modules <- c(
  "intro",
  "reading_data",
  "dplyr_5verbs",
  "ggplot_basics",
  "ggplot_customizing",
  "ggplot_recreate_challenge",
  "tidyr_basics",
  "modeling_and_broom",
  "types_and_functions",
  "purrr_basics",
  "quarto_basics",
  "quarto_whole_game",
  # because I usually touch these too when updating the above
  "py_quarto_basics",
  "py_quarto_whole_game",
  "ds_whole_game",
  "tidy_tuesday"
)

purrr::walk(modules, shunyata::sync_module)
