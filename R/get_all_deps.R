library(shunyata)
pkgs <- get_all_deps(c(
  "rmarkdown_figures",
  "targets_whole_game",
  "targets_basics"
))
dput(pkgs)
