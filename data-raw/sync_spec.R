## Sync the TransitMatters Data Dashboard OpenAPI spec from upstream.
##
## Downloads server/openapi.json from transitmatters/t-performance-dash at a
## pinned commit and records that commit in spec/UPSTREAM_SHA. Run from the
## package root:
##
##   Rscript data-raw/sync_spec.R              # sync to latest commit on main
##   Rscript data-raw/sync_spec.R --ref <sha>  # sync to a commit, tag, or branch
##   Rscript data-raw/sync_spec.R --check      # exit 1 if upstream differs; write nothing
##
## After a sync that changes the spec, run data-raw/generate_client.R.
## Set GITHUB_TOKEN to avoid GitHub's unauthenticated API rate limit.
##
## Requires: httr2, jsonlite

upstream_repo <- "transitmatters/t-performance-dash"
upstream_path <- "server/openapi.json"
spec_file     <- file.path("spec", "openapi.json")
sha_file      <- file.path("spec", "UPSTREAM_SHA")

if (!file.exists("DESCRIPTION")) {
  stop("Run this script from the package root.", call. = FALSE)
}

parse_args <- function(args) {
  out <- list(ref = "main", check = FALSE)
  i <- 1
  while (i <= length(args)) {
    if (args[[i]] == "--check") {
      out$check <- TRUE
    } else if (args[[i]] == "--ref" && i < length(args)) {
      out$ref <- args[[i + 1]]
      i <- i + 1
    } else {
      stop("Unknown argument: ", args[[i]], call. = FALSE)
    }
    i <- i + 1
  }
  out
}

github_get <- function(url, accept) {
  req <- httr2::request(url)
  req <- httr2::req_headers(req, Accept = accept)
  req <- httr2::req_user_agent(req, "transitmattr-sync")
  token <- Sys.getenv("GITHUB_TOKEN")
  # Only the API needs auth (for rate limits). A token scoped to another
  # repo makes raw.githubusercontent.com return 404 for public files.
  if (nzchar(token) && startsWith(url, "https://api.github.com/")) {
    req <- httr2::req_auth_bearer_token(req, token)
  }
  httr2::req_perform(req)
}

# Resolve a branch, tag, or short SHA to a full commit SHA.
resolve_sha <- function(ref) {
  url <- sprintf("https://api.github.com/repos/%s/commits/%s", upstream_repo, ref)
  trimws(httr2::resp_body_string(github_get(url, "application/vnd.github.sha")))
}

fetch_spec <- function(sha) {
  url <- sprintf("https://raw.githubusercontent.com/%s/%s/%s",
                 upstream_repo, sha, upstream_path)
  body <- httr2::resp_body_raw(github_get(url, "application/json"))
  doc <- tryCatch(
    jsonlite::fromJSON(rawToChar(body), simplifyVector = FALSE),
    error = function(e) {
      stop("Upstream spec at ", sha, " is not valid JSON: ", conditionMessage(e),
           call. = FALSE)
    }
  )
  if (is.null(doc$openapi) || is.null(doc$paths)) {
    stop("Upstream file at ", sha, " doesn't look like an OpenAPI spec.",
         call. = FALSE)
  }
  body
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
sha  <- resolve_sha(args$ref)
spec <- fetch_spec(sha)
short_sha <- substr(sha, 1, 12)

current_spec <- if (file.exists(spec_file)) {
  readBin(spec_file, "raw", file.info(spec_file)$size)
} else {
  raw()
}
current_sha  <- if (file.exists(sha_file)) trimws(readLines(sha_file)) else ""
spec_changed <- !identical(spec, current_spec)

if (args$check) {
  if (spec_changed) {
    vendored <- if (nzchar(current_sha)) substr(current_sha, 1, 12) else "none"
    message("spec differs from upstream ", short_sha, " (vendored: ", vendored, ")")
    quit(status = 1)
  }
  message("spec matches upstream ", short_sha)
  quit(status = 0)
}

dir.create(dirname(spec_file), showWarnings = FALSE)
writeBin(spec, spec_file)
writeLines(sha, sha_file)

if (spec_changed) {
  message("updated spec to upstream ", short_sha)
} else if (sha != current_sha) {
  message("spec unchanged; bumped pin to ", short_sha)
} else {
  message("already at ", short_sha)
}

# Expose results to GitHub Actions steps.
github_output <- Sys.getenv("GITHUB_OUTPUT")
if (nzchar(github_output)) {
  cat(
    sprintf("sha=%s\nshort_sha=%s\nchanged=%s\n", sha, short_sha, tolower(spec_changed)),
    file = github_output, append = TRUE
  )
}
