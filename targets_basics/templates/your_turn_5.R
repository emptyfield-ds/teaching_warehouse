library(targets)
library(tarchetypes)

tar_option_set(packages = c("tidyverse", "gtsummary"))
options(tidyverse.quiet = TRUE)
source("R/functions.R")

tar_plan(
  tar_file(diabetes_file, "diabetes.csv"),
  diabetes = read_csv(diabetes_file, col_types = cols()) %>%
    mutate(diabetic = ifelse(glyhb >= 6.5, "Diabetic", "Healthy")),
  table_one = create_table_one(diabetes)
)
