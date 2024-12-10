library(shiny)
library(leaflet) 
library(geojsonio)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(tidyr)
library(sf)

#INTRODUCTION PAGE

countries_data <- readRDS("Countries_data_FailedStates_Islands/combined_countries_data.rds")
geo <- geojson_read("countries.geo.json", what = "sp")

most_produced_crop <- countries_data %>%
  
   
  filter(Year == 2022, Unit == "t") %>% #filtering finding the most crops produced in tons in 2022
  group_by(Area) %>%  #grouping by country
  filter(Value == max(Value, na.rm = TRUE)) %>%
  ungroup() %>%  #remove the grouping
  select(
    Area, 
    Most_Produced_Crop = Item, 
    Max_Production = Value
  )


#joining geojson with country data 
geo@data <-left_join(geo@data, most_produced_crop, by = c("name" = "Area"))

#reading and processing efficiency data call
efficiencydata <- readRDS("efficiency_data /combined_efficiency_data.rds")
efficiencydata <- efficiencydata[efficiencydata$Item != "Hen eggs in shell, fresh", ]

##for efficiency data plot 2
percent_change_data <- efficiencydata %>%                                     
  group_by(Area) %>%                        
  mutate(lag = lag(Value),                        
         ChangefromLast = (Value - lag) * 100 / lag,    
         First = head(Value, 1),                  
         BaselineChange =                       
           case_when(Value != First ~ (Value - First) * 100 / First,
                     TRUE ~ 1 * NA)) %>%            
  select(Year, Area, Item, Value,                 
         ChangefromLast, BaselineChange)
percent_change_data$belowabove <- ifelse(percent_change_data$BaselineChange < 0, "below", "above")
 
#Temp Heat Map Data Modification
temp_merged <- reactive({
  
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
  
  #  merge by left join
  world %>%
    left_join(temp.data, by = "ISO3")
})


#start of server outputs
server <- function(input, output, session) {
 
   #input introduction map 
  output$Intro_Map <- renderLeaflet({
    pal <- colorBin("Blues", domain = geo@data$Max_Production, na.color = "black")
    
    leaflet(geo) %>% 
      addTiles() %>% 
      addPolygons(
        fillColor = ~pal(Max_Production),
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
          textsize = "13px", 
          direction = "auto"
          
          
        )
        
      )
    
  })

#WORLD EVENTS AFFECT ON AGRICULTURE 

  output$Yield_Plot <- renderPlot ({
  
  #picking years and the country of focus for the event
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
        Year >= (event_year - 4) & Year <= event_year,
        Area %in% event_country, #searched this up - %in% checks if something belongs to a vector or list - so it is checking if the countries in event_country is in the column AREA
        Unit == "t" ) %>%   #only data unit is in tons 
      
      group_by(Year, Area) %>% 
      summarize(Total_Production = sum(Value, na.rm = TRUE)) %>%
      ungroup()
    
    #create the actual plot 
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
  
##Code for Farming efficiency tab
  observeEvent(input$selectedCountry, {
    
    filtered_efficiencydata <- efficiencydata %>%
      filter(Area == input$selectedCountry)
    
    
    updateSelectInput(session, "selectedProduct",
                      choices = c(unique(filtered_efficiencydata$Item)),
    )
  })
  
##GGplot for the given data
  
  output$EfficiencyvsTime <- renderPlot({
    efficiencydata %>%
      filter(Area %in% input$selectedCountry & Item %in% input$selectedProduct) %>%
      ggplot(aes(Year, Value)) + 
      geom_line() +
      labs(title = paste("Efficiency vs Time for", input$selectedCountry, "and", paste(input$selectedProduct)),
           x = "Production Years",
           y = "Efficiency (kg/ha)")
  })
  
##farming efficiency plot variance (almost there)
  
  output$PercentChangevsProduct <- renderPlot({
    percent_change_data %>%
      filter(Area %in% input$selectedCountry & Year == input$Years) %>%
      arrange(BaselineChange) %>%
      mutate(Item = factor(Item, ordered = TRUE)) %>%
      ggplot(aes(x=Item, y=BaselineChange, label=BaselineChange)) + 
      geom_bar(stat='identity', aes(fill=belowabove), width=.5)  +
      scale_fill_manual(name="Efficiency", 
                        labels = c("Above Average", "Below Average"), 
                        values = c("above"="#00ba38", "below"="#f8766d")) +
      labs(subtitle="Percent change from earliest production value based on selected year", 
           title= "Diverging Bar Graph") + 
      coord_flip()
    
  })
  
  
#Temp variance heat map
  
  output$temperature_map <- renderLeaflet({
    # Filter data for selected year
    year_data <- temp_merged() %>% 
      filter(Year == input$selected_year)
    
    # color p
    pal <- colorNumeric(
      palette = input$color_palette, 
      domain = year_data$Celsius,
      na.color = "transparent"
    )
    
    # make leaflet map + create sick hover pop up
    leaflet(year_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Celsius),
        weight = 0.5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        popup = ~paste(
          Country, "<br>",
          "Year: ", Year, "<br>",
          "Temperature Change: ", round(Celsius, 2), "°C"
        )
      ) %>%
      addLegend(
        "bottomright",
        pal = pal,
        values = ~Celsius,
        title = paste("Temp Change", input$selected_year, "(°C)"),
        opacity = 1
      )
  })
  
  
    
}


