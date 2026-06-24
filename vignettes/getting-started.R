## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)

## ----install, eval = FALSE----------------------------------------------------
# # install.packages("pak")  # run this once if you don't have pak
# pak::pak("transitmatters/transitmattr")

## ----load---------------------------------------------------------------------
library(transitmattr)
library(dplyr)
library(ggplot2)

## ----healthcheck, eval = FALSE------------------------------------------------
# tm_healthcheck()

## ----list-example, eval = FALSE-----------------------------------------------
# result <- tm_headways("2024-01-15")
# 
# # See what's inside:
# names(result)
# 
# # Grab one piece:
# result$headways

## ----str-example, eval = FALSE------------------------------------------------
# str(result, max.level = 2)

## ----routes-stops, eval = FALSE-----------------------------------------------
# # All available routes, grouped by mode
# routes <- tm_routes()
# names(routes)  # "rapid_transit" "bus" "commuter_rail" "ferry"
# 
# # Stop IDs for a specific route (needed for filtering headways, travel times, etc.)
# red_stops <- tm_stops("line-red")

## ----single-day, eval = FALSE-------------------------------------------------
# # Headways for all stops on a day
# headways_all <- tm_headways("2024-01-15")
# 
# # Headways for one stop (or a vector of stops)
# headways <- tm_headways("2024-01-15", stop = "70061")
# headways <- tm_headways("2024-01-15", stop = c("70061", "70063"))
# 
# # Dwell times, optionally filtered by stop
# dwells <- tm_dwells("2024-01-15", stop = "70061")
# 
# # Travel times between a specific stop pair
# travel <- tm_travel_times("2024-01-15", from_stop = "70076", to_stop = "70064")
# 
# # Alerts (service disruptions)
# alerts <- tm_alerts("2024-01-15")

## ----range, eval = FALSE------------------------------------------------------
# # Daily Red Line ridership for January 2024
# ridership <- tm_ridership(
#   start_date = "2024-01-01",
#   end_date   = "2024-01-31",
#   line_id    = "line-red"
# )
# 
# # Daily trip metrics for the Red Line
# trips <- tm_trip_metrics(
#   start_date = "2024-01-01",
#   end_date   = "2024-01-31",
#   agg        = "daily",
#   line       = "line-red"
# )

## ----to-df, eval = FALSE------------------------------------------------------
# library(dplyr)
# library(transitmattr)
# 
# # Pull ridership data
# ridership_raw <- tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red")
# 
# # Each item in ridership_raw is one record — bind them into rows
# ridership_df <- bind_rows(ridership_raw)
# 
# # Now it looks like a spreadsheet
# head(ridership_df)

## ----plot, eval = FALSE-------------------------------------------------------
# library(ggplot2)
# library(dplyr)
# library(transitmattr)
# 
# ridership_df <- bind_rows(
#   tm_ridership("2024-01-01", "2024-01-31", line_id = "line-red")
# )
# 
# ggplot(ridership_df, aes(x = as.Date(date), y = count)) +
#   geom_line(color = "#DA291C") +   # Red Line color
#   labs(
#     title = "Red Line Daily Ridership — January 2024",
#     x     = "Date",
#     y     = "Riders"
#   ) +
#   theme_minimal()

