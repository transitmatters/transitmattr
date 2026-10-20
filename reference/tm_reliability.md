# Get on-time performance for The RIDE or commuter rail

Returns on-time performance counts summed over each day, week, or month.
The RIDE entries have `completed` and `onTime`, plus `requests`,
`noShows`, and `missed` where every day recorded them. Commuter rail
entries have `otpNumerator`, `otpDenominator`, `cancelled`, and the same
counts split into `peak` and `offPeak`.

## Usage

``` r
tm_reliability(route_id, start_date, end_date, agg, base_url = tm_base_url())
```

## Arguments

- route_id:

  `"RIDE"` for The RIDE, a commuter rail route ID (e.g.
  `"CR-Worcester"`), or `"commuter-rail"` for every commuter rail route
  combined.

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range.

- agg:

  Aggregation level: `"daily"`, `"weekly"`, or `"monthly"`.

- base_url:

  Base URL of the TransitMatters API.

## Value

A `data.frame` of reliability records.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_reliability("RIDE", "2025-01-01", "2025-03-31", agg = "monthly")
tm_reliability("CR-Worcester", "2025-03-01", "2025-03-31", agg = "weekly")
} # }
```
