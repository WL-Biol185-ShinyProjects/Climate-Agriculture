#Crop Heat Maps

install.packages("countrycode")


library(dplyr)
library(plotly)
library(htmlwidgets)
library(tidyr)
library(leaflet)
library(geojsonio)

library(countrycode)



#creates a "crop_data" file from the rds

crop_data <- readRDS("efficiency_data /combined_efficiency_data.rds")

ISO <- read.csv("fully_temp_data_cleaned.csv")


total_yield <- crop_data %>% 
  group_by(Area, Year) %>%
  summarise(Total_Yield = sum(Value, na.rm = TRUE))

crop_data <- crop_data %>%
  left_join(total_yield, by = c("Area", "Year"))

crop_data$Country_Code <- countrycode(crop_data$Area, origin = "country.name", destination = "iso3c")

  




#using our new long_dataframe with shiny function "plot_geo" for its world map

#orienting our mapping software by using 'Area' column for its country tags

#lapply is for checking to see the nature of each column in our dataset (is it character, numeric? etc)

#frame allows us to add a slider

#locations allows for hover over country with popup

lapply(crop_data, class)


yield_map <- plot_geo(crop_data, locationmode = 'iso_a3') %>%
  add_trace(  z          = ~Total_Yield, 
              locations  = ~Country_Code, 
              frame      = ~Year,
              color      = ~Total_Yield
              )


yield_map











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

