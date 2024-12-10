library(shiny)
library(leaflet)
library(tidyverse)
library(geojsonio)
library(dplyr)
library(countrycode)
library(sf)

#naming our ui function for this specific Rscript which we will then call in our master "ui.r" file


crop.ui <- fluidPage(
  titlePanel("Global Crop Yield Change Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Create the slider for year
      sliderInput("selected_year", 
                  "Select Year:",  min = 1990, max = 2020, 
                  value = 2000,
                  step = 1,
                  sep = ""),
      
      # Cool feature that allows us to change up color scheme for our data
      selectInput("color_palette", 
                  "Color Palette:", 
                  choices = c("Viridis" = "viridis", 
                              "Magma" = "magma", 
                              "Inferno" = "inferno"),
                  selected = "viridis")
    ),
    
    mainPanel(
      # Leaflet map output
      leafletOutput("yield_map", height = 600),
      
      # explanatory panel NOTE: look on stackoverflow for fix, ... wont show up
      verbatimTextOutput("This")
    )
  )
)

# creating server for master server
crop.server <- function(input, output, session) {
  
  crop_merged <- reactive({
    # loadup data
    crop_data <- readRDS("efficiency_data /combined_efficiency_data.rds")
    
 #Filtering and joining data so that we can see the total yield of each country in each year for all crops   
    yield_table <- crop_data %>% 
      group_by(Area, Year) %>%
      summarise(Total_Yield = sum(Value, na.rm = TRUE))
    
    
    yield_table$Area <- recode(yield_table$Area, 
                             "Czechoslovakia" = "Czech Republic", 
                             "Serbia and Montenegro" = "Serbia")
    
    yield_table$Country_Code <- countrycode(yield_table$Area, origin = "country.name", destination = "iso3c")
    
    #Taking out any non matches
    
    crop_data <- yield_table %>%
      filter(!is.na(Country_Code)) %>%
      mutate(Year = as.numeric(Year))
    
    
    yield_geo <- st_read("countries.geo.json") %>%
        rename(Country_Code = id)
    
    yield_geo %>%
      left_join(crop_data, "Country_Code")
    
  })
  
  # Create the map
  output$yield_map <- renderLeaflet({
    # Filter data for selected year
    yield_data <- crop_merged() %>%
      filter(Year == input$selected_year)
    
    # color p
    pal <- colorNumeric(
      palette = input$color_palette, 
      domain = yield_data$Total_Yield,
      na.color = "transparent"
    )
    
    # make leaflet map + create sick hover pop up
    leaflet(yield_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Total_Yield),
        weight = 0.5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        popup = ~paste(
          Area, "<br>",
          "Year: ", Year, "<br>",
          "Yield Change: ", round(Total_Yield, 1)
        )
      ) %>%
      addLegend(
        "bottomright",
        pal = pal,
        values = ~Total_Yield,
        title = paste("Yield Change:", input$selected_year),
        opacity = 1
      )
  })
  
  
}

shinyApp(crop.ui, crop.server)
