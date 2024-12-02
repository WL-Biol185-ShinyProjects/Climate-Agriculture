library(shiny)
library(tidyverse)
library(plotly)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)
library(base)

#File Designations
countryfile <- "Countries_data_FailedStates_Islands/combined_countries_data.rds"
countrynames <- readRDS(countryfile)


#defining the UI

ui <- fluidPage(theme = shinytheme("cosmo"),
                
  navbarPage(
    
  #title of webpage
    "Climate Change's Effect on Agricultural Production", 
  
    
  #Intro panel
    tabPanel("Introduction",
             
             div(
               p( 
                 "Welcome to this application! Our goal is to help you explore the impacts of climate change on agriculture across the world. Click on the tabs above to see how changes in the climate affects agriculture in different countries.",
                 style = "font-size: 30px; text-align: center; margin-bottom: 45px;"
                 )
             ),
             
              p(
                "We did not include small islands and the top ten failed states as they have other factors that could affect agriculture production other than climate change. We wanted to focus only on the effect of climate change on agriculture production.",
                style = "font-size: 20px; text-align: center; margin-bottom: 20px;"
              ),
             
              p(
                "Also, this application only takes into account temperature data and agriculture data from the years of 1990 through 2022.", 
                style = "font-size: 15px; text-align: center; margin-bottom: 45px;"
              ),
             
              leafletOutput("Intro_Map", width = "100%", height = "600px"),
             
             div(
               p(
                 "To get you started. The map above shows the total production (in tons) of the most produced crop in each country for the year 2022. Hover over a country to see detailed information, including the name of the crop and its production quantity!",
                 style = "font-size: 30px; text-align: center; margin-top: 35px;"
               )
             )
             
            ),
  
  
  #Heat Maps Panel
    tabPanel("Heat Maps", 
            
             sidebarPanel(
               radioButtons("heatmap_type", "Select Heatmap Type:", 
                              choices = list("Temperature Change" = "temp",
                                             "Crop Yield Change" = "yield")
                            ), 
                 
                checkboxInput("baseline_toggle", "Show values relative to baseline year (1990)")
                
              ), 
             
             
             
             
              mainPanel(
                 leafletOutput("heatmap", width = "100%", height = "600")
                        )
    ),
    
  
  
    #Efficiency Panel
    tabPanel("Farming Efficiency",
          
             sidebarPanel(
               
              selectInput(
                inputId = "selectedCountry",
                label = "Countries",
                choices = c(unique(countrynames$Area)),
                selected = "Albania",
                ),
              
              hr(),
              
              helpText("Available Products for Selected Country"),
              selectInput(
                inputId = "selectedProduct",
                label = "Products",
                choices = NULL
                ),
              
            mainPanel(
              
              plotOutput("EfficiencyvsTime", width = 500, height = 400)
            ),
               
          ),
             
    
  
    #Crop Data Panel
    tabPanel("Crop Data",
             
             
             )
    
  ), 
  
  #WORLD EVENTS AFFECT ON AGRICULTURE  
  
  tabPanel("World Events",
    titlePanel("Major World Events Effect on Agriculture"), 
    
    sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = "World_Event",
          label = "Select a World Event",
          choices = c(
            "Great Flood of 1993",
            "1994 Rwandan Genocide",
            "2003 Iraq War",
            "2004 Indian Ocean Tsunami",
            "2011 Arab Spring",
            "2014 Russia Annexation of Crimea",
            "2014 Ebola Outbreak in West Africa"
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
  

)
)









