# Get aggregate travel times

Retrieves aggregated travel time data over a date range and stop pair.
Common query parameters include `from_stop`, `to_stop`, `start_date`,
and `end_date`.

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
  from_stop  = "place-pktrm",
  to_stop    = "place-davis",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
} # }
```
