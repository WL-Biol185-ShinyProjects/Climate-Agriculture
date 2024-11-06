library(shiny)

# Define server logic required to draw a histogram
function(input, output) {
  
  #loading a test dataset
  data <- read.csv("fully_afgan_cambo_cleaned.csv")
  
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R 
    x  <-  data$Value 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
}