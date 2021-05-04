map_2010_forest_conversion <- function(forest) {
  world <- sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE)) %>%
    mutate(ID = ifelse(ID == "USA", "United States", ID))

  forest <- forest %>% filter(year == 2010, entity != "World")

  world %>%
    left_join(forest, by = c("ID" = "entity")) %>%
    sf::st_as_sf() %>%
    filter(ID != "Antarctica") %>%
    ggplot(aes(fill = net_forest_conversion)) +
    geom_sf(color = "grey90", size = 0.1) +
    cowplot::theme_map() +
    scico::scale_fill_scico(
      palette = "imola",
      labels = scales::comma,
      breaks = c(-1300000, -650000, 0, 650000, 1300000)
    )
}
