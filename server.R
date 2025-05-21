function(input, output, session) {
  
  nav_page <- reactive({ input$nav_page })
  
  waterQualityServer("wq", nav_page)
  
  isotopesServer("iso")
  
  rainfallServer("rain", nav_page)
  
}