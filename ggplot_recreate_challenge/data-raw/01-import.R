#=====================================================================#
# This is code to create: 01-import.R
# Authored by and feedback to: @mjfrigaard
# MIT License
# Version: 1.0
#=====================================================================#

# ‹(•_•)› PACKAGES ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
library(tidyverse)

# ‹(•_•)› IMPORT ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
# https://github.com/Financial-Times/coronavirus-excess-mortality-data
raw_ft_excess_deaths <- read_csv(
  "https://raw.githubusercontent.com/Financial-Times/coronavirus-excess-mortality-data/master/data/ft_excess_deaths.csv"
)

# ‹(•_•)› WRANGLE ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
# FILTER the countries ----------------------------------------
# UK, Austria, Belgium, Brazil, Chile, Denmark, Ecuador, France, Germany,
# Iceland, Israel, Italy, Netherlands, Norway, Peru, Portugal, South Africa,
# Spain, Sweden, Switzerland, and US

ft_countries <- c(
  "UK", "Austria", "Belgium", "Brazil",
  "Chile", "Denmark", "Ecuador", "France",
  "Germany", "Iceland", "Israel", "Italy",
  "Netherlands", "Norway", "Peru", "Portugal",
  "South Africa", "Spain", "Sweden",
  "Switzerland", "US"
)

ft_excess_deaths <- raw_ft_excess_deaths %>%
  filter(country %in% ft_countries)

# ‹(•_•)› EXPORT ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
write_csv(
  ft_excess_deaths,
  "ggplot_recreate_challenge/data/ft_excess_deaths.csv"
)
