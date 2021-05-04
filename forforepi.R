library(fs)
library(coursedeployr)
library(tidyverse)
library(withr)

pad0 <- function(x) {
  stringr::str_pad(x, 2, pad = "0")
}

copy_module <- function(dir, num, path) {
  new_dir <- path(path, paste0(pad0(num), "-", dir))
  usethis::ui_done("Copying {dir} to {new_dir}")
  fs::dir_copy(dir, new_dir)
}

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
  "rmarkdown_whole_game",
  "rmarkdown_basics",
  "ds_whole_game",
  "shiny_basics",
  "shiny_challenge",
  "shiny_challenge",
  "r_best_practices"
)

rforepi <- "/Users/malcolmbarrett/Desktop/rforepi"

if (dir_exists(rforepi)) dir_delete(rforepi)

dir_create(rforepi)

walk2(
  modules,
  seq_along(modules) - 1,
  copy_module,
  path = rforepi
)

with_dir(rforepi, {
  walk2(
    dir_ls(),
    path(dir_ls(), paste0(modules, ".Rmd")),
    render_slides
  )
})

with_dir(rforepi, {
  rforepi2 <- paste(rforepi, 2)
  if (dir_exists(rforepi2)) dir_delete(rforepi2)
  walk2(
    dir_ls(),
    path(rforepi2, dir_ls()),
    sanitize_module
  )
})
