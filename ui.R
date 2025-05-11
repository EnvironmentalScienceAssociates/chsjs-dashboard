
page_navbar(
  title = "Clearwater Harbor and Saint Joseph Sound",
  window_title = "CHSJS",
  id = "nav",
  nav_panel(
    title = "Background",
    layout_columns(
      col_widths = c(3, 6, 3),
      p(),
      includeMarkdown("static/background.md"),
      p()
    )
  ),
  nav_panel(
    title = "R Markdown Example",
    layout_columns(
      col_widths = c(3, 6, 3),
      p(),
      HTML(file.path("static", "Example.Rmd") |>
             knitr::knit(quiet = TRUE) |> 
             markdown::markdownToHTML(fragment.only = TRUE)),
      p()
    )
  ),
  nav_panel(
    title = "Water Quality",
    layout_sidebar(
      sidebar = sidebar(
        id = "sidebar",
        width = 320,
        sliderTextInput(inputId = "date_range", label = "Date Range", choices = date_lab, 
                        selected = date_lab[date_seq %in% c(min_date, max_date)]),
        selectInput(inputId = 'level', label = 'Sample Level', 
                    choices = c("Surface", "Bottom")),
        conditionalPanel(condition = 'input.panel != "Tile Plot"',
                         selectInput(inputId = 'parameter', label = 'Parameter', choices = "NOx (mg/L)")),
        pickerInput(inputId = "sites", label = "Sites", multiple = TRUE, choices = NULL, 
                    options = list(`actions-box` = TRUE, size = 8)),
        conditionalPanel(condition = 'input.panel == "Bar Plot" | input.panel == "Tile Plot" | input.panel == "Map"',
                         selectInput(inputId = "stat", "Statistic", choices = c("Minimum", "Median", "Maximum"),
                                     selected = "Median")),
        downloadButton("downloadFilteredData", "Download Filtered Data"),
        downloadButton("downloadAllData", "Download All Data")
      ),
      navset_card_underline(
        id = "panel",
        title = "All data are provisional and subject to revision",
        nav_panel("Map", leafletOutput("map")),
        nav_panel("Time Series Plot", plotlyOutput("tsPlot")),
        nav_panel("Box Plot", plotlyOutput("boxPlot")),
        nav_panel("Bar Plot", plotlyOutput("barPlot")),
        nav_panel("Tile Plot", plotlyOutput("tilePlot")),
        nav_panel("Table", DT::dataTableOutput("table"))
      )
    )
  ),
  nav_spacer(),
  nav_item(a("Source Code", href = "https://github.com/EnvironmentalScienceAssociates/chsjs-dashboard",
             target = "_blank")),
  nav_item(img(src="logo.jpg", alt="CHSJS logo", width = "60")),
)