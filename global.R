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

blue_light = "#8accd2"
blue_dark = "#258eac"

# Seagrass ----------------------------------------------------------------

seagrass_stations = readRDS(file.path("data", "seagrass_stations.rds")) |> 
  filter(Year < 2024)
seagrass_sites = readRDS(file.path("data", "seagrass_sites.rds"))
seagrass_species = readRDS(file.path("data", "seagrass_species.rds"))

species_sg = c("Syringodium", "Thalassia", "Halodule")
params_sg = c("Blade Length" = "BL_avg", 
              "Percent Cover" = "PerCov",
              "Percent Cover (SAV)" = "SAV_PerCov",  
              "Attached Algae" = "AAlgae_PerCov",
              "Detached Algae" = "DAlgae_PerCov",
              "Depth" = "Depth_m")

min_yr_sg = min(seagrass_stations$Year, na.rm = TRUE)
max_yr_sg = max(seagrass_stations$Year, na.rm = TRUE)
months_sg = sort(unique(seagrass_stations$MonthAbb))
strata_sg = sort(unique(seagrass_stations$Strata))
strata_colors = c("#1193BA", "#F9A134", "#8FCEA5") |> 
  setNames(strata_sg)

# Rainfall ----------------------------------------------------------------

pixel_basin_sf = readRDS(file.path("data", "pixel_basin_sf.rds"))
rainfall = readRDS(file.path("data", "annual-rainfall.rds"))

# Isotopes ----------------------------------------------------------------

isotopes = readRDS(file.path("data", "isotopes.rds")) |> 
  mutate(Tooltip = paste0("Date: ", Date, "<br>",
                          "Site: ", Site, "<br>",
                          "Delta 15N: ", `Delta 15N (‰)`, "‰<br>",
                          "Delta 18O: ", `Delta 18O (‰)`, "‰"))

# Water Quality -----------------------------------------------------------

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

# Map ---------------------------------------------------------------------

basemap = leaflet(options = leafletOptions(attributionControl = FALSE)) |>
  addTiles() |>
  addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo") |>
  addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") |>
  addLayersControl(baseGroups = c("Topo", "Imagery"),
                   options = layersControlOptions(collapsed = FALSE))
