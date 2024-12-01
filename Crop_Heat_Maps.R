#Crop Heat Maps
library(dplyr)
library(plotly)
library(htmlwidgets)
library(tidyr)
library(leaflet)
library(geojsonio)


#creates a "crop_data" file from the rds

crop_data <- readRDS("efficiency_data /combined_efficiency_data.rds")




#using our new long_dataframe with shiny function "plot_geo" for its world map

#orienting our mapping software by using 'Area' column for its country tags

#lapply is for checking to see the nature of each column in our dataset (is it character, numeric? etc)

#frame allows us to add a slider

#locations allows for hover over country with popup

lapply(crop_data, class)


yield_map <- plot_geo(crop_data, locationmode = 'world') %>%
  add_trace(  x = ~crop_data$Value, locations = crop_data$Area, frame=~crop_data$Year,
              color = ~crop_data$Value)


yield_map


# #Mock Code for UI once chloropleth is finalized
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

