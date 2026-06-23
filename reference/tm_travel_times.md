# Get travel time data for a date

Get travel time data for a date

## Usage

``` r
tm_travel_times(user_date, base_url = tm_base_url())
```

## Arguments

- user_date:

  A `Date` object or a `"YYYY-MM-DD"` string.

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with a `travel_times` element containing per-segment travel time
data.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_travel_times("2024-01-15")
} # }
```
