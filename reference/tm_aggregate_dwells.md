# Get aggregate dwells

Common query parameters include `stop`, `start_date`, `end_date`, and
`direction_id`.

## Usage

``` r
tm_aggregate_dwells(..., base_url = tm_base_url())
```

## Arguments

- ...:

  Named query parameters passed to the API (e.g., `from_stop`,
  `to_stop`, `start_date`, `end_date`).

- base_url:

  Base URL of the TransitMatters API. Defaults to
  `getOption("tm_dashboard_base_url")` or the production host.

## Value

A list of aggregated dwell time data.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_aggregate_dwells(
  stop       = "place-davis",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
} # }
```
