#Farming Efficiency


library(dplyr)
library(ggplot2)


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

df <- readRDS("efficiency_data /combined_efficiency_data.rds")
 



  function(input, output, session) {
    
    output$efficiencyplot <- renderPlot({
      input_scatterplot <- ggplot()
      
    }
    
      
    )
    
  }
