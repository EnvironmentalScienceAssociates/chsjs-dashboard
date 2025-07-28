options(repos = c(ESA = "https://environmentalscienceassociates.r-universe.dev",
                  CRAN = "https://cloud.r-project.org"))

egnyte_files = c("isotopes.rds", "monthly-rainfall.rds", "pixel_chsjs_sf.rds", "seagrass_sites.rds",
                 "seagrass_species.rds", "seagrass_stations.rds")

rsconnect::deployApp(forceUpdate = TRUE)