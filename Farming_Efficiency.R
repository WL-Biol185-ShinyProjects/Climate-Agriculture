#Farming Efficiency

library(tidyverse)
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)


##Combining all efficiency data into one plot
file_paths <- c(
  "efficiency_data /only_efficiency_afgan_cambo.csv",
  "efficiency_data /only_efficiency_camer_elsalv.csv",
  "efficiency_data /only_efficiency_eqgu_hung.csv",
  "efficiency_data /only_efficiency_ice_lib.csv",
  "efficiency_data /only_efficiency_lith_monte.csv",
  "efficiency_data /only_efficiency_moro_roma.csv",
  "efficiency_data /only_efficiency_russfed_swed.csv",
  "efficiency_data /only_efficiency_switz_uk.csv",
  "efficiency_data /only_efficiency_tanz_zimb.csv"
)

countries_data <- file_paths %>%
  lapply(read.csv) %>%
  bind_rows()

saveRDS(countries_data, file = "efficiency_data /combined_efficiency_data.rds")

efficiencydata <- readRDS("efficiency_data /combined_efficiency_data.rds")



##Function for creating the products to be dependent on the selected
function(input, output, session) {
  
  
  observeEvent(input$selectedCountry, {
    
    filtered_efficiencydata <- efficiencydata %>%
      filter(Area == input$selectedCountry)
    
    
    updateSelectInput(session, "selectedProduct",
                      choices = c(unique(filtered_efficiencydata$Item)),
    )
  })
  
  output$EfficiencyvsTime <- renderPlot({
    efficiencydata %>%
      filter(Area %in% input$selectedCountry & Item %in% input$selectedProduct) %>%
      ggplot(aes(Year, Value)) + 
      geom_line()
  })
  
  
}






