#Introduction Page

library(tidyverse)
library(shiny)
library(shinyjs)
library(ggplot2)
library(shinyWidgets)
library(leaflet)


navbarPage("Climate Change's Effect on Agricultural Production",
           
           
           # Introduction Tab 
           
           tabPanal("Introduction",
                    h3("Climate Change's Impact on Agriculture across different countries."),
                    p("Explore how climate change affects agricultural production across different countries."),
                    leafletOutput("Introduction_Map", height = "800px"),
                    p("Hover over to view the country name, its popular crop, and its agriculture contribution to GDP")
           
           )
