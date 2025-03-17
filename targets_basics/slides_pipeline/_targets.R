library(targets)
options(tidyverse.quiet = TRUE)
tar_option_set(packages = "tidyverse")
source("R/slide_functions")

list(
  tar_target(gapminder_file, "gapminder.csv", format = "file"),
  tar_target(gapminder, read_csv(gapminder_file, col_types = cols())),
  tar_target(plot, create_line_plot(gapminder))
)
