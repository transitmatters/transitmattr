# Getting Started with transitmattr

## What is this package?

`transitmattr` lets you pull live and historical data from the
[TransitMatters Data Dashboard
API](https://dashboard.transitmatters.org) directly into R. You can get
things like:

- Which routes and stops are available
- How often trains/buses are coming (headways)
- How long vehicles sit at stations (dwell times)
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

## Step 2: The query builder pattern

The core of `transitmattr` is the **query builder**: you create a query
object for your transit mode, chain methods to set context (line, stop,
date), and then call a terminal method to fetch the data.

There are four query constructors — one per transit mode:

| Mode                   | Constructor             |
|------------------------|-------------------------|
| Rapid transit (subway) | `tm_rt_query(line)`     |
| Bus                    | `tm_bus_query(route)`   |
| Commuter Rail          | `tm_cr_query(route)`    |
| Ferry                  | `tm_ferry_query(route)` |

All query methods return a **data frame** ready for analysis — no
conversion needed.

Here is what a typical call looks like:

``` r

# Headways at Harvard Square on the Red Line, January 15 2024
df <- tm_rt_query("Red")$stop("Harvard")$headways("2024-01-15")

head(df)
```

You can also set context step by step and reuse the query object:

``` r

q <- tm_rt_query("Red")
q$stop("Harvard")
q$date("2024-01-15")

headways_df <- q$headways()
dwells_df   <- q$dwells()
headways_df
dwells_df
```

## Step 3: Discover routes

Before building a query you need to know which route or line ID to use.

``` r

# All available routes, grouped by mode
routes <- tm_routes()
names(routes)  # "rapid_transit" "bus" "commuter_rail" "ferry"

# All bus route IDs (local lookup, no API call)
tm_bus_routes()

# All commuter rail route IDs
tm_cr_routes()

# All ferry route IDs
tm_ferry_routes()
```

**Rapid transit line IDs:** `"Red"`, `"Orange"`, `"Blue"`, `"Green"`,
`"Mattapan"`. The prefix form (`"line-red"`) is also accepted.

## Step 4: Discover stops with `$stations()`

Every query object has a `$stations()` method that returns a data frame
of all stops for that line or route. Use this to find the exact station
name to pass to `$stop()`, `$from_stop()`, or `$to_stop()`.

``` r

# Red Line stations
tm_rt_query("Red")$stations()

# Which commuter rail stops are on the Fairmount Line?
tm_cr_query("CR-Fairmount")$stations()

# Route 66 bus stops
tm_bus_query("66")$stations()
```

You can also call `$directions()` to see which direction names apply to
the line:

``` r

tm_rt_query("Red")$directions()
# 0 = "southbound", 1 = "northbound" (example)
```

## Step 5: Fetch data for a single day

These terminal methods need a date (a `"YYYY-MM-DD"` string or a `Date`
object). You can pass the date directly to the terminal method or set it
earlier with `$date()`.

``` r

# Headways at Harvard on the Red Line
tm_rt_query("Red")$stop("Harvard")$headways("2024-01-15")

# Dwell times at the same stop
tm_rt_query("Red")$stop("Harvard")$dwells("2024-01-15")

# Travel times — direction is required for travel time queries
tm_rt_query("Red")$
  from_stop("Alewife")$
  to_stop("Kendall/MIT")$
  direction("southbound")$
  travel_times("2024-01-15")

# Speed restrictions on the Red Line for that day
tm_rt_query("Red")$speed_restrictions("2024-01-15")

# Service alerts for a route on a specific day
tm_alerts("2024-01-15", route = "Red")

# Current live alerts (no date needed)
tm_alerts(route = "Red")
```

## Step 6: Fetch data over a date range

For multi-day analysis use `$date_range(start, end)` instead of
`$date()`.

``` r

# Red Line ridership for January 2024
tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$ridership()

# Daily trip metrics for the Red Line
tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$trip_metrics("daily")

# Delay summaries for the Red Line
tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$line_delays()

# Revenue service hours (daily aggregation)
tm_rt_query("Red")$date_range("2024-01-01", "2024-01-31")$service_hours("daily")

# Scheduled service counts across all routes
tm_scheduled_service("2024-01-01", "2024-01-31", agg = "daily", route_id = "Red")
```

## Step 7: Aggregate endpoints

Aggregate endpoints return long-run averages over a date range, useful
for trend analysis.

``` r

# Average headways at Harvard over January 2024
tm_rt_query("Red")$
  stop("Harvard")$
  date_range("2024-01-01", "2024-01-31")$
  aggregate_headways()

# Average dwell times at Harvard
tm_rt_query("Red")$
  stop("Harvard")$
  date_range("2024-01-01", "2024-01-31")$
  aggregate_dwells()

# Average travel times from Park Street to Davis
tm_rt_query("Red")$
  from_stop("Park Street")$
  to_stop("Davis")$
  date_range("2024-01-01", "2024-01-31")$
  aggregate_travel_times()
```

## Step 8: Bus, Commuter Rail, and Ferry

The same builder pattern applies to other modes. Bus and ferry support
`$headways()`, `$dwells()`, `$aggregate_headways()`, and
`$aggregate_dwells()`. Commuter rail additionally supports
`$travel_times()` and `$aggregate_travel_times()`.

``` r

# Bus headways at Harvard on Route 66
tm_bus_query("66")$stop("Harvard")$headways("2024-01-15")

# Aggregate bus dwell times over a month
tm_bus_query("1")$
  stop("Hynes Station")$
  date_range("2024-01-01", "2024-01-31")$
  aggregate_dwells()

# Commuter rail headways at Back Bay on the Fairmount Line
tm_cr_query("CR-Fairmount")$stop("Newmarket")$headways("2026-01-15")

# Ferry headways at Hingham
tm_ferry_query("Boat-F1")$stop("Hingham")$headways("2024-01-15")
```

> **Tip:** Terminus stations on commuter rail and ferry may have
> incomplete stop IDs in one direction. `$stop()` will warn you if you
> pick a terminus.

## Step 9: Make a quick plot

Query methods return data frames, so you can pipe them directly into
`ggplot2`:

``` r

library(ggplot2)
library(dplyr)
library(transitmattr)

ridership_df <- tm_rt_query("Red")$
  date_range("2024-01-01", "2024-01-31")$
  ridership()

ggplot(ridership_df, aes(x = as.Date(date), y = count)) +
  geom_line(color = "#DA291C") +   # Red Line color
  labs(
    title = "Red Line Daily Ridership — January 2024",
    x     = "Date",
    y     = "Riders"
  ) +
  theme_minimal()
```

## Recap: functions and methods at a glance

**Standalone functions** (no query object needed):

| Function | What it returns |
|----|----|
| [`tm_healthcheck()`](https://transitmatters.github.io/transitmattr/reference/tm_healthcheck.md) | API status |
| [`tm_git_id()`](https://transitmatters.github.io/transitmattr/reference/tm_git_id.md) | Server git commit SHA |
| [`tm_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_routes.md) | All routes grouped by mode |
| [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md) | Bus route IDs (local) |
| [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md) | Commuter rail route IDs (local) |
| [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md) | Ferry route IDs (local) |
| `tm_stops(route_id)` | Stop info from the API |
| `tm_alerts(date, route)` | Service alerts |
| `tm_scheduled_service(start, end, agg)` | Scheduled trip counts |
| `tm_time_predictions(route_id)` | Live prediction accuracy |
| [`tm_facilities()`](https://transitmatters.github.io/transitmattr/reference/tm_facilities.md) | All MBTA stations |
| [`tm_service_ridership_dashboard()`](https://transitmatters.github.io/transitmattr/reference/tm_service_ridership_dashboard.md) | System-wide ridership summary |

**Query constructors** → chain methods → call a terminal method:

| Constructor | Requires |
|----|----|
| `tm_rt_query(line)` | `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, `"Mattapan"` |
| `tm_bus_query(route)` | Route ID from [`tm_bus_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_bus_routes.md) |
| `tm_cr_query(route)` | Route ID from [`tm_cr_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_cr_routes.md) |
| `tm_ferry_query(route)` | Route ID from [`tm_ferry_routes()`](https://transitmatters.github.io/transitmattr/reference/tm_ferry_routes.md) |

**Shared builder methods** (all query types):

| Method                    | What it does           |
|---------------------------|------------------------|
| `$stations()`             | Browse available stops |
| `$directions()`           | See direction labels   |
| `$date(d)`                | Set a single date      |
| `$date_range(start, end)` | Set a date range       |
| `$stop(name)`             | Set the stop           |
| `$direction(dir)`         | Set the direction      |

**Terminal methods** (fetch data, return a data frame):

| Method | Needs |
|----|----|
| `$headways(date)` | stop + date |
| `$dwells(date)` | stop + date |
| `$travel_times(date)` | from/to stops + direction + date (RT and CR only) |
| `$aggregate_headways()` | stop + date_range |
| `$aggregate_dwells()` | stop + date_range |
| `$aggregate_travel_times()` | from/to stops + date_range (RT and CR only) |
| `$ridership()` | date_range (RT only) |
| `$trip_metrics(agg)` | date_range (RT only) |
| `$line_delays(agg)` | date_range (RT only) |
| `$service_hours(agg)` | date_range (RT only) |
| `$scheduled_service(agg)` | date_range (RT only) |
| `$speed_restrictions(date)` | date (RT only) |

Next, check out the **Red Line Analysis** vignette for a full worked
example that goes from raw API data to a polished chart.
