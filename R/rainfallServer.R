rainfallServer <- function(id, nav_page) {
  moduleServer(id, function(input, output, session) {
    rainfallDomain <- reactive({
      req(input$months)
      # define palette across all years
      dfx = rainfall_monthly |>
        filter(month %in% input$months) |>
        group_by(year, pixel) |>
        summarise(value = sum(value, na.rm = TRUE))
      dfx[["value"]]
    })

    rainfallPal <- reactive({
      colorNumeric(palette = "PuOr", domain = rainfallDomain())
    })

    rainfall <- reactive({
      req(input$months)

      dfx = rainfall_monthly |>
        filter(
          year == input$year &
            month %in% input$months
        ) |>
        group_by(pixel) |>
        summarise(value = sum(value, na.rm = TRUE))

      left_join(pixel_chsjs_sf, dfx, by = join_by(PIXEL == pixel)) |>
        filter(!is.na(value)) |>
        mutate(
          fill_color = rainfallPal()(.data[["value"]]),
          label = paste(
            "Pixel:",
            PIXEL,
            "<br>",
            "Rainfall:",
            .data[["value"]],
            " in."
          )
        )
    })

    output$map <- renderLeaflet({
      basemap |>
        setView(lat = 28, lng = -82.775, zoom = 10)
    })

    proxy <- leafletProxy("map")

    observe({
      req(nav_page() == "Rainfall")

      proxy |>
        leafgl::clearGlLayers()

      if (nrow(rainfall()) > 0) {
        proxy |>
          leafgl::addGlPolygons(
            data = rainfall(),
            fillColor = rainfall()$fill_color,
            fillOpacity = 0.7,
            popup = rainfall()$label
          )
      }
    })

    observe({
      req(nav_page() == "Rainfall")

      proxy |>
        removeControl("rainfall")

      if (nrow(rainfall()) > 0) {
        proxy |>
          addLegend(
            "bottomleft",
            pal = rainfallPal(),
            values = rainfallDomain(),
            title = "Rainfall (in.)",
            layerId = "rainfall"
          )
      }
    })
  })
}
