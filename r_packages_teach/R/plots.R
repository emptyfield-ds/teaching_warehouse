#' Plot donation counts by sector
#'
#' @param ... Arguments passed to [`count_donations()`]
#'
#' @return a ggplot
#' @export
#'
#' @examples
#'
#' plot_donations()
#'
plot_donations <- function(...) {
  x <- count_donations(...)

  ggplot2::ggplot(x, ggplot2::aes(
    forcats::fct_reorder(.data$sector, .data$donations),
    .data$donations)
  ) +
    ggplot2::geom_col() +
    ggplot2::coord_flip() +
    ggplot2::xlab("sector") +
    theme_avalanche_v()
}
