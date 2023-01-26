labs_wrap <- function(..., width = 80) {
  x <- tibble::enframe(c(...))
  x <- x |>
    dplyr::mutate(value = stringr::str_wrap(value, width = width)) |>
    tibble::deframe() |>
    as.list()

  ggplot2::labs(!!!x)
}

# tell R that we that `value` is a valid variable.
# `utils::globalVariables()` is often helpful when
# we're using non-standard evaluation, as is common
# in the tidyverse
utils::globalVariables(c("value"))
