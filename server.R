library(shiny)
library(leaflet)
library(geojsonio)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(tidyr)
library(sf)
library(countrycode)



countries_data <- readRDS("Countries_data_FailedStates_Islands/combined_countries_data.rds") #Loading in countries dataset
geo <- geojson_read("countries.geo.json", what = "sp") #Loading in GeoJSON file 


#Prepping the data for the intro page 
most_produced_crop <- countries_data %>%
  filter(Year == 2022, Unit == "t") %>% #filtering finding the most crops produced in tons in 2022
  group_by(Area) %>%  #grouping by country
  filter(Value == max(Value, na.rm = TRUE)) %>%
  ungroup() %>%  #remove the grouping
  select(
    Area,
    Most_Produced_Crop = Item, #renaming column 
    Max_Production = Value #renaming column 
  )


#joining GeoJSON with country data
geo@data <-left_join(geo@data, most_produced_crop, by = c("name" = "Area"))

#reading and processing efficiency data call
efficiencydata <- readRDS("efficiency_data /combined_efficiency_data.rds")
efficiencydata <- efficiencydata[efficiencydata$Item != "Hen eggs in shell, fresh", ]

#Loading data for crop yield map 
crop_data <- readRDS("efficiency_data /combined_efficiency_data.rds")

#Temp Heat Map Data Modification
temp_merged <- reactive({    #prepping the heatmap data for temp 

  fixed <- read.csv("fully_temp_data_cleaned.csv")

  temp.data <- fixed %>%
    pivot_longer(
      cols = starts_with("X"),
      names_to = "Year",
      names_prefix = "X",
      values_to = "Celsius"
    ) %>%
    mutate(Year = as.numeric(Year))

  # json file
  world <- st_read("countries.geo.json") %>%
    rename(ISO3 = id)

  # merge by left join
  world %>%
    left_join(temp.data, by = "ISO3")
})


#Crop Yield Map data modification
crop_merged <- reactive({

  #Filtering and joining data so that we can see the total yield of each country in each year for all crops
  yield_table <- crop_data %>%
    group_by(Area, Year) %>%
    summarise(Total_Yield = sum(Value, na.rm = TRUE))

  #correcting country names to match up with country dataset 
  yield_table$Area <- recode(yield_table$Area,
                             "Czechoslovakia" = "Czech Republic",
                             "Serbia and Montenegro" = "Serbia")

  yield_table$Country_Code <- countrycode(yield_table$Area, origin = "country.name", destination = "iso3c")

  #Taking out any non matches
  crop_data <- yield_table %>%
    filter(!is.na(Country_Code)) %>%
    mutate(Year = as.numeric(Year))


  yield_geo <- st_read("countries.geo.json") %>%
    rename(Country_Code = id)

  yield_geo %>%
    left_join(crop_data, "Country_Code")
})


#start of server outputs
server <- function(input, output, session) {

  #INTRODUCTION PAGE 
  
   #input introduction map
  output$Intro_Map <- renderLeaflet({
    pal <- colorBin("Blues", domain = geo@data$Max_Production, na.color = "black") #Colors for the introduction map (black = countries not included/removed from dataset)

    #Creating the leaflet map for the introduction page 
    leaflet(geo) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Max_Production),  #coloring the countries by their Max_Production (sum of total agriculture products in tons)
        color = "white",
        weight = 1,
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 2,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        ),

        #adding the labels
        label = ~paste(
          "Country: ", name,",",
          "Most Produced Crop: ", Most_Produced_Crop,",",
          "Total Production: ", Max_Production, " Tons"
        ),

       #styling the labels
         labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"


        )

      )

  })

#WORLD EVENTS AFFECT ON AGRICULTURE

  output$Yield_Plot <- renderPlot ({

  #Events of focus. Included the country where the event occurred. Looking two years after the event (important for accurate graph). 
  details_for_events <- list(
    "Great Flood of 1993 (Mississippi River)" = list(year = 1995, country = "United States of America"),
    "The Rwandan Civil War (1994)" = list(year = 1996, country = "Rwanda"),
    "The Iraq War (2003)" = list(year = 2005, country = "Iraq"),
    "The Indian Ocean Tsunami (2004)" = list(year = 2006, country = "Indonesia"),
    "Arab Spring (2011)" = list(year = 2013, country = "Egypt"),
    "Russia Annexation of Crimea (2014)" = list(year = 2016, country = "Ukraine"),
    "Ebola Outbreak in West Africa (2014)" = list(year = 2016, country = "Sierra Leone")
  )

  #getting the event from the UI
    selected_event <- input$World_Event

    event <- details_for_events[[selected_event]]
    event_year <- event$year    #the year that goes with the event
    event_country <- event$country #the country that goes with the event

  #filtering the data
    data_for_event_tab <- countries_data %>%
      filter(
        Year >= (event_year - 4) & Year <= event_year, #Year of event will be in the middle, now we see the agricultural production 2 years before and after the event occured.  
        Area %in% event_country, #checking if country's name matches the event's country 
        Unit == "t" ) %>%   #only data unit is in tons

      group_by(Year, Area) %>%    
      summarize(Total_Production = sum(Value, na.rm = TRUE)) %>%  #calculating total crop production 
      ungroup()

    #creating plot
    plot(
      data_for_event_tab$Year, #xaxis - years
      data_for_event_tab$Total_Production, #yaxis - total production
      type = "b",
      col = "red", #line and point color
      xlab = "Year", #label for the x axis
      ylab = "Total Crop Production (tons)", #label for y-axis
      main = paste("Agriculture Production During", selected_event) #title
    )

  })

#FARMING EFFICIENCY TAB 
  #Altering Input 2 based on input 1
  observeEvent(input$selectedCountry, {

    #filtering the data to only use the selected country on the tab 
    filtered_efficiencydata <- efficiencydata %>%
      filter(Area == input$selectedCountry)


    updateSelectInput(session, "selectedProduct",
                      choices = c(unique(filtered_efficiencydata$Item)),
    )
  })
  
  #GGplot for the given data
  output$EfficiencyvsTime <- renderPlot({
    efficiencydata %>%
      filter(Area %in% input$selectedCountry & Item %in% input$selectedProduct) %>%
      
      #creating a line plot 
      ggplot(aes(Year, Value)) +
      geom_line(color = 'blue', linewidth = 2) +
      labs(title = paste("Efficiency vs Time for", input$selectedCountry, "and", paste(input$selectedProduct)),
           x = "Production Years",   #x-axis
           y = "Efficiency (kg/ha)") #y-axis
  })

  #farming efficiency plot variance bar graph
  output$PercentChangevsProduct <- renderPlot({
    
    #using efficiency data to get percent change 
    percent_change_data <- efficiencydata %>%
      filter(Area %in% input$selectedCountry) %>%
      group_by(Item) %>%
      
      #Adding new column for percent change
      mutate(First = head(Value, 1),
             BaselineChange =
               case_when(Value != First ~ (Value - First) * 100 / First, #calculating percent change 
                         TRUE ~ 1 * NA)) %>% #Set to NA if there is no change 
      select(Year, Area, Item, Value, BaselineChange)

    #Adding new column to make table show above or below the 1990 value
    percent_change_data$belowabove <- ifelse(percent_change_data$BaselineChange < 0, "below", "above")

    #Continued modification (filter for selected year and creating the graph)
    percent_change_data %>%
      filter(Year == input$Years) %>%
      arrange(BaselineChange, by_group = TRUE) %>%
      #ggplot for processed data
      ggplot(aes(x=Item, y=BaselineChange, label=BaselineChange)) +
      geom_bar(stat='identity', aes(fill=belowabove), width=.5)  +
      scale_fill_manual(name="Efficiency",
                        labels = c("Above Average", "Below Average"),
                        values = c("above"="#00ba38", "below"="#f8766d")) +
      labs(subtitle="Percent change from earliest production value of a given product based on selected year",
           title= paste("Diverging Bar Graph for", input$selectedCountry, "in", input$Years),
           y = "Percent Change from Baseline",
           x = paste("Products offered by", input$selectedCountry)) +
      #flipping x and y axis
      coord_flip()

  })

#Temp Variance Heat Map
  output$temperature_map <- renderLeaflet({
    # Filter data for selected year
    year_data <- temp_merged() %>%
      filter(Year == input$selected_year)

    #Color Palette 
    pal <- colorNumeric(
      palette = input$color_palette,
      domain = year_data$Celsius,
      na.color = "transparent"
    )

    #Create Leaflet Map 
    leaflet(year_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Celsius), #Fill the countries' based on the temperature change 
        weight = 0.5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        #Add popup to display the temperature details 
        popup = ~paste(     
          Country, "<br>",   
          "Year: ", Year, "<br>",
          "Temperature Change: ", round(Celsius, 2), "°C"
        )
      ) %>%
      addLegend(
        "bottomright",      #position legend at the bottom-right 
        pal = pal,          #Use the same color palette for the legend 
        values = ~Celsius,
        title = paste("Temp Change", input$selected_year, "(°C)"),
        opacity = 1
      )
  })

#Crop Yield Heat Map
  output$yield_map <- renderLeaflet({

    # Filter data for selected year
    yield_data <- crop_merged() %>%
      filter(Year == input$selected_year)

    # color p
    pal <- colorNumeric(
      palette = input$color_palette,
      domain = yield_data$Total_Yield,
      na.color = "transparent"
    )

    #Create Leaflet Map
    leaflet(yield_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Total_Yield), #Fill the countries' based on the yield change 
        weight = 0.5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        popup = ~paste(
          Area, "<br>",
          "Year: ", Year, "<br>",
          "Yield Change: ", round(Total_Yield, 1)
        )
      ) %>%
      addLegend(
        "bottomright",    #position legend at the bottom-right
        pal = pal,        #Use the same color palette for the legend 
        values = ~Total_Yield,
        title = paste("Yield Change:", input$selected_year),
        opacity = 1
      )
  })



}


