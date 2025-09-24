
waterQualityUI <- function(id){
  ns = NS(id)
  layout_sidebar(
    sidebar = sidebar(
      id = "sidebar",
      width = 320,
      dateRangeInput(inputId = ns("date_range"), label = "Date Range", 
                     start = min_date_wq, end = max_date_wq, 
                     min = min_date_wq, max = max_date_wq),
      pickerInput(inputId = ns("elements"), label = "Elements", multiple = TRUE,
                  choices = elements, selected = elements, 
                  options = pickerOptions(actionsBox = TRUE, selectedTextFormat = "count > 3")),
      selectInput(inputId = ns('level'), label = 'Sample Level', 
                  choices = c("Surface", "Bottom")),
      conditionalPanel(condition = 'input.panel != "Tile Plot" && input.panel != "Scatter Plot"',
                       selectInput(inputId = ns('parameter'), label = 'Parameter', choices = "NOx (mg/L)"),
                       ns = NS(id)),
      conditionalPanel(condition = 'input.panel == "Scatter Plot"',
                       selectInput(inputId = ns('scatter_x'), label = 'X Variable', choices = NULL),
                       selectInput(inputId = ns('scatter_y'), label = 'Y Variable', choices = NULL),
                       ns = NS(id)),
      # sites dropdown doesn't depend on selected parameters (and vice versa)
      pickerInput(inputId = ns("sites"), label = "Sites", multiple = TRUE, choices = NULL, 
                  options = pickerOptions(size = 5, liveSearch = TRUE, selectedTextFormat = "count > 4")),
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
      nav_panel("Scatter Plot", plotlyOutput(ns("scatterPlot"))),
      nav_panel("Table", DT::dataTableOutput(ns("table")))
    )
  )
}
