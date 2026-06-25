# Get aggregate travel times

Retrieves aggregated travel time data over a date range and stop pair.
Common query parameters include `from_stop`, `to_stop`, `start_date`,
and `end_date`. `from_stop` and `to_stop` take **stop IDs** (as returned
by
[`tm_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_stop_id.md),
[`tm_bus_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_stop_id.md),
or
[`tm_cr_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_stop_id.md)),
not place IDs. Multiple stop IDs for the same station can be passed by
repeating the argument (e.g. `from_stop = c("70076", "70077")`).

## Usage

``` r
tm_aggregate_travel_times(..., base_url = tm_base_url())
```

## Arguments

- ...:

  Named query parameters passed to the API (e.g., `from_stop`,
  `to_stop`, `start_date`, `end_date`).

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list with a `data` element.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_aggregate_travel_times(
  from_stop  = "70076",
  to_stop    = "70061",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
} # }
```
