# Get prediction accuracy by week

Returns how accurate the MBTA's arrival and departure predictions were
for a route, week by week. Pass `start_date` and `end_date` to return
only the weeks starting in that range; omit them for the full history.

## Usage

``` r
tm_time_predictions(
  route_id,
  start_date = NULL,
  end_date = NULL,
  base_url = tm_base_url()
)
```

## Arguments

- route_id:

  Route identifier, e.g. `"Red"`, `"CR-Fairmount"`.

- start_date:

  Optional. Return only weeks starting on or after this date. A `Date`
  object or `"YYYY-MM-DD"` string.

- end_date:

  Optional. Return only weeks starting on or before this date.

- base_url:

  Base URL of the TransitMatters API.

## Value

A list with one element per week, each with `routeId`, `week` (a
`Date`), and `prediction`: a list of accuracy buckets with `bin` (how
far ahead the prediction was, e.g. `"0-3 min"`), `num_predictions`, and
`num_accurate_predictions`.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_time_predictions("Red")
tm_time_predictions("Red", "2026-06-01", "2026-07-31")
} # }
```
