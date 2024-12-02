library(shiny)
library(leaflet) 
library(geojsonio)
library(dplyr)

#INTRODUCTION PAGE

countries_data <- readRDS("Countries_data_FailedStates_Islands/combined_countries_data.rds")
geo <- geojson_read("countries.geo.json", what = "sp")

most_produced_crop <- countries_data %>%
  
   
  filter(Year == 2022, Unit == "t") %>% #filtering finding the most crops produced in tons in 2022
  group_by(Area) %>%  #grouping by country
  filter(Value == max(Value, na.rm = TRUE)) %>%
  ungroup() %>%  #remove the grouping
  select(
    Area, 
    Most_Produced_Crop = Item, 
    Max_Production = Value
  )


#joining geojson with country data 
geo@data <-left_join(geo@data, most_produced_crop, by = c("name" = "Area"))


server <- function(input, output, session) {
 
   #input introduction map 
  output$Intro_Map <- renderLeaflet({
    pal <- colorBin("Blues", domain = geo@data$Max_Production, na.color = "transparent")
    
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
          "Max Production: ", Max_Production, " Tons"
        ),
        
       #styling the labels 
         labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"), 
          textsize = "13px", 
          direction = "auto"
          
          
        )
        
      )
    
  })
}


# Define server logic required to draw a histogram
#function(input, output) {
  
  #loading a test dataset
  #data <- read.csv("fully_afgan_cambo_cleaned.csv")
  
  #output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R 
    #x  <-  data$Value 
    #bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    #hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  #})
  
#}