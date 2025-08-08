cheatsheets <- c(
  "dplyr_5verbs/cheatsheet_data-transformation.pdf",
  "ggplot_basics/cheatsheet_data-visualization.pdf",
  "ggplot_customizing/cheatsheet_data-visualization.pdf",
  "ggplot_recreate_challenge/cheatsheet_data-visualization.pdf",
  "intro/cheatsheet_sas-to-r.pdf",
  "intro/cheatsheet_stata-to-r.pdf",
  "modeling_and_broom/cheatsheet_base-r.pdf",
  "purrr_basics/cheatsheet_purrr.pdf",
  "reading_data/cheatsheet_data-import.pdf",
  "rmarkdown_basics/cheatsheet_rmarkdown.pdf",
  "rmarkdown_figures/cheatsheet_rmarkdown.pdf",
  "rmarkdown_tables/cheatsheet_rmarkdown.pdf",
  "shiny_adv_reactivity/cheatsheet_shiny.pdf",
  "shiny_basics/cheatsheet_shiny.pdf",
  "shiny_challenge/cheatsheet_shiny.pdf",
  "shiny_dashboards/cheatsheet_shiny.pdf",
  "shiny_design_ui/cheatsheet_shiny.pdf",
  "shiny_reactivity/cheatsheet_shiny.pdf",
  "tidy_tuesday/cheatsheet_data-visualization.pdf",
  "tidyr_basics/cheatsheet_data-import.pdf",
  "types_and_functions/cheatsheet_base-r.pdf"
)

download_cheatsheet <- function(.file) {
  cheatsheet <- fs::path_file(.file)
  cheatsheet <- sub("cheatsheet\\_", "", cheatsheet)
  if (cheatsheet == "sas-to-r.pdf") {
    cheatsheet <- "sas-r.pdf"
  } else if (cheatsheet == "stata-to-r.pdf") {
    cheatsheet <- "stata2r.pdf"
  }

  usethis::ui_done("Downloading {cheatsheet}")
  usethis:::download_url(
    glue::glue(
      "https://github.com/rstudio/cheatsheets/raw/master/{cheatsheet}"
    ),
    .file
  )
  cat("\n")
}

purrr::walk(cheatsheets, download_cheatsheet)

modules <- c(
  "dplyr_5verbs",
  "ggplot_basics",
  "ggplot_customizing",
  "ggplot_recreate_challenge",
  "intro",
  "modeling_and_broom",
  "purrr_basics",
  "reading_data",
  "rmarkdown_basics",
  "rmarkdown_figures",
  "rmarkdown_tables",
  "shiny_basics",
  # other shiny modules not currently hosted,
  "tidy_tuesday",
  "tidyr_basics",
  "types_and_functions"
)


purrr::walk(modules, shunyata::sync_module)
