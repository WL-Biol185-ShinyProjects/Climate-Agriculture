#Introduction Page

library(shiny)
library(tidyverse)
library(plotly)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)


# trying to combine datasets into one - still working through says it cannot allocate a vector of this size - need to talk about whether we should delete more countries (failed states/small islands)
file_paths <- c( 
  "Countries_Data/fully_afgan_cambo_cleanedV2.csv",
  "Countries_Data/fully_camer_elsalv_cleaned.csv",
  "Countries_Data/fully_eqgu_hung_cleaned.csv",
  "Countries_Data/fully_ice_lib_cleaned.csv",
  "Countries_Data/fully_lith_monte_cleaned.csv",
  "Countries_Data/fully_moro_roma_cleaned.csv",
  "Countries_Data/fully_russfed_swed_cleaned.csv",
  "Countries_Data/fully_switz_uk_cleaned.csv",
  "Countries_Data/fully_tanz_zimb_cleaned.csv"
  )

countries_data <- file_paths %>%
  lapply(read.csv) %>% 
  bind_rows()


#ui 
ui <- fluidPage(
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
  "Countries_Data/fully_afgan_cambo_cleanedV2.csv",
  "Countries_Data/fully_camer_elsalv_cleaned.csv",
  "Countries_Data/fully_eqgu_hung_cleaned.csv",
  "Countries_Data/fully_ice_lib_cleaned.csv",
  "Countries_Data/fully_lith_monte_cleaned.csv",
  "Countries_Data/fully_moro_roma_cleaned.csv",
  "Countries_Data/fully_russfed_swed_cleaned.csv",
  "Countries_Data/fully_switz_uk_cleaned.csv",
  "Countries_Data/fully_tanz_zimb_cleaned.csv"
)

countries_data <- file_paths %>%
  lapply(read.csv) %>% 
  bind_rows()
            


