# Look up the GTFS place ID for a rapid transit station

Returns the GTFS parent-station identifier (e.g. `"place-alfcl"`,
`"place-davis"`). These are provided for cross-referencing with the MBTA
v3 API. The TransitMatters aggregate endpoints expect stop IDs from
[`tm_stop_id()`](https://transitmatters.github.io/transitmattr/reference/tm_stop_id.md),
not place IDs.

## Usage

``` r
tm_place_id(line, stop_name)
```

## Arguments

- line:

  Line name: `"Red"`, `"Orange"`, `"Blue"`, `"Green"`, or `"Mattapan"`
  (case-insensitive; `"line-red"` form also accepted).

- stop_name:

  Station name (case-insensitive), e.g. `"Alewife"`, `"Davis"`. Use
  [`tm_line_stations()`](https://transitmatters.github.io/transitmattr/reference/tm_line_stations.md)
  to see all valid names.

## Value

A single GTFS place ID string.

## Examples

``` r
tm_place_id("Red", "Alewife")
#> [1] "place-alfcl"
tm_place_id("Green", "Park Street")
#> [1] "place-pktrm"
```
