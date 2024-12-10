library(shiny)
library(tidyverse)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)
library(base)
library(lubridate)
library(sf)

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
                "We did not include small islands and the top ten failed states as they have other factors that could affect agriculture production other than climate change. We wanted to focus only on the effect of climate change on agriculture production (countries in black are not included in the dataset).",
                style = "font-size: 20px; text-align: center; margin-bottom: 20px;"
              ),
             
              p(
                "IMPORTANT: this application only takes into account temperature data and agriculture data from the years of 1990 through 2022.", 
                style = "font-size: 15px; text-align: center; margin-bottom: 45px;"
              ),
             
              leafletOutput("Intro_Map", width = "100%", height = "600px"),
             
             div(
               p(
                 "To get you started. The map above shows the total production (in tons) of the most produced crop in each country for the year 2022. Hover over a country to see detailed information, including the name of the most popular crop and its total production quantity across all agriculture products!",
                 style = "font-size: 30px; text-align: center; margin-bottom: 35px;"
               ),
               
               p(
                 "The darker the shade over a country the more agricultural products they produced. As you can tell, Brazil is the darkest shade, meaning they have produced the most total agricultural products",
                 style = "font-size: 20px; text-align: center; margin-top: 15px;"
               )
             )
             
            ),
  
  
  #Heat Maps Panel
    tabPanel("Heat Maps", 
           
          titlePanel("This page details heat maps for both crop production and temperature change across our selected countries"),
             sidebarLayout(
                sidebarPanel(
                  # Create the slider for year
                  sliderInput("selected_year", 
                              "Select Year:",  min = 1990, max = 2020, 
                              value = 2000,
                              step = 1,
                              sep = ""),
                
                  # Cool feature that allows us to change up color scheme for our data
                  selectInput("color_palette", 
                              "Color Palette:", 
                              choices = c("Viridis" = "viridis", 
                                          "Magma" = "magma", 
                                          "Inferno" = "inferno"),
                              selected = "viridis"),
                 
                  checkboxInput("baseline_toggle", "Show values relative to baseline year (1990)")
                
                ), 
             
             
              mainPanel(
                tabsetPanel(
                  tabPanel("Global Temperature Visualization",
                           
                      #map output     
                      leafletOutput("temperature_map", height = 600),
                           
                      # explanatory panel NOTE: look on stackoverflow for fix, ... wont show up
                      verbatimTextOutput("This")
                    ),
                  
                  tabPanel("Global Crop Visualization",
                      
                      #Cambell map output
                      
                      
                    )
                ),
              )
             )
    ),
    
  
  
    #Efficiency Panel
    tabPanel("Farming Efficiency",
         
        titlePanel("This tab shows various graphs surrounding the products and their efficiency"),
          sidebarLayout(   
             sidebarPanel(
              
               p(
                 "Select a country and product from their list of choices."
               ), 
               
              selectInput(
                inputId = "selectedCountry",
                label = "Countries",
                choices = c(unique(countrynames$Area)),
                selected = "Albania"
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
              
              tabsetPanel(
                tabPanel("Efficiency Vs Product Graph",
              
              p("The plot below depicts the efficiency by which a given country produced a product over the time period 1990 to 2022 (in Kilograms per Hectare). Some products were not produced over that entire time range, and for those the x-axis is adjusted to show this.",
                style = "font-size: 20px; text-align: center; margin-botton: 20px;"
              ), 
              
              plotOutput("EfficiencyvsTime", width = 1600, height = 800),
              
              p("It is apparent that some crops have decreased in production over the time period, which could be due to climate, geopolitical, or financial considerations.",
                style = "font-size: 15px; text-align: center; margin-botton: 15px:"
              ),
              
                ),
                tabPanel("Percent Variation in Production",
                  
              sliderInput("Years", "Years of Production:",
                min = 1990,
                max = 2022,
                value = 1991,
                sep = ""
                        ),
              hr(),
                
              plotOutput("PercentChangevsProduct", width = 2000, height = 800),
                )
            )
               
          )
             
        )
      
    ),
  
  #WORLD EVENTS AFFECT ON AGRICULTURE  
  
  tabPanel("World Events",
    titlePanel("How do Major Events in a Country Affect the Agriculture Production for that Country?"), 
    
    
    div(
    
      p(
        "In this tab, you can see the effects of different world events on agriculture production. These events range from natural disasters, wars, uprisings, and epidemics. All of these events affect the country's infrastructure potentially leading to lower agriculture production.",
        style = "font-size: 20px; text-align: center; margin-bottom: 45px; margin-top: 30px;"
      )
    ),
    
    
    sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = "World_Event",
          label = "Select a World Event",
          choices = c(
            "Great Flood of 1993 (Mississippi River)",
            "The Rwandan Civil War (1994)",
            "The Iraq War (2003)",
            "The Indian Ocean Tsunami (2004)",
            "Arab Spring (2011)",
            "Russia Annexation of Crimea (2014)",
            "Ebola Outbreak in West Africa (2014)"
          ), 
          
          
          selected = "1994 Rwandan Civil War"
        )
      ),
      
      
      #displays scatterplot 
      mainPanel(
        plotOutput("Yield_Plot", height = "600px"),
        
        p(
          "The seven events that we focused on:",
          style = "font-size: 25px; text-align: left; margin-bottom: 30px;"
        ),
        
        p(
          "1. The Great Flood of 1993 (Mississippi River).",
          style = "font-size: 20px; text-align: left; margin-bottom: 20px;"
        ),
        
        p(
          "2. The Rwandan Civil War (1994).",
          style = "font-size: 20px; text-align: left; margin-bottom: 20px;"
        ),
        
        p(
          "3. The Iraq War (2003)",
          style = "font-size: 20px; text-align: left; margin-bottom: 20px;"
        ),
        
        p(
          "4. The Indian Ocean Tsunami (2004)",
          style = "font-size: 20px; text-align: left; margin-bottom: 20px;"
        ),     
        
        p(
          "5. Arab Spring (2011)",
          style = "font-size: 20px; text-align: left; margin-bottom: 20px;"
        ), 
        
        p(
          "6. The Russia Annexation of Crimea (2014)",
          style = "font-size: 20px; text-align: left; margin-bottom: 20px;"
        ),       
        
        p(
          "7. The Ebola Outbreak in West Africa (2014)",
          style = "font-size: 20px; text-align: left; margin-bottom: 40px;"
        ),     
        
        
        div(
          #severe public health crisis that claimed over 11,000 lives, primarily in Guinea, Liberia, and Sierra Leone, and highlighted the need for global health preparedness.
          p(
            "Event Descriptions",
            style = "font-size: 20px; text-align: left; margin-top: 30px;"
          )
        ), 
        
        p(
          "1. The Great Flood of 1993: The Mississippi River flooded and it affected numerous states in the USA, including North Dakota, South Dakota, Nebraska, Kansas, Missouri, Wisconsin, and Illinois.",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        ),
        
        p(
          "2. The Rwandan Civil War (1994): A violent conflict in Rwanda that resulted in the loss of over 800,000 lives within approximately 100 days.",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        ),
        
        p(
          "3. The Iraq War (2003): The United States invaded Iraq to overthrow Saddam Hussein's regime, leading to prolonged violence.",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        ),
        
        p(
          "4 The Indian Ocean Tsunami (2004): A massive undersea earthquake, causing widespread destruction and loss of life across several countries in Southeast Asia, especially Indonesia.",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        ),
        
        p(
          "5. Arab Spring (2011): A series of pro-democracy uprisings and protests across the Middle East and North Africa (we are focusing on the impact of agricultural production in Egypt).",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        ), 
        
        p(
          "6. The Russia Annexation of Crimea (2014): A controversial takeover in which Russia seized control of the Crimean Peninsula from Ukraine.",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        ),  
        
        p(
          "7. The Ebola Outbreak in West Africa (2014): A severe public health crisis that highlighted the need for global health preparedness.",
          style = "font-size: 10px; text-align: left; margin-bottom: 10px;"
        )    
        
          )
        )
    
      )
  
  )
)