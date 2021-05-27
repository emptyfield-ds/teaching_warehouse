library(fs)
library(coursedeployr)
library(tidyverse)
library(withr)
library(usethis)


copy_module <- function(dir) {
  new_dir <- path_temp(dir)
  if (dir_exists(new_dir)) dir_delete(new_dir)
  ui_done("Copying {ui_path(dir)} to {ui_path(new_dir)}")
  dir_copy(dir, new_dir)
}

set_local_proj <- function(path = getwd()) {
  defer(proj_set("/Users/malcolmbarrett/Google Drive/Active/r_teaching_warehouse"))
  proj_set(path, force = TRUE)
  use_rstudio()
}

normalize_module <- function(module) {
  destdir <- path(getOption("usethis.destdir"), module)
  new_module <- copy_module(module)
  with_dir(new_module, {
    render_slides(new_module, path_ext_set(module, "Rmd"))
    sanitize_module(new_module, destdir, overwrite = TRUE)
    set_local_proj(new_module)
  })
  dir_delete(new_module)
  proj_activate(destdir)
}

normalize_module("rmarkdown_figures")
