## Run the vignettes' code and the help pages' examples against the live API.
##
## The vignettes don't run their chunks when the package is built, and the
## examples are in \dontrun{}, because both call the API. This runs them all,
## so they keep working as the API and the package change. It makes about 80
## API requests. Run from the package root:
##
##   Rscript data-raw/run_examples.R
##
## A vignette chunk with `live = FALSE` is skipped, e.g. one that installs a
## package.
##
## Requires: devtools, knitr, and the packages the vignettes use

if (!file.exists("DESCRIPTION")) {
  stop("Run this script from the package root.", call. = FALSE)
}
devtools::load_all(quiet = TRUE)

message("Running the help pages' examples")
devtools::run_examples(run_dontrun = TRUE, document = FALSE)

# Run every chunk, even eval = FALSE ones, unless it says live = FALSE.
knitr::opts_hooks$set(eval = function(options) {
  options$eval <- !isFALSE(options$live)
  options
})
out <- tempfile("vignettes-")
dir.create(out)
# Stop at the first error rather than writing it into the output, and keep
# plots out of the package directory.
knitr::opts_chunk$set(error = FALSE, fig.path = file.path(out, "figure", ""))
for (vignette in list.files("vignettes", pattern = "\\.Rmd$", full.names = TRUE)) {
  message("Running ", vignette)
  knitr::knit(vignette, output = file.path(out, sub("Rmd$", "md", basename(vignette))),
              envir = new.env(), quiet = TRUE)
}
message("All examples ran.")
