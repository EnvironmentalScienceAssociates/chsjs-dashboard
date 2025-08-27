options(dplyr.summarise.inform = FALSE,
        shiny.autoreload = TRUE)
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

# Data --------------------------------------------------------------------

if (!dir.exists("data")) dir.create("data")

remote_path = file.path("Shared","Projects","2020","D202001308.05 - Clearwater Harbor St. Joseph Sound FY24",
                        "Analysis","R Analysis","Rdata")

 
egnyte_files = c("isotopes.rds", "monthly-rainfall.rds", "pixel_chsjs_sf.rds", "seagrass_sites.rds",
                 "seagrass_species.rds", "seagrass_stations.rds", "wq.rds")

for (i in egnyte_files){
  Sys.sleep(0.4) # avoid rate limiting and 403
  # https://github.com/thinkelman-esa/egnyter
  egnyter::download_file(file.path(remote_path, i), file.path("data", i),
                         domain = "https://oneesa.egnyte.com",
                         token = Sys.getenv("EgnyteKey"))
}

# Seagrass ----------------------------------------------------------------

seagrass_stations = readRDS(file.path("data", "seagrass_stations.rds")) |> 
  filter(Year < 2024)
seagrass_sites = readRDS(file.path("data", "seagrass_sites.rds"))
seagrass_species = readRDS(file.path("data", "seagrass_species.rds"))

species_sg = c("Syringodium", "Thalassia", "Halodule")
params_sg = c("Blade Length" = "BL_avg", 
              "Percent Cover" = "PerCov",
              "Percent Cover (SAV Total)" = "SAV_PerCov",  
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

pixel_chsjs_sf = readRDS(file.path("data", "pixel_chsjs_sf.rds"))
rainfall_monthly = readRDS(file.path("data", "monthly-rainfall.rds"))
months = setNames(1:12, month.abb[1:12])

# Isotopes ----------------------------------------------------------------

isotopes = readRDS(file.path("data", "isotopes.rds")) |> 
  mutate(Tooltip = paste0("Date: ", Date, "<br>",
                          "Site: ", Site, "<br>",
                          "Delta 15N: ", `Delta 15N (‰)`, "‰<br>",
                          "Delta 18O: ", `Delta 18O (‰)`, "‰"))

# Water Quality -----------------------------------------------------------

wq_raw = readRDS(file.path("data", "wq.rds"))

site_locs = wq_raw |> 
  select(Site, Lat, Lon) |> 
  distinct()

wq = wq_raw |> 
  mutate(Parameter_Units = ifelse(is.na(Units), Parameter, paste0(Parameter, " (", Units, ")"))) |> 
  select(Date, Level, Parameter = Parameter_Units, Site, Value = Result)

min_date_wq = min(wq[["Date"]], na.rm = TRUE)
max_date_wq = max(wq[["Date"]], na.rm = TRUE)

# Map ---------------------------------------------------------------------

basemap = leaflet(options = leafletOptions(attributionControl = FALSE)) |>
  addTiles() |>
  addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo") |>
  addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") |>
  addLayersControl(baseGroups = c("Topo", "Imagery"),
                   options = layersControlOptions(collapsed = FALSE))
