plot_penguins <- function(data) {
  ggplot(data, aes(x = flipper_len, y = body_mass, color = species)) +
    geom_point() +
    labs(
      title = "Penguin Flipper Length vs Body Mass",
      x = "Flipper Length (mm)",
      y = "Body Mass (g)"
    ) +
    theme_minimal()
}