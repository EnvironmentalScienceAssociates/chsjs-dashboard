
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
                           by = join_by(pixel)) |> 
        mutate(fill_color = pal()(.data[[yr_chr]]),
               label = paste(.data[[yr_chr]], " in."))
      
      leafletProxy("map")|>
        leafgl::addGlPolygons(data = map_data, 
                              fillColor = map_data$fill_color,
                              fillOpacity = 0.6,
                              popup = map_data$label)
    })
    
  })
}
