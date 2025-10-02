rainfallUI <- function(id) {
  ns = NS(id)
  tagList(
    div(
      layout_columns(
        pickerInput(
          inputId = ns("months"),
          label = "Months",
          multiple = TRUE,
          choices = months,
          selected = months,
          options = pickerOptions(
            container = "body",
            actionsBox = TRUE,
            liveSearch = TRUE,
            size = 6,
            selectedTextFormat = "count > 4"
          )
        ),
        sliderInput(
          ns("year"),
          "Year",
          min = 1995,
          max = 2024,
          value = 1995,
          sep = "",
          step = 1,
          animate = TRUE
        ),
        col_widths = c(4, 8)
      )
    ),
    leafletOutput(ns("map"))
  )
}
