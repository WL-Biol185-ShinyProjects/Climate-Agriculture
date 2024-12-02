library(shiny)
library(leaflet) 
library(geojsonio)
library(dplyr)
library(ggplot2)

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

efficiencydata <- readRDS("efficiency_data /combined_efficiency_data.rds")

server <- function(input, output, session) {
 
   #input introduction map 
  output$Intro_Map <- renderLeaflet({
    pal <- colorBin("Blues", domain = geo@data$Max_Production, na.color = "transparent")
    
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
          "Max Production: ", Max_Production, " Tons"
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
    "1994 Rwandan Genocide" = list(year = 1996, country = "Rwanda"),
    "2003 Iraq War" = list(year = 2005, country = "Iraq"),
    "2004 Indian Ocean Tsunami" = list(year = 2006, country = "Indonesia"),
    "2011 Arab Spring" = list(year = 2013, country = "Egypt"),
    "2014 Russia Annexation of Crimea" = list(year = 2016, country = "Ukraine"),
    "2014 Ebola Outbreak in West Africa" = list(year = 2016, country = "Sierra Leone")
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
  
  ##Raw data code
  output$Raw_Product_Data = DT::renderDataTable({
    countries_data
  })
    
}

