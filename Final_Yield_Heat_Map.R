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
                  "Select Year:",  min = 1991, max = 2022, 
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
    # load up data
    crop_data <- readRDS("efficiency_data /combined_efficiency_data.rds")
    ##Djibouti is an outlier so it is removed for clarity of the heat map (Over 3000% growth)
    crop_data <- crop_data[crop_data$Area != "Djibouti", ]
    
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
    # Filter data for selected year and make new variable for change from baseline year
    yield_data <- crop_merged() %>%
      group_by(Country_Code) %>%
      mutate(First = head(Total_Yield, 1),
            BaselineChange =
            case_when(Total_Yield != First ~ (Total_Yield - First) * 100 / First,
                       TRUE ~ 1 * NA)) %>%
      filter(Year == input$selected_year)
    
    # Making palette based on percent change from baseline year
    pal <- colorNumeric(
      palette = input$color_palette, 
      domain = yield_data$BaselineChange,
      na.color = "transparent"
    )
    
    # making yield leaflet
    leaflet(yield_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(BaselineChange),
        weight = 0.5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        popup = ~paste(
          Area, "<br>",
          "Year: ", Year, "<br>",
          "Total Yield: ", round(Total_Yield, 1), "<br>",
          "% Yield Change: ", round(BaselineChange, 1)
        )
      ) %>%
      # Adding the key to give contex in percent change form
      addLegend(
        "bottomright",
        pal = pal,
        values = ~BaselineChange,
        title = paste("Yield Change:", input$selected_year),
        opacity = 1
      )
  })
  
  
}

shinyApp(crop.ui, crop.server)
