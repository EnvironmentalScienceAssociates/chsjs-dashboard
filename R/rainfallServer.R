
rainfallServer <- function(id, nav_page){
  moduleServer(id, function(input, output, session) {

    pal <- reactive({
      colorNumeric(palette = "Blues", domain = seq(15, 85, 10))
    })
    
    output$map <- renderLeaflet({
      basemap |> 
        setView(lat = 27.9, lng = -82.775, zoom = 10) |> 
        addLegend("bottomright", pal = pal(), values = seq(15, 85, 10),
                  title = "Annual<br>Rainfall (in.)")
    })
    
    observe({
      req(nav_page() == "Rainfall")
      
      leafletProxy("map")|>
        clearShapes()
      
      yr_chr = as.character(input$yr)
      map_data = left_join(pixel_basin_sf, rainfall[,c("pixel", yr_chr)],
                           by = join_by(pixel))
      
      map_data$label = paste(map_data[[yr_chr]], " in.")
    
      leafletProxy("map")|>
        addPolygons(data = map_data, 
                    weight = 0,
                    opacity = 0,
                    fillOpacity = 0.6,
                    label = ~label,
                    color = pal()(map_data[[yr_chr]]))
    })
    
  })
}
