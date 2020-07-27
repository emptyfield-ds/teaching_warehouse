#=====================================================================#
# This is code to create: dplyr-5verbs-01.R
# Authored by and feedback to:
# MIT License
# Version:
#=====================================================================#

# packages ----
library(tidyverse)
library(gapminder)

# across() with mutate() single function ----
mutate(diamonds, across(c("price", "carat"), ~ mean(.x)))

# across() with mutate() multiple functions ----
mutate(diamonds,
       across(c("carat", "depth"), list(sd = sd, mean = mean)))

# across() with mutate() and where() ----
mutate(gapminder,
   across(where(is.numeric), list(mean = mean, median = median)))
