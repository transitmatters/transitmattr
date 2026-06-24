# transitmattr

An R package for the [TransitMatters Data Dashboard
API](https://dashboard.transitmatters.org), providing access to MBTA
performance metrics: headways, dwell times, travel times, ridership,
speed restrictions, and more.

## Installation

``` r

# install.packages("pak")
pak::pak("transitmatters/transitmattr")
```

Or with `remotes`:

``` r

remotes::install_github("transitmatters/transitmattr")
```

## Usage

``` r

library(transitmattr)
```

### No-parameter endpoints

``` r

# Check API health
tm_healthcheck()

# List MBTA facilities
tm_facilities()

# Service ridership dashboard summary
tm_service_ridership_dashboard()
```

### Per-date endpoints

Functions accept either a `Date` object or a `"YYYY-MM-DD"` string.

``` r

tm_headways("2024-01-15")
tm_dwells(as.Date("2024-01-15"))
tm_travel_times("2024-01-15")

# Dated or current alerts
tm_alerts()
tm_alerts("2024-01-15")
```

### Aggregate endpoints

``` r

tm_aggregate_travel_times(
  from_stop  = "place-pktrm",
  to_stop    = "place-davis",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)

tm_aggregate_headways(
  stop       = "place-davis",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
```

### Parameterized endpoints

``` r

# Ridership for the Red Line
tm_ridership("2024-01-01", "2024-01-31", line_id = "Red")

# Delay summary by line
tm_line_delays("2024-01-01", "2024-01-31", line = "Red")

# Trip metrics
tm_trip_metrics("2024-01-01", "2024-01-31", agg = "daily", line = "Red")

# Scheduled service (optionally filtered to one route)
tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily")
tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily", route_id = "Red")

# Speed restrictions / slow zones
tm_speed_restrictions("Red", "2024-01-15")

# Service hours
tm_service_hours("2024-01-01", "2024-01-31", agg = "daily")
```

### Overriding the base URL

``` r

options(tm_dashboard_base_url = "https://your-staging-host.example.com")
```

## License

MIT
