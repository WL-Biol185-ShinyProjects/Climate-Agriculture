library(dplyr)
library(plotly)
library(htmlwidgets)
library(tidyr)
library(leaflet)
library(geojsonio)


#creates a "dataframe" for our csv

df <- read.csv("fully_temp_data_cleaned.csv")


#nifty way of making our long X1990-X2022 columns into 2 columns... 1 with values(temp change) and 1 column with the year

long_df <- df %>%
  pivot_longer(
    cols = 'X1990':'X2022',
    names_to = "Year",
    values_to = "Celcius"
    
  )


#using our new long_dataframe with shiny function "plot_geo" for its world map

#Then making the "relative color change" element dependent on new 'celcius' column

#orienting our mapping software by using 'ISO3' column for its country tags

#llapply is for checking to see the nature of each column in our dataset (is it character, numeric? etc)

#frame allows us to add a slider

#locations allows for hover over country with popup

lapply(long_df, class)


p <- plot_geo(long_df, locationmode = 'world') %>%
  add_trace(  z = ~long_df$Celcius, locations = long_df$ISO3, frame=~long_df$Year,
                color = ~long_df$Celcius)


p




