# Get travel time data for a date

Get travel time data for a date

## Usage

``` r
tm_travel_times(user_date, from_stop, to_stop, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object or a `"YYYY-MM-DD"` string.

- from_stop:

  One or more origin stop IDs (required). Use
  [`tm_stops()`](https://transitmatters.github.io/transitmattr/reference/tm_stops.md)
  to find IDs.

- to_stop:

  One or more destination stop IDs (required).

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

An unnamed list of travel time event records. Use
`dplyr::bind_rows(result)` to convert to a data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_travel_times("2024-01-15", from_stop = "70076", to_stop = "70064")
} # }
```
