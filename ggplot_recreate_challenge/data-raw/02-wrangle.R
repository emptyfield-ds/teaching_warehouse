#=====================================================================#
# This is code to create: 02-wrangle.R
# Authored by and feedback to: @mjfrigaard
# MIT License
# Version: 1.0
#=====================================================================#

# ‹(•_•)› PACKAGES ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
library(tidyverse)
library(janitor)
library(skimr)


# options -----------------------------------------------------------------
options(tibble.print_max = 50)

# ‹(•_•)› IMPORT ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
# see 01-import.R for more details.
# import this from local
ft_excess_deaths <- readr::read_csv("ggplot_recreate_challenge/data/ft_excess_deaths.csv")


# VIEW DATA ----
# View(ft_excess_deaths)

# View the data -----------------------------------------------------------

# get a glimpse of the data
ft_excess_deaths |> glimpse(78)

# get a skim of the data
ft_excess_deaths |> skimr::skim()


# >>>>> CREATE LINE PLOT FOR A SINGLE COUNTRY <<<<< --------------------------
# We can see from the figure that we want time on the x axis (either as a date
# or month) and the y axis will be deaths. Why don't we start with a single
# country (UK) and recreate the line graph

# create UKExcessDeaths ----
UKExcessDeaths <- ft_excess_deaths |>
  dplyr::filter(country == "UK")

# create UKExcessDeathsPrior ----
UKExcessDeathsPrior <- UKExcessDeaths |>
  dplyr::filter(year != 2020)
# how many years do we have data for?
# (what do we expect to see?)
UKExcessDeathsPrior |>
  dplyr::count(year, sort = TRUE)
# there should be nine years of data in this tibble

# UKExcessDeathsPriorWk ~~ GROUP BY & SUMMARIZE deaths by week/year --------------
# Our final plot will have deaths on the y axis, and weeks across the x, so
# we'll calculate the mean number of deaths per week and year by grouping the
# dataset by week and year and summarizing mean deaths
UKExcessDeathsPriorWk <- UKExcessDeathsPrior |>
  dplyr::group_by(week, year) |>
    dplyr::summarize(deaths = mean(deaths, na.rm = TRUE)) |>
    # create a numeric week
    dplyr::mutate(week = as.numeric(week),
    # We will want a separate gray line for each prior year, so we need the year
    # variable to be a factor
                  year = factor(year))


# create UKExcessDeaths2020 ----
UKExcessDeaths2020 <- UKExcessDeaths |>
  dplyr::filter(year == 2020)

UKExcessDeaths2020 |>
  dplyr::count(year, sort = TRUE)
# this should only be 2020

# UKExcessDeaths2020Wk ~~ GROUP BY & SUMMARIZE deaths by week/year --------------
# Our final plot will have deaths on the y axis, and weeks across the x, so
# we'll calculate the mean number of deaths per week and year by grouping the
# dataset by week and year and summarizing mean deaths and expected_deaths
UKExcessDeaths2020Wk <- UKExcessDeaths2020 |>
  dplyr::group_by(week, year) |>
    dplyr::summarize(deaths = mean(deaths, na.rm = TRUE),
                     expected_deaths = mean(expected_deaths, na.rm = TRUE)) |>
    # to plot the weeks along the x axis in order, we will
    # want this to be numeric
    dplyr::mutate(week = as.numeric(week),
                  year = factor(year))

# UKExcessDeathsWk ~~ GROUP BY & SUMMARIZE deaths by week/year -----------------
# Our final plot will have deaths on the y axis, and weeks across the x, so
# we'll calculate the average number of deaths per week and year by grouping the
# dataset by week and summarizing average death
UKExcessDeathsWk <- UKExcessDeaths |>
  # these are historical, so we will remove the 2020 data
  dplyr::filter(year != 2020) |>
  # note this is not by week and year, just week!
  dplyr::group_by(week) |>
    dplyr::summarize(deaths = mean(deaths, na.rm = TRUE)) |>
      dplyr::mutate(week = as.numeric(week))



# >>>>> REPEAT THIS PROCESS FOR ENTIRE DATASET <<<<< --------------------------
# create ExcessDeaths2020Wk ----
ExcessDeaths2020Wk <- ft_excess_deaths |>
  dplyr::filter(year == 2020) |>
# ~~~ GROUP BY & SUMMARIZE deaths by week/year -------------
# Our final plot will have deaths on the y axis, and weeks across the x, so
# we'll calculate the mean number of deaths per country, week, and year by
# grouping the dataset by country, week, and year and summarizing the mean
# deaths and expected_deaths
  dplyr::group_by(country, week, year) |>
    dplyr::summarize(deaths = mean(deaths, na.rm = TRUE),
                     expected_deaths = mean(expected_deaths, na.rm = TRUE)) |>
  dplyr::mutate(week = as.numeric(week),
                # ~~ factor years ------
                year = factor(year))


# create ExcessDeathsPriorWk ----
ExcessDeathsPriorWk <- ft_excess_deaths |>
  dplyr::filter(year != 2020) |>
# ExcessDeathsPriorWk ~~~ GROUP BY & SUMMARIZE deaths by week/year -------------
# Our final plot will have deaths on the y axis, and weeks across the x, so
# we'll calculate the mean number of deaths per week and year by grouping the
# dataset by country, week, and year and summarizing the mean deaths
  dplyr::group_by(country, week, year) |>
    dplyr::summarize(deaths = mean(deaths, na.rm = TRUE)) |>
    dplyr::mutate(week = as.numeric(week),
                 # ~~ factor years ------
                year = factor(year))


# create ft_excess_deathsWk ----------------------------------------------------
# first create numeric/factor variables
ft_excess_deathsWk <- ft_excess_deaths |>
#  ~~~ GROUP BY & SUMMARIZE deaths by week/year -------------
# Our final plot will have deaths on the y axis, and weeks across the x, so
# we'll calculate the mean number of deaths per country and week by grouping
# the dataset by country and week and summarizing the mean deaths
# these are historical, so we will remove the 2020 data
  dplyr::filter(year != 2020) |>
  # only grouped by country and week
  dplyr::group_by(country, week) |>
    dplyr::summarize(deaths = mean(deaths, na.rm = TRUE)) |>
    # ~~ numeric week -----
    dplyr::mutate(week = as.numeric(week))



