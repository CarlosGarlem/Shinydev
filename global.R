library(dplyr)

store_df <- read.csv('./data/Sample - Superstore.csv') %>%
  mutate(Order.Date = as.Date(Order.Date, format = '%m/%d/%Y'),
         Ship.Date = as.Date(Order.Date, format = '%m/%d/%Y'))