# transitmattr: R Client for the TransitMatters Data Dashboard API

A thin 'httr2'-based wrapper around the TransitMatters Data Dashboard
API, providing access to MBTA performance metrics including headways,
dwell times, travel times, ridership, and service data.

## Options

- `tm_dashboard_base_url`: the API's base URL. Defaults to the
  production API.

- `transitmattr.max_concurrency`: how many requests to have in flight at
  once when a call makes several, such as `$headways()` over a date
  range. Defaults to 8.

## See also

Useful links:

- <https://transitmatters.github.io/transitmattr/>

- <https://github.com/transitmatters/transitmattr>

- Report bugs at <https://github.com/transitmatters/transitmattr/issues>

## Author

**Maintainer**: Andrew Kouré <akoure@transitmatters.info>

Authors:

- Andrew Kouré <akoure@transitmatters.info>
