options(dplyr.summarise.inform = FALSE)
library(shinyWidgets)
library(shiny) 
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(leaflet)
library(leaflegend)
library(plotly)
library(bslib)
library(sf)
library(markdown)

percentile <- function(x){
  rank_x = rank(x)
  rank_x/max(rank_x) * 100
}

isotopes = readRDS(file.path("data", "isotopes.rds")) |> 
  mutate(Tooltip = paste0("Date: ", Date, "<br>",
                          "Site: ", Site, "<br>",
                          "Delta 15N: ", `Delta 15N (‰)`, "‰<br>",
                          "Delta 18O: ", `Delta 18O (‰)`, "‰"))
wq_raw = readRDS(url("https://github.com/mkwessel/CHSJS/raw/main/CHSJS_WQ_Data.rds"))

site_locs = wq_raw |> 
  select(Site, Lat, Lon) |> 
  distinct()

wq = wq_raw |> 
  mutate(Parameter_Units = ifelse(is.na(Units), Parameter, paste0(Parameter, " (", Units, ")"))) |> 
  select(Date, Level, Parameter = Parameter_Units, Site, Value = Result)

min_date = min(wq[["Date"]], na.rm = TRUE)
max_date = max(wq[["Date"]], na.rm = TRUE)
date_seq =  seq(from = min_date, to = max_date, by = "day")
date_lab = format(date_seq, "%b %d")

blue_light = "#8accd2"
blue_dark = "#258eac"

basemap = leaflet(options = leafletOptions(attributionControl = FALSE)) |>
  addTiles() |>
  addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo") |>
  addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") |>
  setView(lat = 28.03, lng = -82.775, zoom = 11) |>
  addLayersControl(baseGroups = c("Topo", "Imagery"),
                   options = layersControlOptions(collapsed = FALSE))

add_circles <- function(map, ...){
  map |> 
    addCircleMarkers(radius = 6,
                     color = "black",
                     weight = 1,
                     opacity = 1,
                     fillOpacity = 0.8,
                     ...)
}

layout_columns_custom <- function(...){
  layout_columns(
    col_widths = breakpoints(
      sm = c(1, 10, -1),
      md = c(2, 8, -2),
      lg = c(3, 6, -3)
    ),
    img(src = "logo.jpg", alt = "CHSJS logo", width = "70%"),
    ...
  )
}
