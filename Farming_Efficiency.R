#Farming Efficiency

library(tidyverse)
library(shiny)
library(dplyr)
library(ggplot2)
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


##working percent change code
percent_change_data <- efficiencydata %>%                                     
  group_by(Area, Item) %>%                        
  mutate(lag = lag(Value),                        
         ChangefromLast = (Value - lag) * 100 / lag,    
         First = head(Value, 1),                  
         BaselineChange =                       
           case_when(Value != First ~ (Value - First) * 100 / First,
                     TRUE ~ 1 * NA)) %>%            
  select(Year, Item, Value,                 
         ChangefromLast, BaselineChange)

percent_change_data$belowabove <- ifelse(percent_change_data$BaselineChange < 0, "below", "above")


percent_change_data <- percent_change_data[order(percent_change_data$BaselineChange), ] 
percent_change_data$Item <- factor(percent_change_data$Item, levels = percent_change_data$Item) 

ggplot(percent_change_data, aes(x=Item, y=BaselineChange, label=BaselineChange)) + 
  geom_bar(stat='identity', aes(fill=belowabove), width=.5)  +
  ##this part is fine
  scale_fill_manual(name="Efficiency", 
                    labels = c("Above Average", "Below Average"), 
                    values = c("above"="#00ba38", "below"="#f8766d")) +
  labs(subtitle="Percent change from earliest production value based on selected year", 
       title= "Diverging Bar Graph") + 
  coord_flip()





observeEvent(input$selectedCountry, {
    
    filtered_percent_change_data <- percent_change_data %>%
      filter(Area == input$selectedCountry)
    
    
    updateSelectInput(session, "Years",
                      choices = c(unique(filtered_efficiencydata$Item)),
    )
  })
  

##possibly might need to group by years as well but check once we run the document
  
  output$PercentChangevsProduct <- renderPlot({
    percent_change_data %>%
      filter(Area %in% input$selectedCountry & Year %in% input$Years) %>%
      ggplot(percent_change_data, aes(x=Item, y=BaselineChange, label=BaselineChange)) + 
      geom_bar(stat='identity', aes(fill=belowabove), width=.5)  +
      scale_fill_manual(name="Efficiency", 
                        labels = c("Above Average", "Below Average"), 
                        values = c("above"="#00ba38", "below"="#f8766d")) +
      labs(subtitle="Percent change from earliest production value based on selected year", 
           title= "Diverging Bar Graph") + 
      coord_flip()
    
  })
