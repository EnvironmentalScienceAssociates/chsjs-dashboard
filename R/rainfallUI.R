
rainfallUI <- function(id){
  ns = NS(id)
  tagList(
    sliderInput(ns("yr"), "Year", min = 1995, max = 2024, value = 1995, 
                sep = "", step = 1, animate = TRUE),
    leafletOutput(ns("map"))
  )
}
