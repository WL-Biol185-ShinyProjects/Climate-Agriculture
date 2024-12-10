#Crop Heat Maps




#creates a "crop_data" file from the rds


# Run the application 
shinyApp(temp.ui, temp.server)

crop_data <- readRDS("efficiency_data /combined_efficiency_data.rds")

ISO <- read.csv("fully_temp_data_cleaned.csv")


total_yield <- crop_data %>% 
  group_by(Area, Year) %>%
  summarise(Total_Yield = sum(Value, na.rm = TRUE))

crop_data <- crop_data %>%
  left_join(total_yield, by = c("Area", "Year"))

crop_data$Country_Code <- countrycode(crop_data$Area, origin = "country.name", destination = "iso3c")


yield_geo <- geojson_read("countries.geo.json", what = "sp")

GEO_iso <- yield_geo
GEO_iso@data <- GEO_iso@data %>%
  left_join(crop_data, by = c("id" = "Country_Code"))


palette <- colorNumeric(palette = "YlGnBu", domain = crop_data$Total_Yield, na.color = "#f0f0f0")

yield_map <- leaflet(yield_geo) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~palette(Total_Yield),
    weight = 1,
    color = "white",
    fillOpacity = 0.5
    ) %>%
  addLegend(
    pal = palette,
    values = crop_data$Total_Yield,
    title = "Total Yield",
    position = "bottomright"
  )
    
filter_geo <- reactive({
  year_data <- total_yield %>%
    filter(Year == input$year)
  
  geo@data <- left_join(geo@data, year_data, by = c("name" = "Area"))
  geo
})

output$slider_map <- renderLeaflet({
  pal <- colorBin("YlGnBu", domain = total_yield$Total_Yield, na.color = "transparent")
  leaflet(filtered_geo()) %>%
    addTiles() %>%
    addPolygons(
      fillColor = ~pal(Total_Yield),
      color = "white",
      weight = 1,
      fillOpacity = 0.7)
})

#***Not sure where to go from here



#using our new long_dataframe with shiny function "plot_geo" for its world map

#orienting our mapping software by using 'Area' column for its country tags

#lapply is for checking to see the nature of each column in our dataset (is it character, numeric? etc)

#frame allows us to add a slider

#locations allows for hover over country with popup












#Mock Code for UI once chloropleth is finalized
# Crop_Heat_Map_ui <- fluidPage("Climate + Agriculture Research",
#                         navbarMenu("Crop Yield Cloropleth"),
#                              tabPanel("Historic Crop Yield Data by Country"),
#                              setBackgroundColor("floralwhite"),
#                              mainPanel(p("placeholder description of map")),
#                              leafletOutPut("MAPNAME", height = ("80vh")))


#crop_data <- readRDS("combined_countries_data.rds")


#geo_countries <- geojson_read("countries.geo.json", what = "sp")

#geo_countries_data <- left_join(geo_countries_data, crop_data, by = c("name" = "Country"))



#color_palet <- colorBin("YlOrRd", domain = crop_data$X1990)


#leaflet(geo_countries) %>%
  #addPolygons(fillColor = ~color_pal(X1990))

