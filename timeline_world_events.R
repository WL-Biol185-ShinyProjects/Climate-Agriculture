#TIMELINE OF WORLD EVENTS 

library(shiny) 
library(ggplot2)

worldevents_ui <- fluidPage(
  titlePanel("Major World Events Affect on Agriculture"), 
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "World Event",
        label = "Select a World Event",
        choices = c(
          "1991 Soviet Union Dissolution",
          "1997 Asian Financial Crisis",
          "2004 Indian Ocean Tsunami", 
          "2008 Global Financial Crisis", 
          "2011 Arab Spring", 
          "2014 Ebola Outbreak in West Africa",
          "2020 COVID-19 Pandemic", 
          "2022 War in Ukraine"
        ), 
        
        selected = "2020 COVID-19 Pandemic"
      )
    ),
    
    
    #displays scatterplot 
    mainPanel(
      plotOutput("Yield_Plot")
    )
  )
  
)


#server

worldevents_server <- function(input, output, session){
  
  output$Yield_Plot <- renderPlot ({
    
  })
}