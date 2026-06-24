# Get dwell time data for a date

Get dwell time data for a date

## Usage

``` r
tm_dwells(user_date, stop, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object or a `"YYYY-MM-DD"` string.

- stop:

  One or more stop IDs (required). Use
  [`tm_stops()`](https://transitmatters.github.io/transitmattr/reference/tm_stops.md)
  to find IDs. Pass a character vector for multiple stops.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

An unnamed list of dwell event records. Use `dplyr::bind_rows(result)`
to convert to a data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_dwells("2024-01-15", stop = "70061")
} # }
```
