
#THESIS/EXPLAINATION: this shiny app will allow our CSV temperature data (alongside the latitude and longitude in the csv)
# then we convert into GeoJSON format and visualize it on a heatmap. the heatmap is supported by Leaflet




#packages necessary for this r script to run

library(shiny)
library(leaflet)
library(tidyverse)
library(geojsonio)
library(dplyr)

#naming our ui function for this specific Rscript which we will then call in our master "ui.r" file


Temp_Heat_Maps_ui <- fluidPage(
  
 
   titlePanel("Global Climate Change Map"),
  
 
    sidebarLayout(
    sidebarPanel(
      
      fileInput("file1", "fully_temp_data_cleaned.csv",
                accept = c(".csv")),
      
      tags$hr(),
      checkboxInput("header", "Header", TRUE),
      actionButton("Generate HeatMap")
    ),
      
      
      
      
      
      helpText(" Visualizing Global Temperature Changes"),
    
    mainPanel(
      leafletOutput("heatmap")
      
      
    )
    )
  )
  
  




  #specific code for the Temps_Heat_Maps_server which we will store in this Rscript and then call-up in our master "server.r" file
  


Temp_Heat_Maps_server <- function(input, output, session) {
  
  
  #the block below reads CSV and interpets first row as header, df means "dataframe" which is what is containing our csv in this script
  
  df <- read.csv(inFile$datapath, header = input$header)
  
  observeEvent(input$generateHeatmap,
               df <- data_input(),
               
               geojson <- geojsonio::geojson_list(df, lat = "latitude", lon = "longitude"),
               
               
               
               #Makes the GeoJSON coordinates into a form that is readable for our leaflet heatmap so it can run in app
               #creates in a list (points) that combines each element (long, lat, and "csv value" )
               
               
            points <- lapply(geojson$features, function(feature)   {
              c(features$geometry$coordinates[[1]], features$geometry$coordinates, features$properties$value)
              }),
              
              
              #creates the actual heatmap now that our data is in a form leaflet can understand
            
            output$heatmap <- renderLeaflet({
              leaflet() %>%
                addTiles() %>%
                addHeatmap(data = points, radius = 15, blur = 20, max = 100, gradient = "ylOrRd")
            })

  )

shinyApp(Temp_Heat_Maps_ui, Temp_Heat_Maps_server )
              
              
              
              
              
}
          
              
              
              
              
              
              
              
              
              
            
               
               
               
               
               
          


