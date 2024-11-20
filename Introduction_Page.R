#Introduction Page

library(shiny)
library(tidyverse)
library(plotly)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)



#ui 
Introduction_Page_ui <- fluidPage(
  titlePanel("Climate Change's Effect on Agricultural Production"), 
  
  tabsetPanel(
    #intro tab
    tabPanel("Introduction",
             leafletOutput("Intro_Map", width = "100%", height = "600"),
             p("Hover over a country marker to see details.")
             ),
    
    tabPanel("Heat Maps", 
        sidebarLayout(
          sidebarPanel(
            radioButtons("heatmap_type", "Select Heatmap Type:", 
                         choices = list("Temperature Change" = "temp",
                                        "Crop Yield Change" = "yield")), 
            checkboxInput("baseline_toggle", "Show values relative to baseline year (1990)")
            ), 
          mainPanel(
            leafletOutput("heatmap", width = "100%", height = "600")
          )
          )
        ),
    
    #add other tabs 
    
  ) 
  
)



#server.R

# trying to combine datasets into one - still working through says it cannot allocate a vector of this size - need to talk about whether we should delete more countries (failed states/small islands)
file_paths <- c( 
  "Countries_data_FailedStates_Islands/afgan_cambo_cleaned.csv",
  "Countries_data_FailedStates_Islands/camer_elsalv_cleaned.csv",
  "Countries_data_FailedStates_Islands/eqgu_hung_cleaned.csv",
  "Countries_data_FailedStates_Islands/ice_lib_cleaned.csv",
  "Countries_data_FailedStates_Islands/lith_monte_cleaned.csv",
  "Countries_data_FailedStates_Islands/moro_roma_cleaned.csv",
  "Countries_data_FailedStates_Islands/russfed_swed_cleaned.csv",
  "Countries_data_FailedStates_Islands/switz_uk_cleaned.csv",
  "Countries_data_FailedStates_Islands/tanz_zimb_cleaned.csv"
)

countries_data <- file_paths %>%
  lapply(read.csv) %>% 
  bind_rows()
            


