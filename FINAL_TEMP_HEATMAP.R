library(shiny)
library(sf)
library(dplyr)
library(tidyr)
library(leaflet)

# define temp_ui
temp.ui <- fluidPage(
  titlePanel("Global Temperature Change Visualization"),
  
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
      leafletOutput("temperature_map", height = 600),
      
      # explanatory panel NOTE: look on stackoverflow for fix, ... wont show up
      verbatimTextOutput("This")
    )
  )
)

# server Logic+ edits our initial dataset so that we get all temp columns strictly numeric and loaded up into just 2, a year and temp column
temp.server <- function(input, output, session) {
  
  temp_merged <- reactive({
    # loadup data
    fixed <- read.csv("fully_temp_data_cleaned.csv")
    
    
    temp.data <- fixed %>%
      pivot_longer(
        cols = starts_with("X"),
        names_to = "Year",
        names_prefix = "X",
        values_to = "Celsius"
      ) %>%
      mutate(Year = as.numeric(Year))
    
    # json file
    world <- st_read("countries.geojson") %>%
      rename(ISO3 = iso_a3)
    
    #  merge by left join
    world %>%
      left_join(temp.data, by = "ISO3")
  })
  
  # Create the map
  output$temperature_map <- renderLeaflet({
    # Filter data for selected year
    year_data <- temp_merged() %>% 
      filter(Year == input$selected_year)
    
    # color p
    pal <- colorNumeric(
      palette = input$color_palette, 
      domain = year_data$Celsius,
      na.color = "transparent"
    )
    
    # make leaflet map + create sick hover pop up
    leaflet(year_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(Celsius),
        weight = 0.5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        popup = ~paste(
          Country, "<br>",
          "Year: ", Year, "<br>",
          "Temperature Change: ", round(Celsius, 2), "°C"
        )
      ) %>%
      addLegend(
        "bottomright",
        pal = pal,
        values = ~Celsius,
        title = paste("Temp Change", input$selected_year, "(°C)"),
        opacity = 1
      )
  })
  

}

# Run the application 
shinyApp(temp.ui, temp.server)