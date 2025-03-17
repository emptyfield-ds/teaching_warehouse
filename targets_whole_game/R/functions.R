map_2010_forest_conversion <- function(forest) {
  world <- sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE)) |>
    mutate(ID = ifelse(ID == "USA", "United States", ID))

  forest <- forest |> filter(year == 2010, entity != "World")

  world |>
    left_join(forest, by = c("ID" = "entity")) |>
    sf::st_as_sf() |>
    filter(ID != "Antarctica") |>
    ggplot(aes(fill = net_forest_conversion)) +
    geom_sf(color = "white", size = 0.1) +
    cowplot::theme_map() +
    scico::scale_fill_scico(
      palette = "romaO",
      begin = .21,
      end = .85,
      na.value = "grey80"
    ) +
    theme(legend.position = "none")
}

barplot_top_10_change <- function(forest) {
  forest |>
    filter(year == 2010, entity != "World") |>
    slice_max(abs(net_forest_conversion), n = 10) |>
    arrange(net_forest_conversion) |>
    mutate(entity = fct_inorder(entity)) |>
    ggplot(aes(
      x = net_forest_conversion,
      y = entity,
      fill = net_forest_conversion
    )) +
    geom_col() +
    scico::scale_fill_scico(palette = "romaO", begin = .21, end = .85) +
    scale_x_continuous(
      name = "Net Forest Conversion (ha) in 2010",
      labels = c("-1M", "0", "+1M", "+2M"),
      breaks = c(-1e6, 0, 1e6, 2e6)
    ) +
    cowplot::theme_minimal_vgrid() +
    theme(
      axis.title.y = element_blank(),
      legend.position = "none"
    )
}

plot_top_change_2010 <- function(forest) {
  map_2010_forest_conversion(forest) /
    (
      plot_spacer() +
        barplot_top_10_change(forest) +
        plot_spacer() +
        plot_layout(widths = c(1, 8, 1))
    ) +
    plot_layout(heights = c(2, 1))
}

clean_2010_causes <- function(brazil_loss) {
  brazil_loss |>
    filter(year == 2010) |>
    select(-entity:-year) |>
    pivot_longer(everything(), names_to = "cause", values_to = "hectacres") |>
    arrange(desc(hectacres)) |>
    mutate(cause = to_sentence(cause))
}

to_sentence <- function(x) {
  str_to_sentence(str_replace_all(x, "_", " "))
}

label_sentence <- function(x) {
  str_wrap(to_sentence(x), width = 15)
}

table_brazil_causes <- function(brazil_causes_2010) {
  gt(
    brazil_causes_2010,
    caption = "Causes of Brazilian forest loss in 2010"
  ) |>
    fmt_number(hectacres, decimals = 0) |>
    summary_rows(
      columns = hectacres,
      fns = list(Total = "sum"),
      decimals = 0,
      missing_text = ""
    ) |>
    cols_label(cause = md("*Cause*"), hectacres = md("*Hectacres*"))
}

plot_cause_hist <- function(brazil_loss) {
  brazil_loss |>
    select(-entity, -code) |>
    pivot_longer(-year, names_to = "cause", values_to = "hectacres") |>
    arrange(desc(hectacres)) |>
    mutate(cause = fct_inorder(cause)) |>
    ggplot(aes(x = year, y = hectacres)) +
    geom_col(
      data = function(x) select(x, -cause),
      mapping = aes(fill = "all data"),
      alpha = .9
    ) +
    geom_col(aes(fill = "cause"), alpha = .9) +
    facet_wrap(~ cause, labeller = as_labeller(label_sentence)) +
    cowplot::theme_minimal_hgrid() +
    theme(legend.position = "bottom", legend.justification = "center") +
    scale_y_continuous(
      name = "forest loss (ha)",
      breaks = c(0, 1e6, 2e6, 3e6, 4e6),
      labels = c("0", "1M", "2M", "3M", "4M")
    ) +
    scale_x_continuous(breaks = scales::pretty_breaks()) +
    scale_fill_manual(
      name = "",
      values = c("all data" = "grey70", "cause" = "#CC79A7")
    )
}
