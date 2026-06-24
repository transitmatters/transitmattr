## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = TRUE   # set to TRUE locally to actually hit the API
)

## ----load---------------------------------------------------------------------
library(transitmattr)
library(dplyr)
library(ggplot2)

## ----ridership-pull-----------------------------------------------------------
ridership_raw <- tm_ridership(
  start_date = "2024-01-01",
  end_date   = "2024-01-31",
  line_id    = "line-Red"
)

## ----ridership-df-------------------------------------------------------------
library(dplyr)
ridership_df <- bind_rows(ridership_raw)
head(ridership_df)

## ----ridership-cols-----------------------------------------------------------
glimpse(ridership_df)

## ----ridership-plot-----------------------------------------------------------
library(ggplot2)
ggplot(ridership_df, aes(x = as.Date(date), y = count)) +
  geom_col(fill = "#DA291C") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Red Line Daily Ridership",
    subtitle = "January 2024",
    x = NULL,
    y = "Riders"
  ) +
  theme_minimal()

