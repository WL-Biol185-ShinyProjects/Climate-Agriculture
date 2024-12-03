#Farming Efficiency

library(tidyverse)
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)

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

##Needed to clean dataset to tidy set for graph
efficiencydata <- readRDS("efficiency_data /combined_efficiency_data.rds")

cleanefficiency <- efficiencydata[, -c(1, 2, 3, 4, 5, 7, 8, 9, 11, 13, 15, 16)]

spreadefficiency <- cleanefficiency %>%
  pivot_wider(names_from = Year, values_from = Value)

##Function for creating the products to be dependent on the selected
function(input, output, session) {
  
  
  observeEvent(input$selectedCountry, {
    
    filtered_efficiencydata <- efficiencydata %>%
      filter(Area == input$selectedCountry)
    
    
    updateSelectInput(session, "selectedProduct",
                      choices = c(unique(filtered_efficiencydata$Item)),
    )
  })
  
  ##GGplot for the given data
  
  output$EfficiencyvsTime <- renderPlot({
    efficiencydata %>%
      filter(Area %in% input$selectedCountry & Item %in% input$selectedProduct) %>%
      ggplot(aes(Year, Value)) + 
      geom_line() +
      labs(title = paste("Efficiency vs Time for", input$selectedCountry, "and", paste(input$selectedProduct)),
           x = "Production Years",
           y = "Efficiency (kg/ha)")
  })
  
  
}


## for the UI later

sliderInput("Years", "Years of Production:",
            min = 1990,
            max = 2022,
            value = 1990
            )



