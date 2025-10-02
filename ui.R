page_navbar(
  title = "Clearwater Harbor & St. Joseph Sound",
  window_title = "CHSJS",
  id = "nav_page",
  navbar_options = navbar_options(bg = blue_dark),
  theme = bs_theme(
    primary = blue_light,
    secondary = blue_dark
  ) |>
    bs_add_rules(list(paste0("h", 1:5, " { color: ", blue_dark, "; }"))),
  nav_panel(
    title = "About",
    layout_columns_custom(
      includeMarkdown("markdown/about.md")
    )
  ),
  nav_panel(
    title = "Water Quality",
    waterQualityUI("wq")
  ),
  nav_panel(
    title = "Isotopes",
    layout_columns_custom(isotopesUI("iso"))
  ),
  nav_panel(
    title = "Rainfall",
    layout_columns_custom(rainfallUI("rain"))
  ),
  nav_panel(
    title = "Seagrass",
    layout_columns_custom(seagrassUI("sg"))
  ),
  nav_spacer(),
  nav_item(a(
    icon("github"),
    href = "https://github.com/EnvironmentalScienceAssociates/chsjs-dashboard",
    target = "_blank",
    title = "Source Code"
  ))
)
