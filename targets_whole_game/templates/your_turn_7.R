library(targets)
library(tarchetypes)
options(tidyverse.quiet = TRUE)

# load packages prior to our pipeline
# this is the same as including a script that calls `library()` for each package
tar_option_set(packages = c("tidyverse", "maps", "sf", "scico", "patchwork", "gt"))

source("R/functions.R")

# end your _targets.R file with a list of targets
tar_plan(
  tar_file(forest_file, "data/forest.csv"),
  tar_file(brazil_loss_file, "data/brazil_loss.csv"),
  forest = read_csv(forest_file),
  brazil_loss = read_csv(brazil_loss_file),
  forest_map = plot_top_change_2010(forest),
  brazil_causes_2010 = clean_2010_causes(brazil_loss),
  brazil_causes_table = table_brazil_causes(brazil_causes_2010),
  brazil_causes_hist = plot_cause_hist(brazil_loss),
  tar_quarto(report, "whole_game.qmd")
)
