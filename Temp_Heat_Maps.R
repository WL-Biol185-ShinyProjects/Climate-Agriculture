#ui.R code for temp changes

library(shiny)
library(leaflet)

ui <- fluidPage(
  
  titlePanel("Global Climate Change Map"),
  
  sidebarLayout(
    sidebarPanel(
      
      helpText(" Visualizing Global Temperature Changes")
    )
  ),
  
  
  mainPanel(
    leafletOutput("map", height = "1000px")
    
    
  )
)



  #server.R code
  


  
  
  






