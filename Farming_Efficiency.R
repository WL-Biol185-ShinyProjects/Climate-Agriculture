#Farming Efficiency

library(tidyverse)
library(shiny)
library(leaflet)
library(dplyr)
library(plyr)
library(ggplot2)
library(shinythemes)

file_paths <- c( 
  "efficiency_data /only_efficiency_afgan_cambo.csv",
  "efficiency_data /only_efficiency_camer_elsalv.csv",
  "efficiency_data /only_efficiency_eqgu_hung.csv",
  "efficiency_data /only_efficiency_ice_lib.csv",
  "efficiency_data /only_efficiency_lith_monte.csv",
  "efficiency_data /only_efficiency_moro_roma.csv",
  "efficiency_data /only_efficiency_russfed_swed.csv",
  "efficiency_data /only_efficiency_switz_uk.csv",
  "efficiency_data /only_efficiency_tanz_zimb.csv",
)

  efficiency_data <- file_paths %>%
    lapply(read.csv) %>% 
    bind_rows()


  function(input, output, session) {
    output$CountryMap <- renderLeaflet()
    
  }
