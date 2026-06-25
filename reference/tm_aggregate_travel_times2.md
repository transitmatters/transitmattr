# Get aggregate travel times (v2)

Second variant of the aggregate travel times endpoint. Accepts the same
query parameters as
[`tm_aggregate_travel_times()`](https://transitmatters.github.io/transitmattr/reference/tm_aggregate_travel_times.md).

## Usage

``` r
tm_aggregate_travel_times2(..., base_url = tm_base_url())
```

## Arguments

- ...:

  Named query parameters passed to the API (e.g., `from_stop`,
  `to_stop`, `start_date`, `end_date`).

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with `by_date` and `by_time` elements.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_aggregate_travel_times2(
  from_stop  = "70076",
  to_stop    = "70061",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
} # }
```
