# Getting Started with transitmattr

## What is this package?

`transitmattr` lets you pull live and historical data from the
[TransitMatters Data Dashboard
API](https://dashboard.transitmatters.org) directly into R. You can get
things like:

- Which routes and stops are available
- How often trains are coming (headways)
- How long trains sit at stations (dwell times)
- How long it takes to travel between stops (travel times)
- How many people are riding (ridership)
- Where slow zones are affecting service

## Installation

``` r

# install.packages("pak")  # run this once if you don't have pak
pak::pak("transitmatters/transitmattr")
```

## Loading the package

``` r

library(transitmattr)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
```

## Step 1: Check that the API is working

Before doing anything else, it’s good practice to confirm the API is up.

``` r

tm_healthcheck()
```

You’ll get back something like:

    $status
    [1] "pass"

If you see `"pass"` you’re good to go.

## Step 2: Understanding what you get back

All `tm_*` functions return a **list** — R’s way of bundling different
pieces of data together. Most dated endpoints return an unnamed list of
event records, one per observation (e.g. one per train departure). Use
[`str()`](https://rdrr.io/r/utils/str.html) to see the shape and `[[1]]`
to inspect a single record.

``` r

result <- tm_headways("2024-01-15", stop = "70061")

length(result)    # number of events
str(result[[1]])  # fields: route_id, direction, current_dep_dt,
                  #   headway_time_sec, benchmark_headway_time_sec,
                  #   vehicle_label, vehicle_consist
```

## Step 3: Discover routes and stops

Before pulling event data you often need to know which routes and stop
IDs exist.

``` r

# All available routes, grouped by mode
routes <- tm_routes()
names(routes)  # "rapid_transit" "bus" "commuter_rail" "ferry"

# Stop IDs for a specific route (needed for filtering headways, travel times, etc.)
# Route IDs come from tm_routes() — e.g. "Red", "Orange", "Green-B"
red_stops <- tm_stops("Red")
```

## Step 4: Pull data for a single day

These functions need a date. You can also pass stop IDs to narrow the
results — without them you get every stop, which can be a large
response.

``` r

# Headways at one stop (or a vector of stops)
headways <- tm_headways("2024-01-15", stop = "70061")
headways <- tm_headways("2024-01-15", stop = c("70061", "70063"))

# Dwell times at a stop
dwells <- tm_dwells("2024-01-15", stop = "70061")

# Travel times between a stop pair
travel <- tm_travel_times("2024-01-15", from_stop = "70076", to_stop = "70064")

# Alerts for a specific day and route
alerts <- tm_alerts("2024-01-15", route = "Red")

# Current live alerts for a route
alerts_now <- tm_alerts(route = "Red")
```

## Step 5: Pull data over a date range

Most analysis requires looking at a range of dates. These functions take
`start_date` and `end_date` plus some extra options.

``` r

# Daily Red Line ridership for January 2024
ridership <- tm_ridership(
  start_date = "2024-01-01",
  end_date   = "2024-01-31",
  line_id    = "line-red"
)

# Daily trip metrics for the Red Line
trips <- tm_trip_metrics(
  start_date = "2024-01-01",
  end_date   = "2024-01-31",
  agg        = "daily",
  line       = "line-red"
)

# How many trips were scheduled to run each day
scheduled <- tm_scheduled_service(
  start_date = "2024-01-01",
  end_date   = "2024-01-31",
  route_id    = "Red",
  agg        = "daily"
)

# Total revenue service hours each day on the Red Line
hours <- tm_service_hours(
  start_date = "2024-01-01",
  end_date   = "2024-01-31",
  agg        = "daily",
  line_id    = "Red"
)
```

**Available line IDs:**

| Line        | `line_id` / `line` |
|-------------|--------------------|
| Red Line    | `"line-red"`       |
| Orange Line | `"line-orange"`    |
| Blue Line   | `"line-blue"`      |
| Green Line  | `"line-green"`     |
| Commuter    | `"line-cr"`        |

## Step 8: Turn the result into a data frame

The API gives back a list, but most R analysis tools (like `ggplot2`)
prefer a **data frame**. Here’s the easiest way to convert:

``` r

library(dplyr)
library(transitmattr)

# Pull ridership data
ridership_raw <- tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red")

# Each item in ridership_raw is one record — bind them into rows
ridership_df <- bind_rows(ridership_raw)

# Now it looks like a spreadsheet
head(ridership_df)
```

> **Tip:** If
> [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
> doesn’t work, try
> `do.call(rbind, lapply(ridership_raw, as.data.frame))` — it’s a bit
> more verbose but handles some tricky list shapes.

## Step 9: Make a quick plot

Once you have a data frame you can plot with `ggplot2`:

``` r

library(ggplot2)
library(dplyr)
library(transitmattr)

ridership_df <- bind_rows(
  tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red")
)

ggplot(ridership_df, aes(x = as.Date(date), y = count)) +
  geom_line(color = "#DA291C") +   # Red Line color
  labs(
    title = "Red Line Daily Ridership — January 2024",
    x     = "Date",
    y     = "Riders"
  ) +
  theme_minimal()
```

## Step 7: Aggregate endpoints

The aggregate endpoints return long-run averages rather than individual
trip events — useful for trend analysis over weeks or months.

``` r

# Average travel time from Park Street to Davis, by date
travel_agg <- tm_aggregate_travel_times(
  from_stop  = "70076",
  to_stop    = "70064",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)

# Same data via the v2 endpoint (returns by_date and by_time breakdowns)
travel_agg2 <- tm_aggregate_travel_times2(
  from_stop  = "70076",
  to_stop    = "70064",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)

# Average headways at a stop over a date range
headways_agg <- tm_aggregate_headways(
  stop       = "70061",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)

# Average dwell times at a stop over a date range
dwells_agg <- tm_aggregate_dwells(
  stop       = "70061",
  start_date = "2024-01-01",
  end_date   = "2024-01-31"
)
```

> **Tip:** The v2 travel times endpoint (`tm_aggregate_travel_times2`)
> is used in the Red Line Analysis vignette for a worked plotting
> example.

## Recap: the functions at a glance

| Function | What it returns | Needs |
|----|----|----|
| [`tm_healthcheck()`](https://transitmatters.github.io/transitmattr/reference/tm_healthcheck.md) | API status | nothing |
| [`tm_git_id()`](https://transitmatters.github.io/transitmattr/reference/tm_git_id.md) | Server git commit SHA | nothing |
| [`tm_time_predictions()`](https://transitmatters.github.io/transitmattr/reference/tm_time_predictions.md) | Live time predictions | nothing |
| [`tm_service_ridership_dashboard()`](https://transitmatters.github.io/transitmattr/reference/tm_service_ridership_dashboard.md) | System-wide ridership summary | nothing |
| [`tm_facilities()`](https://transitmatters.github.io/transitmattr/reference/tm_facilities.md) | All MBTA stations | nothing |
| [`tm_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_routes.md) | All available routes by mode | nothing |
| `tm_stops(route_id)` | Stop IDs for a route | route ID |
| `tm_headways(date, stop)` | Train frequency | date + stop(s) |
| `tm_dwells(date, stop)` | Station dwell times | date + stop(s) |
| `tm_travel_times(date, from_stop, to_stop)` | Stop-to-stop travel | date + stop pair |
| `tm_alerts(date, route)` | Service alerts | optional date + route |
| `tm_ridership(start, end)` | Ridership counts | date range |
| `tm_trip_metrics(start, end, agg, line)` | Trip performance | date range + line |
| `tm_line_delays(start, end, line)` | Delay summaries | date range + line |
| `tm_scheduled_service(start, end, agg)` | Scheduled trip counts | date range + agg |
| `tm_service_hours(start, end, agg, line_id)` | Revenue service hours | date range + agg + line |
| `tm_speed_restrictions(line_id, date)` | Slow zones | line + date |
| `tm_aggregate_travel_times(...)` | Long-run travel time trends | stop pair + range |
| `tm_aggregate_travel_times2(...)` | Long-run travel times (v2, with by_date/by_time) | stop pair + range |
| `tm_aggregate_headways(...)` | Long-run headway trends | stop + range |
| `tm_aggregate_dwells(...)` | Long-run dwell time trends | stop + range |

Next, check out the **Red Line Analysis** vignette for a full worked
example that goes from raw API data to a polished chart.
