library(dplyr)
library(datasets)
library(lubridate)
library(plotly)

states_info <- data.frame('StateName' = c('District of Columbia', state.name)
                          ,'StateAbb' = c('DC', state.abb))

store_df <- read.csv('./data/Sample - Superstore.csv') %>%
              mutate(Order.Date = as.Date(Order.Date, format = '%m/%d/%Y'),
                     Ship.Date = as.Date(Order.Date, format = '%m/%d/%Y')) %>%
              left_join(states_info, by = c('State' = 'StateName'))