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

pixel_basin_sf = readRDS(file.path("data", "pixel_basin_sf.rds"))
rainfall = readRDS(file.path("data", "annual-rainfall.rds"))

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
  addLayersControl(baseGroups = c("Topo", "Imagery"),
                   options = layersControlOptions(collapsed = FALSE))
