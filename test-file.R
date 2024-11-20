library(leaflet)
library(geojsonio)
library(tidyverse)

data1 <- read.csv("fully_temp_data_cleaned.csv")


geo <- geojson_read("countries.geo.json", what = "sp")

geo@data <- left_join(geo@data, data1, by = c("name" = "Country"))



pal <- colorBin("YlOrRd", domain = data1$X1990)


leaflet(geo) %>%
  addPolygons(fillColor = ~pal(X1990))





