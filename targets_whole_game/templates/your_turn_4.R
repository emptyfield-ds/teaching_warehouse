library(targets)
library(tarchetypes)
options(tidyverse.quiet = TRUE)

# load packages prior to our pipeline
# this is the same as including a script that calls `library()` for each package
tar_option_set(packages = c("tidyverse", "maps", "sf", "scico"))
source("R/functions.R")

# end your _targets.R file with a list of targets
tar_plan(
  tar_file(forest_file, "data/forest.csv"),
  forest = read_csv(forest_file),
  forest_map = map_2010_forest_conversion(forest),
  top10_barplot = barplot_top_10_change(forest)
)
