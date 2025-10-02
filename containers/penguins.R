library(ggplot2)
p <- penguins |>
  ggplot(aes(x = flipper_len, y = body_mass, color = species)) +
  geom_point() +
  labs(
    title = "Penguin Flipper Length vs Body Mass",
    x = "Flipper Length (mm)",
    y = "Body Mass (g)"
  ) +
  theme_minimal()

ggsave("figures/penguins.png", plot = p, width = 6, height = 4)
