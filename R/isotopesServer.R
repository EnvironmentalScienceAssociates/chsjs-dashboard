isotopesServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlotly({
      plot_ly(
        isotopes,
        x = ~`Delta 15N (‰)`,
        y = ~`Delta 18O (‰)`,
        type = 'scatter',
        mode = 'markers',
        text = ~Tooltip,
        marker = list(color = "black"),
        hoverinfo = 'text'
      ) |>
        layout(
          shapes = list(
            list(
              type = "rect",
              x0 = 5,
              x1 = 25,
              y0 = -4,
              y1 = 10,
              fillcolor = "lightgreen",
              opacity = 0.2,
              line = list(color = "green")
            ),
            list(
              type = "rect",
              x0 = -4,
              x1 = 4,
              y0 = -4,
              y1 = 10,
              fillcolor = "pink",
              opacity = 0.2,
              line = list(color = "red")
            ),
            list(
              type = "rect",
              x0 = -2.5,
              x1 = 4,
              y0 = 14,
              y1 = 26,
              fillcolor = "lightblue",
              opacity = 0.2,
              line = list(color = "blue")
            )
          ),
          annotations = list(
            list(
              x = 20,
              y = 7,
              text = "Manure/Wastewater",
              showarrow = FALSE,
              font = list(color = "green", size = 12)
            ),
            list(
              x = 0,
              y = 7,
              text = "Ammonia Fertilizer",
              showarrow = FALSE,
              font = list(color = "red", size = 12)
            ),
            list(
              x = 0,
              y = 27,
              text = "Nitrate Fertilizer",
              showarrow = FALSE,
              font = list(color = "blue", size = 12)
            )
          ),
          title = "2024 CHSJS Isotopes",
          xaxis = list(title = "Delta 15N (‰)", range = c(-5, 40)),
          yaxis = list(title = "Delta 18O (‰)", range = c(-5, 30)),
          showlegend = FALSE
        )
    })
  })
}
