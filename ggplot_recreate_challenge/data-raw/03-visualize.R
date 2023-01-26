#=====================================================================#
# This is code to create: 03-visualize.R
# Authored by and feedback to: @mjfrigaard
# MIT License
# Version: 1.0
#=====================================================================#

# ‹(•_•)› PACKAGES ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
library(tidyverse)
library(janitor)
library(skimr)

# ‹(•_•)› IMPORT ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––√\/  ----
source("2020-07-updates/ggplot_recreate_challenge/02-wrangle.R")

# ‹(•_•)› VISUALIZE ––•––•––√\/––√\/––•––•––√\/––√\/––•––•––√\/––  ----

uk_labs <- ggplot2::labs(x = "Date", y = "Deaths",
                title = "Death rates in UK compared to historical averages",
       subtitle = "Number of deaths per week from all causes vs. recent years")

# Now we can plot the mean deaths per week and year for the UK
# gg_uk_recent_years ----
gg_uk_recent_years <- UKExcessDeathsPriorWk |>
  ggplot(aes(x = week,
             y = deaths,
             group = year)) +

  geom_line(color = "grey75",
            alpha = 3/5)

gg_uk_recent_years + uk_labs

# gg_uk_excess_deaths ----
gg_uk_excess_deaths <- gg_uk_recent_years +

    geom_line(data = UKExcessDeaths2020Wk,

              aes(
                x = week,
                y = deaths,
                group = year
                 ),

              color = "firebrick")

gg_uk_excess_deaths

# gg_uk_total_excess_deaths ----
gg_uk_total_excess_deaths <- gg_uk_excess_deaths +

    geom_ribbon(data = UKExcessDeaths2020Wk,

                aes(
                  ymin = expected_deaths,
                  ymax = deaths
                  ),

                fill = "tomato",

                alpha = 1/2)

gg_uk_total_excess_deaths

# gg_uk_historical_average ----

gg_uk_historical_average <- gg_uk_total_excess_deaths +

    geom_line(data = UKExcessDeathsWk,

              inherit.aes = FALSE,

            aes(
                x = week,
                y = deaths
                ),

             color = "black")

# uk_labs and ftplottools::ft_theme() ----
gg_uk_historical_average +

    ftplottools::ft_theme() +

  uk_labs

# >>>>> REPEAT THIS PLOT FOR ENTIRE DATASET <<<<< --------------------------

# Now we can plot the mean deaths

labs <- ggplot2::labs(x = "Date", y = "Deaths",
                title = "Death rates compared to historical averages",
       subtitle = "Number of deaths per week from all causes vs. recent years")


# create gg_facet_by_country ----------------------------------------------
# previous years (gray lines) ----
# this is the first layer of multiple gray lines. we'll be mapping the deaths
# per week from all previous years, so remember which variable will be the
# grouping variable
gg_facet_by_country <- ggplot(data = ExcessDeathsPriorWk,
               aes(
                   x = week,
                   y = deaths,
                   group = year
                   )) +
  # add the "grey75" to the and alpha level for transparency
  geom_line(color = "grey75",
            alpha = 3/5) +

# 2020 excess deaths  ----
# these are the deaths from 2020 (the coronavirus data) stored in
# ExcessDeaths2020Wk
    geom_line(data = ExcessDeaths2020Wk,
                aes(
                    x = week,
                    y = deaths,
                group = year
                    ),
  # the color here is the "firebrick"
              color = "firebrick") +

# total excess deaths  ----
# here we have the area (ribbon) with the same ExcessDeaths2020Wk

    geom_ribbon(data = ExcessDeaths2020Wk,
# the ymin and ymax variables are expected_deaths and deaths, respectively.
                aes(
                    ymin = expected_deaths,
                    ymax = deaths
                    ),
# the color here is "tomato"
                    fill = "tomato",
# the alpha setting here is 1/2
                    alpha = 1/2) +

# historical averages  ----
# these is the data from FtExcessDeathsWk (grouped only on country and week)
    geom_line(data = FtExcessDeathsWk,
# remove the inherited aesthetics from the previous layers
              inherit.aes = FALSE,
# here we're only mapping an x and y variable
            aes(
                x = week,
                y = deaths
                ),
# set the color to "black"
             color = "black") +

# facet by country  ----
# use facet_wrap to facet this by country, and set the scales to "free"
    facet_wrap(. ~ country,
               scales = "free")

# add labels ----
gg_facet_by_country + labs

# add theme ---------------------------------------------------------------

my_theme <- theme(plot.background =
             element_rect(fill = "#FFF1E5"),

          panel.background =
              element_rect(fill = "#FFF1E5"),

          panel.grid = element_line(color = "grey90"),

          axis.text =
            element_text(family = "Ubuntu",
                                   size = 7),

          axis.title =
            element_text(family = "Ubuntu",
                                    size = 11),

          panel.border =
            element_blank(),

          strip.background = element_blank(),

          plot.title = element_text(family = "Verdana",
                                    size = 15)

          )


# combine theme and labels ------------------------------------------------

gg_facet_by_country + my_theme + labs



