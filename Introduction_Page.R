#Introduction Page

library(shiny)
library(tidyverse)
library(plotly)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)



#ui 
ui <- fluidPage(theme = shinytheme("cosmo"),
                
                navbarPage(
                  
                  #title of webpage
                  "Climate Change's Effect on Agricultural Production", 
                  
                  
                  #Intro panel
                  tabPanel("Introduction",
                           
                           div(
                             p( 
                               "Welcome to this application! Our goal is to help you explore the impacts of climate change on agriculture across the world. Click on the tabs above to see how changes in the climate affects agriculture in different countries.",
                               style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
                             )
                           ),
                           
                           p(
                             "We did not include small islands and the top ten failed states as they have other factors that could affect agriculture production other than climate change. We wanted to focus only on the effect of climate change on agriculture production.",
                             style = "font-size: 16px; text-align: center; margin-bottom: 30px;"
                           ),
                           
                           leafletOutput("Intro_Map", width = "100%", height = "600px"),
                           
                           div(
                             p(
                               "To get you started. The map above shows the total production (in tons) of the most produced crop in each country for the year 2022. Hover over a country to see detailed information, including the name of the crop and its production quantity!",
                               style = "font-size: 16px; text-align: center; margin-top: 25px;"
                             )
                           )
                           
                  )
    #other tabs will go after the comma



#server.R

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
}
















