read_deps <- function(module) {
  url <- glue::glue("https://raw.githubusercontent.com/emptyfield-ds/{module}/HEAD/.deps")
  readLines(url, encoding = "UTF-8", warn = FALSE)
}

get_all_deps <- function(modules) {
  sort(unique(purrr::flatten_chr(purrr::map(modules, read_deps))))
}

pkgs <- get_all_deps(c("rmarkdown_figures", "targets_whole_game", "targets_basics"))
dput(pkgs)
