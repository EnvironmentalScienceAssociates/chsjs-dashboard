
seagrassUI <- function(id){
  ns = NS(id)
  div(
    layout_columns(
      col_widths = c(4, 4, 4),
      checkboxGroupInput(inputId = ns("strata"), label = "Strata", inline = TRUE,
                         choices = strata_sg, selected = strata_sg),
      selectInput(inputId = ns("param"), label = "Parameter", 
                  choices = params_sg, selected = "PerCov"),
      conditionalPanel(
        condition = 'input.param == "PerCov" | input.param == "BL_avg"',
        selectInput(inputId = ns("species"), label = "Species", choices = species_sg),
        ns = NS(id)
      )
    ),
    plotlyOutput(ns("tsPlot"), height = "500px")
  )
}
