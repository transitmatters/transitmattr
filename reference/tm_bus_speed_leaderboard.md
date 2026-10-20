# Get the slowest bus routes

Ranks bus routes by average speed over a date range, slowest first.
Speed in mph is `miles_covered / (total_time / 3600)`.

## Usage

``` r
tm_bus_speed_leaderboard(
  start_date,
  end_date,
  limit = NULL,
  base_url = tm_base_url()
)
```

## Arguments

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range.

- limit:

  Maximum number of routes to return, from 1 to 200. Optional; the API
  defaults to 10.

- base_url:

  Base URL of the TransitMatters API.

## Value

A `data.frame` with one row per route: `route`, trips delivered
(`count`), `total_time` in seconds, `miles_covered`, and `n_traversals`.

## Details

Data covers recent dates only. The API ranks routes over at most 150
days.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_bus_speed_leaderboard("2026-09-01", "2026-09-30", limit = 20)
} # }
```
