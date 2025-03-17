library(targets)
library(tarchetypes)

tar_option_set(packages = "tidyverse")
options(tidyverse.quiet = TRUE)

tar_plan(
  tar_file(diabetes_file, "diabetes.csv"),
  diabetes = read_csv(diabetes_file, col_types = cols()) |>
    mutate(diabetic = ifelse(glyhb >= 6.5, "Diabetic", "Healthy"))
)
