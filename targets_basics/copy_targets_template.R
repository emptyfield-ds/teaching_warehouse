copy_targets_template <- function(template) {
  copied <- file.copy(
    file.path("templates", template),
    "_targets.R",
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
  targets_r <- usethis::ui_path("_targets.R")
  usethis::ui_done("Copying {template_r} to {targets_r}")
}
