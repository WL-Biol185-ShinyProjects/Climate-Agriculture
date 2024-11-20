#Crop Heat Maps

library(tidyverse)
library(shiny)
library(leaflet)
library(geojsonio)
library(dplyr)


# #Mock Code for UI once chloropleth is finalized
# Crop_Heat_Map_ui <- fluidPage("Climate + Agriculture Research",
#                         navbarMenu("Crop Yield Cloropleth"),
#                              tabPanel("Historic Crop Yield Data by Country"),
#                              setBackgroundColor("floralwhite"),
#                              mainPanel(p("placeholder description of map")),
#                              leafletOutPut("MAPNAME", height = ("80vh")))


crop_data <- readRDS("combined_countries_data.rds")


geo_countries <- geojson_read("countries.geo.json", what = "sp")

geo_countries_data <- left_join(geo_countries_data, crop_data, by = c("name" = "Country"))



color_palet <- colorBin("YlOrRd", domain = crop_data$X1990)


leaflet(geo_countries) %>%
  addPolygons(fillColor = ~color_pal(X1990))

