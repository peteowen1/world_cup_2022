library(XML)
library(RCurl)
library(rvest)
library(tidyverse)

wc_538_df <- read_csv("https://projects.fivethirtyeight.com/soccer-api/international/2022/wc_forecasts.csv") %>%
  filter(forecast_timestamp == max(forecast_timestamp))

#### aanm analysis
aanm_teams <- c('Morocco','Mexico','Japan','USA','Senegal','Canada','South Korea','Tunisia','Saudi Arabia','Iran','Cameroon','Ghana','Qatar')

aanm_538_df <- wc_538_df %>% filter(team %in% aanm_teams) %>%
  mutate(no_qf = 1-make_quarters)

aanm_538_df %>% select(team,make_quarters)

1-prod(aanm_538_df$no_qf)
