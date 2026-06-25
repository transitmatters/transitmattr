# Create a rapid transit query

Constructs a `TmRTQuery` object for the given MBTA rapid transit line.
Chain builder methods to set context, then call a terminal method to
fetch data.

## Usage

``` r
tm_rt_query(line, base_url = tm_base_url())
```

## Arguments

- line:

  Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or `"Mattapan"`.
  Case-insensitive; `"line-red"` form also accepted.

- base_url:

  API base URL. Defaults to the production host or the
  `tm_dashboard_base_url` option.

## Value

A `TmRTQuery` R6 object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Headways at Harvard on the Red Line
tm_rt_query("Red")$stop("Harvard")$headways("2024-01-15")

# Travel times (direction required for stop ID resolution)
tm_rt_query("Red")$from_stop("Alewife")$to_stop("Kendall/MIT")$direction("southbound")$travel_times("2024-01-15")

# Line-level aggregate (no stop needed)
tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")
} # }
```
