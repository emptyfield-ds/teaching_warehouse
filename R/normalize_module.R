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

set_remote <- function(module) {
  module <- glue::glue("https://github.com/emptyfield-ds/{module}.git")
  # TODO: check if exists
  gert::git_remote_add(module)
}

force_push <- function() {
  msg <- glue::glue("Render module: {Sys.time()}")
  usethis::ui_done("Force pushing")
  gert::git_add(".")
  gert::git_commit(msg)
  gert::git_push(force = TRUE)
  code_for_cloud <- glue::glue(
    "git fetch
    git reset origin/{usethis::git_branch_default()} --hard
    git pull
    "
  )
  usethis::ui_todo("Update git on RStudio Cloud")
  usethis::ui_code_block(code_for_cloud)
}

normalize_module <- function(module) {
  destdir <- path(getOption("usethis.destdir"), module)
  new_module <- copy_module(module)
  with_dir(new_module, {
    render_slides(new_module, path_ext_set(module, "Rmd"))
    sanitize_module(new_module, destdir, overwrite = TRUE)
  })

  dir_delete(new_module)

  with_dir(destdir, {
    set_local_proj(destdir)
    gert::git_init()
    set_remote(module)
    force_push()
  })
  proj_activate(destdir)
}


module <- "renv_basics"
normalize_module(module)
emptyfield::browse_cloud(module)
