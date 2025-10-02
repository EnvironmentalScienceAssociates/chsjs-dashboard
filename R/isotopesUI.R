isotopesUI <- function(id) {
  ns = NS(id)
  tagList(
    plotlyOutput(ns("plot")),
    helpText(
      "Note: The bounding boxes represent potential sources of nitrate (Canion et al. 2020)."
    )
  )
}
