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
  "tidy_tuesday",
  "types_and_functions",
  "purrr_basics",
  "rmarkdown_basics",
  "shiny_basics",
  "shiny_challenge",
  "r_best_practices"
)

course_dir <- "/Users/malcolmbarrett/Desktop/au-intro-r-sp21"

if (dir_exists(course_dir)) dir_delete(course_dir)

walk2(
  modules,
  seq_along(modules) - 1,
  copy_module,
  path = course_dir
)

with_dir(course_dir, {
  walk2(
    dir_ls(),
    path(dir_ls(), paste0(modules, ".Rmd")),
    render_slides
  )
})

with_dir(course_dir, {
  rforepi2 <- paste(course_dir, 2)
  if (dir_exists(rforepi2)) dir_delete(rforepi2)
  walk2(
    dir_ls(),
    path(rforepi2, dir_ls()),
    sanitize_module
  )
})

set_local_proj <- function(path) {
  usethis::create_project(path, open = FALSE)
  r_folder <- path(path, "R")
  if (dir_exists(r_folder)) dir_delete(r_folder)
}

old <- usethis::proj_get()

with_dir(paste(course_dir, 2), {
  walk(
    dir_ls(),
    set_local_proj
  )
})

usethis::proj_set(old)
