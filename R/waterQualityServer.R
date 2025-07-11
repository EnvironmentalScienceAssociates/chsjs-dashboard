
waterQualityServer <- function(id, nav_page){
  moduleServer(id, function(input, output, session) {
    
    statFN <- reactive({
      fn = c("Minimum" = min, "Median" = median,
             "Mean" = mean, "Maximum" = max)
      fn[[input$stat]]
    })
    
    # Reactive Values ---------------------------------------------------------
    
    rv <- reactiveValues(last_param = NULL)
    
    # Filter ------------------------------------------------------------------

    datSub1 <- reactive({
      filter(wq, Level == input$level & Date >= input$date_range[1] & Date <= input$date_range[2])
    })
    
    observe({
      req(datSub1())
      params = sort(unique(datSub1()$Parameter))
      
      if (is.null(rv$last_param) || input$parameter != rv$last_param) rv$last_param = input$parameter
      sel = if (rv$last_param %in% params) rv$last_param else params[1]
      updateSelectInput(session, 'parameter', choices = params, selected = sel)
      
      sites = sort(unique(datSub1()$Site))
      freezeReactiveValue(input, "sites")
      updatePickerInput(session, "sites", choices = sites, selected = sites)
    })
    
    datSub2 <- reactive({
      filter(datSub1(), Site %in% input$sites)
    })
    
    datSub3 <- reactive({
      filter(datSub2(), Parameter == input$parameter)
    })
    
    # Time Series Plot --------------------------------------------------------
    
    output$tsPlot <- renderPlotly({
      req(datSub3(), nrow(datSub3()) > 0)
      p = ggplot(datSub3(), aes(x = Date, y = Value, color = Site)) + 
        geom_point() +
        geom_line(alpha = 0.6) +
        labs(x = "", y = input$parameter) +
        theme_bw()
      
      ggplotly(p)
    })
    
    # Box Plot ----------------------------------------------------------------
    
    output$boxPlot <- renderPlotly({
      req(datSub3(), nrow(datSub3()) > 0)
      p = ggplot(datSub3(), aes(x = Site, y = Value)) + 
        geom_boxplot(alpha = 0.3, fill = blue_light) +
        labs(y = input$parameter) +
        scale_x_discrete(limits = rev) +
        coord_flip() +
        theme_bw()
      
      ggplotly(p)
    })
    
    # Bar Plot ----------------------------------------------------------------
    
    barSumm <- reactive({
      req(datSub3(), nrow(datSub3()) > 0)
      datSub3() |> 
        group_by(Site) |> 
        summarise(Value = statFN()(Value, na.rm = TRUE))
    })
    
    output$barPlot <- renderPlotly({
      p = ggplot(barSumm(), aes(y = Site, x = Value)) +
        geom_col(fill = blue_light) +
        scale_y_discrete(limits = rev) +
        labs(x = input$parameter) +
        theme_bw() 
      
      ggplotly(p)
    })
    
    # Tile Plot ---------------------------------------------------------------
    
    tileSumm <- reactive({
      req(datSub2(), nrow(datSub2()) > 0)
      datSub2() |> 
        group_by(Site, Parameter) |> 
        summarise(Value = statFN()(Value, na.rm = TRUE)) |> 
        group_by(Parameter) |> 
        mutate(Percentile = percentile(Value))
    })
    
    output$tilePlot <- renderPlotly({
      p = ggplot(tileSumm(), aes(y = Site, x = Parameter, fill = Percentile, label = Value)) +
        geom_tile() +
        scale_y_discrete(limits = rev) +
        scale_fill_gradient2(mid = "#f7f7f7", low = scales::muted(blue_dark), high = scales::muted("red"), midpoint = 50) +
        labs(x = "",) +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 0.5))
      
      ggplotly(p)
    })
    
    # Map ---------------------------------------------------------------------
    
    mapData <- reactive({
      req(datSub3(), nrow(datSub3()) > 0)
      datSub3() |> 
        group_by(Site, Parameter) |> 
        summarise(Value = statFN()(Value, na.rm = TRUE)) |>
        mutate(Popup = paste(Parameter, "<br>", Value)) |> 
        left_join(site_locs, by = join_by(Site))
    })
    
    output$map <- renderLeaflet({
      basemap |> 
        setView(lat = 28.03, lng = -82.775, zoom = 11)
    })
    
    myPalette <- reactive({
      colorNumeric(palette = "Spectral", domain = mapData()$Value, reverse = TRUE)
    })
    
    observe({
      req(nav_page() == "Water Quality")
      leafletProxy("map")|>
        clearShapes() |>
        clearMarkers() |>
        clearControls()
      
      leafletProxy("map")|>
        add_circles(data = mapData(), 
                    lng = ~Lon, 
                    lat = ~Lat, 
                    label = ~Site, 
                    popup = ~Popup,
                    fillColor = ~myPalette()(Value)) |> 
        addLegend("bottomright", pal = myPalette(), values = mapData()$Value, 
                  title = paste(input$stat, "<br>", input$parameter))
    })
    
    # Table/Download -------------------------------------------------------------------
    
    tableDownload <- reactive({
      req(datSub3(), nrow(datSub3()) > 0)
      mutate(datSub3(), Date = as.character(Date))
    })
    
    output$table <- DT::renderDataTable({
      tableDownload()
    }, options = list(searching = TRUE, bPaginate = TRUE, info = TRUE, scrollX = TRUE))
    
    output$downloadFilteredData <- downloadHandler(
      filename = function() {
        paste0("CHSJS-FilteredData-", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(tableDownload(), file, row.names = FALSE)
      }
    )
    
    output$downloadAllData <- downloadHandler(
      filename = function() {
        paste0("CHSJS-AllData-", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(mutate(wq, Date = as.character(Date)), file, row.names = FALSE)
      }
    )
    
  })
}
