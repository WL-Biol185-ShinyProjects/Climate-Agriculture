library(shiny)
library(tidyverse)
library(plotly)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)
library(base)

#File Designations
countryfile <- "Countries_data_FailedStates_Islands/combined_countries_data.rds"
countrynames <- readRDS(countryfile)


#defining the UI

ui <- fluidPage(theme = shinytheme("cosmo"),
                
  navbarPage(
    
  #title of webpage
    "Climate Change's Effect on Agricultural Production", 
  
    
  #Intro panel
    tabPanel("Introduction",
             
             div(
               p( 
                "Welcome to this application! Our goal is to help you explore the impacts of climate change on agriculture across the world. Click on the tabs above to see how changes in the climate affects agriculture in different countries.",
                 style = "font-size: 30px; text-align: center; margin-bottom: 45px;"
                 )
             ),
             
              p(
                "We did not include small islands and the top ten failed states as they have other factors that could affect agriculture production other than climate change. We wanted to focus only on the effect of climate change on agriculture production.",
                style = "font-size: 20px; text-align: center; margin-bottom: 20px;"
              ),
             
              p(
                "Also, this application only takes into account temperature data and agriculture data from the years of 1990 through 2022.", 
                style = "font-size: 15px; text-align: center; margin-bottom: 45px;"
              ),
             
              leafletOutput("Intro_Map", width = "100%", height = "600px"),
             
             div(
               p(
                 "To get you started. The map above shows the total production (in tons) of the most produced crop in each country for the year 2022. Hover over a country to see detailed information, including the name of the crop and its production quantity!",
                 style = "font-size: 30px; text-align: center; margin-top: 35px;"
               )
             )
             
            ),
  
  
  #Heat Maps Panel
    tabPanel("Heat Maps", 
            
             sidebarPanel(
               radioButtons("heatmap_type", "Select Heatmap Type:", 
                              choices = list("Temperature Change" = "temp",
                                             "Crop Yield Change" = "yield")
                            ), 
                 
                checkboxInput("baseline_toggle", "Show values relative to baseline year (1990)")
                
              ), 
             
             
             
             
              mainPanel(
                 leafletOutput("heatmap", width = "100%", height = "600")
                        )
    ),
    
  
  
    #Efficiency Panel
    tabPanel("Farming Efficiency",
          
          sidebarLayout(   
             sidebarPanel(
              
               p(
                 "Select a country and product from their list of choices."
               ), 
               
              selectInput(
                inputId = "selectedCountry",
                label = "Countries",
                choices = c(unique(countrynames$Area)),
                selected = "Albania",
                ),
              
              hr(),
              
              helpText("Available Products for Selected Country"),
              selectInput(
                inputId = "selectedProduct",
                label = "Products",
                choices = NULL
                )
             ),
             
            mainPanel(
              
              p(
                "The plot below depicts the efficiency by which a given country produced a product over the time period 1990 to 2022 (in Kilograms per Hectare). Some products were not produced over that entire time range, and for those the x-axis is adjusted to show this."
              ), 
              
              plotOutput("EfficiencyvsTime", width = 500, height = 400)
            ),
               
          ),
             
    
  
    #Crop Data Panel
    tabPanel("Raw Data",
             
             
             
             )
    
  ), 
  
  #WORLD EVENTS AFFECT ON AGRICULTURE  
  
  tabPanel("World Events",
    titlePanel("Major World Events Effect on Agriculture"), 
    
    
    div(
      p( 
        "How do major events in a country affect the total agriculture production in various countries?",
        style = "font-size: 30px; text-align: center; margin-bottom: 30px;"
      )
    ),
    
    p(
      "In this tab, you can see the effects of seven different events. These events range from natural disasters, wars, uprisings, and epidemics. All of these events affect the country's infrastructure potentially leading to lower agriculture production",
      style = "font-size: 20px; text-align: center; margin-bottom: 30px;"
    ),
    
    p(
      "The seven events that we have focused on are: 
           The Great Flood of 1993 which is when the Mississippi River flooded and it affected major states in the United States, including North Dakota, south Dakota, Nebraska, Kansas, Missouri, Wisconsin, and Illinois. 
           The 1994 Rwandan Civil War which was the most intense conflict in Rwanda.
           The 2003 Iraq War which is when the United States invaded  Iraq.
           The 2004 Indian Ocean Tsunami, which decimated Indonesia
           The 2011 Arab Spring, which was a wave of pro-democracy protests and uprising that took place in the Middle East in North Africa (we are focusing on the agriculture production in Egypt)
           The 2014 Russia Annexation of Crimea which was when russia invaded the Crimean Peninsula
           The 2014 Ebola Outbreak in West Africa, where we will be focusing on the country most affected: Sierra Leone", 
      style = "font-size: 15px; text-align: left; margin-bottom: 45px;"
    ),
    
    
    sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = "World_Event",
          label = "Select a World Event",
          choices = c(
            "Great Flood of 1993 (Mississippi River)",
            "1994 Rwandan Genocide",
            "2003 Iraq War",
            "2004 Indian Ocean Tsunami",
            "2011 Arab Spring",
            "2014 Russia Annexation of Crimea",
            "2014 Ebola Outbreak in West Africa"
          ), 
          
          
          
          selected = "1994 Rwandan Genocide"
        )
      ),
      
      
      #displays scatterplot 
      mainPanel(
        plotOutput("Yield_Plot")
      )
    )
    
  )
  

)
)









