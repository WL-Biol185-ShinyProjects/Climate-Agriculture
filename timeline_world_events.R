#TIMELINE OF WORLD EVENTS 

library(shiny) 
library(ggplot2)

#ui

#WORLD EVENTS AFFECT ON AGRICULTURE  

tabPanel("World Events",
         titlePanel("How do Major Events in a Country Affect the Agriculture Production for that Country?"), 
         
         
         div(
           
           p(
             "In this tab, we explore the impact of significant world events on agricultural production to provide a different perspective on factors influencing agriculture other than climate change. While climate change is an importaant issue for agriculture, other events - such as natural disasters, wars, political uprisings, and epidemics. These events can affect infrastructure and hinder the production of crops. It is important to note that these charts are in the context of one country. Also, focus on the year of the event and the year following the event.",
             style = "font-size: 25px; text-align: center; margin-bottom: 45px; margin-top: 45px;"
           )
         ),
         
         p(
           "The Seven Events Explored:",
           style = "font-size: 23px; text-align: center; margin-bottom: 30px;"
         ),
         
         p(
           "1. The Great Flood of 1993: The Mississippi River flooded and it affected numerous states in the USA, including North Dakota, South Dakota, Nebraska, Kansas, Missouri, Wisconsin, and Illinois.",
           style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
         ),
         
         p(
           "2. The Rwandan Civil War (1994): A violent conflict in Rwanda that resulted in the loss of over 800,000 lives within approximately 100 days.",
           style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
         ),
         
         p(
           "3. The Iraq War (2003): The United States invaded Iraq to overthrow Saddam Hussein's regime, leading to prolonged violence.",
           style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
         ),
         
         p(
           "4. The Indian Ocean Tsunami (2004): A massive undersea earthquake, causing widespread destruction and loss of life across several countries in Southeast Asia, especially Indonesia.",
           style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
         ),     
         
         p(
           "5. Arab Spring (2011): A series of pro-democracy uprisings and protests across the Middle East and North Africa (we are focusing on the impact of agricultural production in Egypt).",
           style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
         ), 
         
         p(
           "6. The Russia Annexation of Crimea (2014): A controversial takeover in which Russia seized control of the Crimean Peninsula from Ukraine.",
           style = "font-size: 18px; text-align: center; margin-bottom: 20px;"
         ),       
         
         p(
           "7. The Ebola Outbreak in West Africa (2014): A severe public health crisis that highlighted the need for global health preparedness.",
           style = "font-size: 18px; text-align: center; margin-bottom: 40px;"
         ),     
         
         
         sidebarLayout(
           sidebarPanel(
             selectInput(
               inputId = "World_Event",
               label = "Select a World Event",
               choices = c(
                 "Great Flood of 1993 (Mississippi River)",
                 "The Rwandan Civil War (1994)",
                 "The Iraq War (2003)",
                 "The Indian Ocean Tsunami (2004)",
                 "Arab Spring (2011)",
                 "Russia Annexation of Crimea (2014)",
                 "Ebola Outbreak in West Africa (2014)"
               ), 
               
               
               selected = "1994 Rwandan Civil War"
             )
           ),
           
           
           #displays scatterplot 
           mainPanel(
             plotOutput("Yield_Plot", height = "600px")
             
             
             
           )
         )
         
)


#server

output$Yield_Plot <- renderPlot ({
  
  #picking years and the country of focus for the event
  details_for_events <- list(
    "Great Flood of 1993 (Mississippi River)" = list(year = 1995, country = "United States of America"),
    "The Rwandan Civil War (1994)" = list(year = 1996, country = "Rwanda"),
    "The Iraq War (2003)" = list(year = 2005, country = "Iraq"),
    "The Indian Ocean Tsunami (2004)" = list(year = 2006, country = "Indonesia"),
    "Arab Spring (2011)" = list(year = 2013, country = "Egypt"),
    "Russia Annexation of Crimea (2014)" = list(year = 2016, country = "Ukraine"),
    "Ebola Outbreak in West Africa (2014)" = list(year = 2016, country = "Sierra Leone")
  )
  
  #getting the event from the UI   
  selected_event <- input$World_Event
  
  event <- details_for_events[[selected_event]]
  event_year <- event$year    #the year that goes with the event 
  event_country <- event$country #the country that goes with the event 
  
  #filtering the data
  data_for_event_tab <- countries_data %>% 
    filter(
      Year >= (event_year - 4) & Year <= event_year,
      Area %in% event_country, #searched this up - %in% checks if something belongs to a vector or list - so it is checking if the countries in event_country is in the column AREA
      Unit == "t" ) %>%   #only data unit is in tons 
    
    group_by(Year, Area) %>% 
    summarize(Total_Production = sum(Value, na.rm = TRUE)) %>%
    ungroup()
  
  #create the actual plot 
  plot(
    data_for_event_tab$Year, #xaxis - years
    data_for_event_tab$Total_Production, #yaxis - total production
    type = "b", 
    col = "red", #line and point color 
    xlab = "Year", #label for the x axis
    ylab = "Total Crop Production (tons)", #label for y-axis 
    main = paste("Agriculture Production During", selected_event) #title 
  )
  
})