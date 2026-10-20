# Get hourly weather in downtown Boston

Data covers recent dates only.

## Usage

``` r
tm_weather(start_date, end_date, base_url = tm_base_url())
```

## Arguments

- start_date:

  Start of the date range. A `Date` object or `"YYYY-MM-DD"` string.

- end_date:

  End of the date range.

- base_url:

  Base URL of the TransitMatters API.

## Value

A `data.frame` with one row per hour: `timestamp` (Eastern local time,
e.g. `"2026-04-22T14:00"`), `temperature_f`, `weather_code` (a WMO
code), `condition` (e.g. `"clear"`, `"rain"`), `precipitation_in`,
`humidity_pct`, and `wind_mph`.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_weather("2026-10-01", "2026-10-07")
} # }
```
