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
raw_ft_excess_deaths <- readr::read_csv("https://raw.githubusercontent.com/Financial-Times/coronavirus-excess-mortality-data/master/data/ft_excess_deaths.csv")

# CLEAN NAMES ----
# janitor::clean_names()
# normally this is required, but these variables look ok!

# ‹(•_•)› WRANGLE ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
# FILTER the countries ----------------------------------------
# UK, Austria, Belgium, Brazil, Chile, Denmark, Ecuador, France, Germany,
# Iceland, Israel, Italy, Netherlands, Norway, Peru, Portugal, South Africa,
# Spain, Sweden, Switzerland, and US

ft_countries <- c("UK", "Austria", "Belgium", "Brazil",
                  "Chile", "Denmark", "Ecuador", "France",
                  "Germany", "Iceland", "Israel", "Italy",
                  "Netherlands", "Norway", "Peru", "Portugal",
                  "South Africa", "Spain", "Sweden",
                  "Switzerland", "US")

FtExcessDeaths <- FtExcessDeaths %>%
  dplyr::filter(country %in% ft_countries)

# COUNT countries ---------------------------------------------------------
# how many countries do we have?
FtExcessDeaths %>% dplyr::count(country, sort = TRUE)

# ‹(•_•)› EXPORT ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
readr::write_csv(as.data.frame(FtExcessDeaths),
    path = "2020-07-updates/ggplot_recreate_challenge/FtExcessDeaths.csv")
