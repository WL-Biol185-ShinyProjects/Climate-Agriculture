library(shiny)
library(tidyverse)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(shinythemes)
library(base)
library(sf)

#File Designations
countryfile <- "Countries_data_FailedStates_Islands/combined_countries_data.rds"
countrynames <- readRDS(countryfile)


#Defining the UI

ui <- fluidPage(theme = shinytheme("cosmo"),
                
  navbarPage(
    
  #Title of Webpage
    "Climate Change's Effect on Agricultural Production", 
  
    
  #Introduction Panel
    tabPanel("Introduction",
            
             div(
               p( 
                "Welcome to our application! 2023 marked the warmest year on record since 1850.  If global yearly carbon emmissions continue to rise, it is predicted that by the end of this century global temperature will be 2.78 °C 
                above the 1901-1960 average. This trend has far reaching implications, particularly for agricultural economies. The changing climate has significant consequences for global food production distribution. This 
                app examines how climate change affects the agriculture sector by utilizing data on countries across the world. We defined climate change as the year-over-year change in mean annual surface temperature per country (°C). 
                Use the tabs above to discover how climate shifts influence agricultural systems in various countries. Additionally, dive into our tab on significant world events to gain a broader understanding on how other factors, 
                such as natural disasters and conflicts, also affect agricultural production. To avoid biasing the results, we exluded very small nations, small islands nations, the top failed states, and disputed territories, as these regions are inordinately influenced by additional 
                factors beyond climate change that highly skew agricultural production data. These countries are shown in black on the map, meaning they are not included in the analysis.",
                 style = "font-size: 20px; text-align: center; margin-bottom: 45px;"
                 )
             ),
             
              p(
                "IMPORTANT: this application only takes into account temperature data and agriculture data from the year 1990 to 2022.", 
                style = "font-size: 15px; text-align: center; margin-bottom: 45px;"
              ),
             
              leafletOutput("Intro_Map", width = "100%", height = "600px"),
             
             div(
               p(
                 "The map above provides an overview of global agricultural production, showing two key insights for each country in 2022: total yield and most popular crop. The shading represents the total agricultural production in tons - the darker the shade, the higher the production. 
                 For example, Brazil, the darkest shade, has the highest total agriculture production in 2022. Additionally, the map highlights the most produced crop in each country. Hover over a country to see its total production in tons and its most produced crop. 
                 To dive deeper into how climate change and significant world events affect agriculture, explore the other tabs.",
                 style = "font-size: 20px; text-align: center; margin-top: 45px;"
               )
              
             ),
             
             div(
               p(
                 "Countries Removed From Analysis",
                 style = "font-size: 30px; text-align: center; margin-top: 45px;"
               ),
               
               p(
                 "Failed States/Disputed Territories:",
                 style = "font-size: 23px; text-align: left; margin-top: 20px;"
               ),
               
               p(
                 "Afganistan, Chad, Central African Republic, Democratic Republic of the Congo, Kosovo, Sudan, South Sudan, Somalia, Somaliland, Syria, Yemen, Haiti, Western Sahara",
                 style = "font-size: 15px; text-align: left; margin-top: 15px;"
               ),
               
               p(
                 "Very Small Nations/Island Nations:",
                 style = "font-size: 23px; text-align: left; margin-top: 20px;"
               ),
             
              p(
                "Antigua and Barbuda, The Bahamas, Barbados, Cabo Verde, Cook Islands, Comoros, Dominica, Faroe Island, Fiji, French Polynesia, Grenada, Greenland, Guadeloupe, Jamaica, Marshall Islands, Martinique, Maldives, Mauritius, Malta, Nauru, New Caledonia, Niue, Puerto Rico, Reunion, Samoa, 
                Sao Tome and Principe, Seychelles, Saint Kitts and Nevis, Saint Lucia, Saint Vincent and the Grenadines, Tokelau, Trinidad and Tobago, Tuvalu, Vanuatu",
               style = "font-size: 15px; text-align: left; margin-bottom: 25px; margin-top: 15px;"
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
                
                ), 
             
             
              mainPanel(
                tabsetPanel(
                  tabPanel("Global Temperature Visualization",
                           
                      #temp map output     
                      leafletOutput("temperature_map", height = 300),
                      
                      #description of temp heat map for app
                      p(
                        "Using the year slider, this heat map explores how average annual temperatures
                        have changed globally. The map shows a country's temperature variance 
                       from its baseline temperature in 1960, making it easy to spot regions 
                        that have experienced significant warming or cooling trends. Paired with the crop yield heat map, 
                        this tool can help you uncover links between climate change and agricultural productivity. 
                        While rising temperatures caused by global warming may harm certain areas, others could see 
                        conditions that are more favorable for farming. This highlights the complex and often nuanced 
                        ways climate change impacts agriculture on a global scale."
                      ),
                           
                      # explanatory panel NOTE: look on stackoverflow for fix, ... wont show up
                      verbatimTextOutput("This")
                    ),
                  
                  tabPanel("Global Crop Visualization",
                      
                      #yield map output
                      leafletOutput("yield_map", height = 300),
                      
                  #description of yield heat map for app
                  p(
                    "Using the year slider, this heat map visualizes how each country's total yield
                    changes by percent increase or decrease with respect to the country's total yield in 1990.
                    This map is designed as a counterpart to the temperature change heat map under this
                    tab. We hope that the user can find a relationship between temperature change and 
                    change in total crop yield. The relationship between temp. and yield is not a strictly 
                    1 to 1 linear correlation because 
                    temperature changes affect different crops in different ways, but there is correlation
                    between temperature and crop yield across the world. NOTE: Djibouti was
                    removed from this dataset because it was an outlier in positive yield growth."
                  )
                    ),
                ),
              )
            )
    ),
    
  
  
    #Efficiency Panel
    tabPanel("Farming Efficiency",
         
        titlePanel("This tab shows various graphs surrounding the products and their efficiency in production"),
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
                #Line Plot Panel
                tabPanel("Efficiency Vs Product Graph",

              p("The plot below depicts the efficiency by which a given country produced a product over the time period 1990 to 2022 (in Kilograms per Hectare). Some products were not produced over that entire time range, and for those the x-axis is adjusted to show this.",
                style = "font-size: 20px; text-align: left; margin-botton: 20px; margin-top:10px;"
              ),

              plotOutput("EfficiencyvsTime", width = 1000, height = 600),

              p("It is apparent that some crops have decreased in production over the time period, which could be due to climate, geopolitical, or financial factors.",
                style = "font-size: 20px; text-align: center; margin-botton: 20px; margin-top: 10px;"
                ),

                ),

                #Diverging Bar Graph Panel
                tabPanel("Percent Variation in Production",
                         
              p("Pick a country and a year to see how that country's production of its agriculture changed as a percent from 1990.",
                style = "font-size: 20px; text-align: left; margin-bottom: 10px; margin-top: 10px;"
                ),
              
              hr(),
              
              sliderInput("Years", "Years of Production:",
                min = 1990,
                max = 2022,
                value = 1991,
                sep = ""
                        ),
              hr(),

              plotOutput("PercentChangevsProduct", width = 1200, height = 800),
                )
            )

          )

        )

    ),

  #World Events Tab

  tabPanel("World Events",
    titlePanel("How do Major Events in a Country Affect the Agriculture Production for that Country?"),


    div(

      p(
        "In this tab, we explore the impact of significant world events on agricultural production to provide a different perspective on factors influencing agriculture other than climate change. While climate change is an important issue for agriculture, other events - such as natural disasters, wars, political uprisings, and epidemics also play important roles. These events can affect infrastructure and hinder the production of crops. It is important to note that these charts are in the context of one country. Also, focus on the year of the event and the year following the event.",
        style = "font-size: 20px; text-align: center; margin-bottom: 45px; margin-top: 45px;"
      )
    ),


    #The events the user can choose from 
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

        
        #description of the events 
        p(
          "The Seven Events Explored",
          style = "font-size: 20px; text-align: center; margin-bottom: 30px;"
        ),

        p(
          "1. The Great Flood of 1993: The Mississippi River flooded and it affected numerous states in the USA, including North Dakota, South Dakota, Nebraska, Kansas, Missouri, Wisconsin, and Illinois.",
          style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
        ),

        p(
          "2. The Rwandan Civil War (1994): A violent conflict in Rwanda that resulted in the loss of over 800,000 lives within approximately 100 days.",
          style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
        ),

        p(
          "3. The Iraq War (2003): The United States invaded Iraq to overthrow Saddam Hussein's regime, leading to prolonged violence.",
          style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
        ),

        p(
          "4. The Indian Ocean Tsunami (2004): A massive undersea earthquake, causing widespread destruction and loss of life across several countries in Southeast Asia, especially Indonesia.",
          style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
        ),

        p(
          "5. Arab Spring (2011): A series of pro-democracy uprisings and protests across the Middle East and North Africa (we are focusing on the impact of agricultural production in Egypt).",
          style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
        ),

        p(
          "6. The Russia Annexation of Crimea (2014): A controversial takeover in which Russia seized control of the Crimean Peninsula from Ukraine.",
          style = "font-size: 15px; text-align: left; margin-bottom: 20px;"
        ),

        p(
          "7. The Ebola Outbreak in West Africa (2014): A severe public health crisis that highlighted the need for global health preparedness.",
          style = "font-size: 15px; text-align: left;"
        )

          )
        )

      )

  )
)