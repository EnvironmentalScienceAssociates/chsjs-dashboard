options(repos = c(ESA = "https://environmentalscienceassociates.r-universe.dev",
                  CRAN = "https://cloud.r-project.org"))

egnyte_files = c("isotopes.rds", "monthly-rainfall.rds", "pixel_chsjs_sf.rds", "seagrass_sites.rds",
                 "seagrass_species.rds", "seagrass_stations.rds", "wq_combined.rds")
for (i in egnyte_files) if (file.exists(file.path("data", i))) file.remove(file.path("data", i))

rsconnect::deployApp(forceUpdate = TRUE)
