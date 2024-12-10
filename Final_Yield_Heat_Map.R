library(shiny)
library(leaflet)
library(tidyverse)
library(geojsonio)
library(dplyr)
library(countrycode)


#naming our ui function for this specific Rscript which we will then call in our master "ui.r" file


crop.ui <- fluidPage(
  titlePanel("Global Crop Yield Change Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Create the slider for year
      sliderInput("selected_year", 
                  "Select Year:",  min = 1990, max = 2020, 
                  value = 2000,
                  step = 1),
      
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
    
    crop_data <- crop_data %>%
      left_join(yield_table, by = c("Area", "Year"))
    
    crop_data$Area <- recode(crop_data$Area, 
                             "Czechoslovakia" = "Czech Republic", 
                             "Serbia and Montenegro" = "Serbia")
    
    crop_data$Country_Code <- countrycode(crop_data$Area, origin = "country.name", destination = "iso3c")
    
    #Taking out any non matches
    
    crop_data <- crop_data %>%
      filter(!is.na(Country_Code))
    
    
    yield_geo <- geojson_read("countries.geo.json", what = "sp")
    
    yield_geo@data <- yield_geo@data %>%
      left_join(crop_data, by = c("id" = "Country_Code"))
    
    yield_geo <- subset(yield_geo, !is.na(yield_geo@data$Country_Code))
    
    yield_geo@data <- left_join(yield_geo@data, crop_data, by = c("Country_Code" = "Country_Code"))
    
    return(yield_geo)
    
  })
  
  # Create the map
  output$yield_map <- renderLeaflet({
    # Filter data for selected year
    yield_geo <- crop_merged()
    yield_geo_year <- yield_geo[yield_geo@data$Year == input$selected_year, ]
    
    # color p
    pal <- colorNumeric(
      palette = input$color_palette, 
      domain = yield_geo_year$Total_Yield,
      na.color = "transparent"
    )
    
    # make leaflet map + create sick hover pop up
    leaflet(yield_geo_year) %>%
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


