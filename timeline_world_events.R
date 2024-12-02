#TIMELINE OF WORLD EVENTS 

library(shiny) 
library(ggplot2)

fluidPage(
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


#server

output$Yield_Plot <- renderPlot ({
  
  details_for_events <- list(
    "Great Flood of 1993" = list(year = 1995, country = "United States of America"),
    "1994 Rwandan Genocide" = list(year = 1996, country = "Rwanda"),
    "2003 Iraq War" = list(year = 2005, country = "Iraq"),
    "2004 Indian Ocean Tsunami" = list(year = 2006, country = "Indonesia"),
    "2011 Arab Spring" = list(year = 2013, country = "Egypt"),
    "2014 Russia Annexation of Crimea" = list(year = 2016, country = "Ukraine"),
    "2014 Ebola Outbreak in West Africa" = list(year = 2016, country = "Sierra Leone")
  )
  
  #get the selected event and the year that goes with it  
  selected_event <- input$World_Event
  
  event <- details_for_events[[selected_event]]
  event_year <- event$year
  event_country <- event$country
  
  #filtering the data
  data_for_event_tab <- countries_data %>% 
    filter(
      Year >= (event_year - 4) & Year <= event_year,
      Area %in% event_country,
      Unit == "t" ) %>%
    
    group_by(Year, Area) %>% 
    summarize(Total_Production = sum(Value, na.rm = TRUE)) %>%
    ungroup()
  
  #create the actual plot 
  plot(
    data_for_event_tab$Year, 
    data_for_event_tab$Total_Production, 
    type = "b", 
    col = "blue", 
    xlab = "Year",
    ylab = "Total Crop Production (tons)",
    main = paste("Agriculture Production During", selected_event)
  )
  
})
}