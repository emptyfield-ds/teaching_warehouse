library(targets)
library(tarchetypes)

tar_option_set(packages = c("tidyverse", "gtsummary", "patchwork"))
options(tidyverse.quiet = TRUE)
source("R/functions.R")

tar_plan(
  tar_file(diabetes_file, "diabetes.csv"),
  diabetes = read_csv(diabetes_file, col_types = cols()) |>
    mutate(diabetic = ifelse(glyhb >= 6.5, "Diabetic", "Healthy")),
  description = listify_descriptions(diabetes),
  table_one = create_table_one(diabetes),
  figure_one = create_figure_one(diabetes),
  table_two = create_table_two(diabetes)
)
