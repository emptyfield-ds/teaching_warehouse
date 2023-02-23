
copy_qmd_template <- function(template) {
  if (template == "your_turn_3.qmd") {
    file.copy(
      file.path("templates", "references.bib"),
      "references.bib",
      overwrite = TRUE
    )
  }
  copied <- file.copy(
    file.path("templates", template),
    "whole_game.qmd",
    overwrite = TRUE
  )

  if (!copied) {
    stop(
      file.path("templates", template), " not found. ",
      "Are you sure you're in the right working directory?",
      call. = FALSE
    )
  }

  template_r <- usethis::ui_path(file.path("templates", template))
  targets_r <- usethis::ui_path("whole_game.qmd")
  usethis::ui_done("Copying {template_r} to {targets_r}")
}
