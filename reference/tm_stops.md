# Get stops for a route from the API

Returns live stop data from the API for a given route. For local lookups
backed by embedded data, use the `$stations()` method on a query object.

## Usage

``` r
tm_stops(route_id, base_url = tm_base_url())
```

## Arguments

- route_id:

  An MBTA route ID string (e.g. `"Red"`, `"CR-Fairmount"`).

- base_url:

  Base URL of the TransitMatters API.

## Value

A list with `type`, `direction`, and `stations` elements.

## Examples

``` r
if (FALSE) { # \dontrun{
tm_stops("Red")
} # }
```
