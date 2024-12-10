#Introduction Page

library(shiny)
library(tidyverse)
library(plotly)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)



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
             plotOutput("Yield_Plot", height = "600px"),
             
             p(
               "The Seven Events Explored:",
               style = "font-size: 20px; text-align: left; margin-bottom: 30px;"
             ),
             
             p(
               "1. The Great Flood of 1993: The Mississippi River flooded and it affected numerous states in the USA, including North Dakota, South Dakota, Nebraska, Kansas, Missouri, Wisconsin, and Illinois.",
               style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
             ),
             
             p(
               "2. The Rwandan Civil War (1994): A violent conflict in Rwanda that resulted in the loss of over 800,000 lives within approximately 100 days.",
               style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
             ),
             
             p(
               "3. The Iraq War (2003): The United States invaded Iraq to overthrow Saddam Hussein's regime, leading to prolonged violence.",
               style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
             ),
             
             p(
               "4. The Indian Ocean Tsunami (2004): A massive undersea earthquake, causing widespread destruction and loss of life across several countries in Southeast Asia, especially Indonesia.",
               style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
             ),     
             
             p(
               "5. Arab Spring (2011): A series of pro-democracy uprisings and protests across the Middle East and North Africa (we are focusing on the impact of agricultural production in Egypt).",
               style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
             ), 
             
             p(
               "6. The Russia Annexation of Crimea (2014): A controversial takeover in which Russia seized control of the Crimean Peninsula from Ukraine.",
               style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
             ),       
             
             p(
               "7. The Ebola Outbreak in West Africa (2014): A severe public health crisis that highlighted the need for global health preparedness.",
               style = "font-size: 15px; text-align: left;"
             )      
             
           )
         )
         
)

)



#server.R

#introduction page
#input introduction map 
output$Intro_Map <- renderLeaflet({
  pal <- colorBin("Blues", domain = geo@data$Max_Production, na.color = "black")
  
  leaflet(geo) %>% 
    addTiles() %>% 
    addPolygons(
      fillColor = ~pal(Max_Production),
      color = "white",
      weight = 1, 
      fillOpacity = 0.7, 
      highlight = highlightOptions(
        weight = 2, 
        color = "#666", 
        fillOpacity = 0.9, 
        bringToFront = TRUE
      ), 
      
      #adding the labels 
      label = ~paste(
        "Country: ", name,",",
        "Most Produced Crop: ", Most_Produced_Crop,",", 
        "Total Production: ", Max_Production, " Tons"
      ),
      
      #styling the labels 
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"), 
        textsize = "13px", 
        direction = "auto"
        
        
      )
      
    )
  
})















