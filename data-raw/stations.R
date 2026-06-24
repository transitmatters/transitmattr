## Run this script to regenerate R/sysdata.rda whenever any file under
## constants/ changes.
##
## Requires: jsonlite, usethis (both in Suggests)

.read_dir <- function(subdir) {
  files <- list.files(
    file.path("constants", subdir),
    full.names = TRUE,
    pattern = "\\.json$"
  )
  do.call(c, lapply(files, jsonlite::fromJSON, simplifyVector = FALSE))
}

.tm_rt_stations    <- jsonlite::fromJSON("constants/stations.json",
                                         simplifyVector = FALSE)
.tm_bus_stations   <- .read_dir("bus_constants")
.tm_cr_stations    <- .read_dir("cr_constants")
.tm_ferry_stations <- .read_dir("ferry_constants")

usethis::use_data(
  .tm_rt_stations, .tm_bus_stations, .tm_cr_stations, .tm_ferry_stations,
  internal = TRUE, overwrite = TRUE
)
