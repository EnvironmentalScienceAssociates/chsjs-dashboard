
waterQualityUI <- function(id){
  ns = NS(id)
  layout_sidebar(
    sidebar = sidebar(
      id = "sidebar",
      width = 320,
      sliderTextInput(inputId = ns("date_range"), label = "Date Range", choices = date_lab, 
                      selected = date_lab[date_seq %in% c(min_date, max_date)]),
      selectInput(inputId = ns('level'), label = 'Sample Level', 
                  choices = c("Surface", "Bottom")),
      conditionalPanel(condition = 'input.panel != "Tile Plot"',
                       selectInput(inputId = ns('parameter'), label = 'Parameter', choices = "NOx (mg/L)"),
                       ns = NS(id)),
      pickerInput(inputId = ns("sites"), label = "Sites", multiple = TRUE, choices = NULL, 
                  options = list(`actions-box` = TRUE, size = 8, `live-search` = TRUE,
                                 `selected-text-format` = "count > 4")),
      conditionalPanel(condition = 'input.panel == "Bar Plot" | input.panel == "Tile Plot" | input.panel == "Map"',
                       selectInput(inputId = ns("stat"), "Statistic", choices = c("Minimum", "Median", "Maximum"),
                                   selected = "Median"),
                       ns = NS(id)),
      downloadButton(ns("downloadFilteredData"), "Download Filtered Data"),
      downloadButton(ns("downloadAllData"), "Download All Data")
    ),
    navset_card_underline(
      id = ns("panel"),
      nav_panel("Map", leafletOutput(ns("map"))),
      nav_panel("Box Plot", plotlyOutput(ns("boxPlot"))),
      nav_panel("Bar Plot", plotlyOutput(ns("barPlot"))),
      nav_panel("Tile Plot", plotlyOutput(ns("tilePlot"))),
      nav_panel("Time Series Plot", plotlyOutput(ns("tsPlot"))),
      nav_panel("Table", DT::dataTableOutput(ns("table")))
    )
  )
}
