#Farming Efficiency

library(tidyverse)
library(dplyr)
library(ggplot2)


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
      
      updateSelectInput(
        inputId = "selectedProduct",
        choices = c(filter(efficiencydata, unique(countrynames$Item & countrynames$Area))),
      )
    })
    
    
    
    output$efficiencyplot <- renderPlot({
      ggplot(efficiencydata, mapping = aes())
      
    }
  
    )
    
  }
