# Look up numeric stop IDs for a rapid transit station

Returns the stop ID(s) used by the headway, dwell, and travel-time
endpoints for a given station and direction of travel.

## Usage

``` r
tm_stop_id(line, stop_name, direction)
```

## Arguments

- line:

  Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or `"Mattapan"`
  (case-insensitive; `"line-red"` form also accepted).

- stop_name:

  Station name (case-insensitive), e.g. `"Alewife"`, `"Davis"`. Use
  [`tm_line_stations()`](https://transitmatters.github.io/transitmattr/reference/tm_line_stations.md)
  to see all valid names.

- direction:

  Direction of travel. Either the direction name for the line (e.g.
  `"northbound"`, `"southbound"`, `"eastbound"`, `"westbound"`) or the
  numeric code `0` or `1`. Use
  [`tm_line_directions()`](https://transitmatters.github.io/transitmattr/reference/tm_line_directions.md)
  to see which names apply to a given line.

## Value

A character vector of stop IDs (most stations have one; branching or
multi-platform stations may have several).

## Examples

``` r
tm_stop_id("Red", "Alewife", "southbound")
#> [1] "70061"
tm_stop_id("Red", "Davis", 0)
#> [1] "70064"
tm_stop_id("Green", "Park Street", "eastbound")
#> [1] "70200"
```
