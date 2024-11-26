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
             
              leafletOutput("Intro_Map", width = "100%", height = "600"),
                p("Hover over a country marker to see details.")
             
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
              
              selectInput(
                inputId = "selectedProduct",
                label = "Products",
                choices = NULL
                ),
              
            mainPanel(
              
              plotOutput("", width = 1000, height = 600)
            )
               
             ),
             
    ),
  
    #Crop Data Panel
    tabPanel("Crop Data",
             
             
             )
    
  ), 
  

)









