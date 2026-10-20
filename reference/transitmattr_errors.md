# Errors raised by transitmattr

When a request fails, transitmattr raises an error with one of these
classes, so you can handle each kind of failure with
[`tryCatch()`](https://rdrr.io/r/base/conditions.html):

## Details

    transitmattr_error
    |-- transitmattr_http_error       the API responded with an error status
    |   |-- transitmattr_bad_request    400: a parameter is missing or invalid
    |   |-- transitmattr_range_too_long 403: the date range has too many entries
    |   |-- transitmattr_not_found      404: no route has this ID
    |   `-- transitmattr_server_error   5xx: the API failed
    `-- transitmattr_network_error    no response: a timeout or failed connection

HTTP errors have fields `status` (the HTTP status code), `code` (the
error type the API reported, such as `"ForbiddenError"`, or `NULL`), and
`content` (the response body as text). They also have httr2's classes
`httr2_http_<status>`, `httr2_http`, and `httr2_error`, so handlers
written for earlier versions keep working.

Requests that time out, fail to connect, or get a 429, 502, 503, or 504
response are retried up to three times before an error is raised.

## Examples

``` r
if (FALSE) { # \dontrun{
tryCatch(
  tm_stops("Purple"),
  transitmattr_not_found = function(e) {
    message("No such route: ", conditionMessage(e))
    NULL
  }
)
} # }
```
