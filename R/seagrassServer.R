seagrassServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    stationsSub <- reactive({
      dfx = seagrass_stations
      dfx[dfx[["Strata"]] %in% input$strata, ]
    })

    sitesSub <- reactive({
      dfx = seagrass_sites
      dfx[dfx[["StatKey"]] %in% unique(stationsSub()[["StatKey"]]), ]
    })

    speciesWide <- reactive({
      # taking the approach of pivoting wider to fill all sample dates
      req(input$param %in% c("BL_avg", "PerCov"), nrow(sitesSub()) > 0)
      seagrass_species |>
        select(all_of(c("SiteKey", "Species", input$param))) |>
        pivot_wider(names_from = "Species", values_from = input$param) |>
        mutate(
          Resp = ifelse(
            is.na(.data[[input$species]]),
            0,
            .data[[input$species]]
          )
        )
    })

    tsSumm <- reactive({
      out = NULL

      if (input$param == "Depth_m") {
        out = stationsSub() |>
          group_by(Strata, Year) |>
          summarise(Resp = mean(Depth_m, na.rm = TRUE)) |>
          mutate(
            Tooltip = paste0(
              "Year: ",
              Year,
              "<br>",
              "Depth: ",
              round(Resp, 2),
              " m<br>",
              "Strata: ",
              Strata
            )
          )
      }

      if (input$param %in% c("SAV_PerCov", "AAlgae_PerCov", "DAlgae_PerCov")) {
        out = sitesSub() |>
          left_join(
            select(stationsSub(), StatKey, Year, Strata),
            by = join_by(StatKey)
          ) |>
          group_by(Strata, Year) |>
          summarise(Resp = mean(.data[[input$param]], na.rm = TRUE)) |>
          mutate(
            Tooltip = paste0(
              "Year: ",
              Year,
              "<br>",
              "Cover: ",
              round(Resp, 2),
              "%<br>",
              "Strata: ",
              Strata
            )
          )
      }

      if (input$param %in% c("PerCov", "BL_avg")) {
        out = speciesWide() |>
          filter(SiteKey %in% unique(sitesSub()[["SiteKey"]])) |>
          left_join(
            select(sitesSub(), SiteKey, StatKey),
            by = join_by(SiteKey)
          ) |>
          left_join(
            select(stationsSub(), StatKey, Year, Strata),
            by = join_by(StatKey)
          ) |>
          group_by(Strata, Year) |>
          summarise(Resp = mean(Resp, na.rm = TRUE))

        if (input$param == "PerCov") {
          out = mutate(
            out,
            Tooltip = paste0(
              "Year: ",
              Year,
              "<br>",
              "Cover: ",
              round(Resp, 2),
              "%<br>",
              "Strata: ",
              Strata
            )
          )
        }

        if (input$param == "BL_avg") {
          out = mutate(
            out,
            Tooltip = paste0(
              "Year: ",
              Year,
              "<br>",
              "Blade Length: ",
              round(Resp, 2),
              "<br>",
              "Strata: ",
              Strata
            )
          )
        }
      }

      out
    })

    output$tsPlot <- renderPlotly({
      req(nrow(tsSumm()) > 0)

      y_lab = "Avg. Cover (%)"
      if (input$param == "BL_avg") {
        y_lab = "Avg. Blade Length"
      }
      if (input$param == "Depth_m") {
        y_lab = "Avg. Depth (m)"
      }

      p = ggplot(
        tsSumm(),
        aes(x = Year, y = Resp, col = Strata, group = Strata, text = Tooltip)
      ) +
        geom_line() +
        geom_point() +
        labs(y = y_lab) +
        scale_color_manual(values = strata_colors) +
        theme_minimal()

      ggplotly(p, tooltip = "text")
    })
  })
}
