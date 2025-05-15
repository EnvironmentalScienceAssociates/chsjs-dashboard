
page_navbar(
  title = "Clearwater Harbor and Saint Joseph Sound",
  window_title = "CHSJS",
  id = "nav",
  nav_panel(
    title = "Background",
    layout_columns(
      col_widths = breakpoints(
        sm = c(-1, 10, -1),
        md = c(-2, 8, -2),
        lg = c(-3, 6, -3)
      ),
      includeMarkdown("static/background.md"),
    )
  ),
  # nav_panel(
  #   title = "R Markdown Example",
  #   layout_columns(
  #     col_widths = breakpoints(
  #       sm = c(-1, 10, -1),
  #       md = c(-2, 8, -2),
  #       lg = c(-3, 6, -3)
  #     ),
  #     HTML(file.path("static", "Example.Rmd") |>
  #            knitr::knit(quiet = TRUE) |> 
  #            markdown::markdownToHTML(fragment.only = TRUE))
  #   )
  # ),
  nav_panel(
    title = "Water Quality",
    waterQualityUI("wq")
  ),
  nav_panel(
    title = "Isotopes"
  ),
  nav_panel(
    title = "Groundwater"
  ),
  nav_panel(
    title = "Seagrass"
  ),
  nav_panel(
    title = "Events"
  ),
  nav_spacer(),
  nav_item(a("Source Code", href = "https://github.com/EnvironmentalScienceAssociates/chsjs-dashboard",
             target = "_blank")),
  nav_item(img(src="logo.jpg", alt="CHSJS logo", width = "60")),
)