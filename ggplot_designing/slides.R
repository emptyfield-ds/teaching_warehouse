emperors %>%
  count(cause) %>%
  mutate(
    cause = fct_inorder(cause)
  ) %>%
  ggplot(aes(x = n, y = cause)) +
  geom_col() +
  geom_text(aes(label = n, x = n - .25), color = "white", size = 6, hjust = 1) +
  cowplot::theme_minimal_vgrid(16) +
  theme(
    axis.title.y = element_blank(), # we don't need this title because it's self explanatory
    legend.position = "none" # for the same reason, we don't need a legend
  ) +
  xlab("number of emperors")

emperors %>%
  count(cause) %>%
  arrange(n) %>%
  mutate(
    cause = fct_inorder(cause)
  ) %>%
  ggplot(aes(x = n, y = cause)) +
  geom_col() +
  geom_text(aes(label = n, x = n - .25), color = "white", size = 6, hjust = 1) +
  cowplot::theme_minimal_vgrid(16) +
  theme(
    axis.title.y = element_blank(), # we don't need this title because it's self explanatory
    legend.position = "none" # for the same reason, we don't need a legend
  ) +
  xlab("number of emperors")

emperors %>%
  count(cause) %>%
  arrange(n) %>%
  mutate(
    assassinated = ifelse(cause == "Assassination", TRUE, FALSE),
    cause = fct_inorder(cause)
  ) %>%
  ggplot(aes(x = n, y = cause, fill = assassinated)) +
  geom_col() +
  geom_text(aes(label = n, x = n - .25), color = "white", size = 6, hjust = 1) +
  cowplot::theme_minimal_vgrid(16) +
  theme(
    axis.title.y = element_blank(), # we don't need this title because it's self explanatory
    legend.position = "none" # for the same reason, we don't need a legend
  ) +
  scale_fill_manual(name = NULL, values = c("#B0B0B0D0", "#D55E00D0")) +
  xlab("number of emperors")

library(gapminder)
library(ggrepel)

set.seed(1010)

gapminder %>%
  filter(year == 2007) %>%
  ggplot(aes(log(gdpPercap), lifeExp)) +
  geom_point(size = 3.5, alpha = .9, shape = 21, col = "white", fill = "#0162B2") +
  geom_text_repel(aes(label = country), size = 4.5,
                  point.padding = .2, box.padding = .4, force = 1,
                  min.segment.length = 0) +
  theme_minimal(14) +
  theme(legend.position = "none",
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y = element_blank()) +
  labs(x = "log(GDP per capita)",
       y = "life expectancy")


nyc_squirrels <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-29/nyc_squirrels.csv")

dog_sighting <- nyc_squirrels %>%
  mutate(dog = str_detect(other_activities, "dog")) %>%
  filter(dog)

central_park <- sf::read_sf("data/central_park/")

nyc_squirrels %>%
  ggplot() +
  geom_sf(data = central_park, color = "grey80") +
  geom_point(aes(x = long, y = lat)) +
  geom_point(
    data = dog_sighting,
    aes(x = long, y = lat, color = "squirrel interacting\nwith a dog"),
    size = 3
  ) +
  ggrepel::geom_label_repel(
    data = filter(dog_sighting, str_detect(other_activities, "teasing")),
    aes(x = long, y = lat, label = str_wrap("All other dog sightings involved a squirrel hiding or being chased. This squirrel, however, was actively teasing a dog.", 30)),
    nudge_x = .015,
    segment.color = "grey70"
  ) +
  cowplot::theme_map() +
  theme(legend.position = c(.1, .9)) +
  scale_color_manual(name = NULL, values = "#FB1919")

diabetes %>%
  ggplot(aes(glyhb)) +
  geom_density(aes(fill = gender)) +
  scale_x_log10() +
  colorblindr::scale_fill_OkabeIto()


diabetes %>%
  ggplot(aes(glyhb, y = ..count.., fill = gender)) +
  geom_histogram() +
  gghighlight() +
  facet_wrap(vars(gender)) +
  scale_x_log10(name = "glycosylated hemoglobin a1c") +
  scale_color_manual(name = NULL, values = density_colors) +
  scale_fill_manual(name = NULL, values = density_colors) +
  theme_minimal_hgrid(16) +
  theme(legend.position = "bottom", legend.justification = "center")


lightning_plot <- emperors %>%
  mutate(killer = fct_lump(killer, 10)) %>%
  count(killer) %>%
  arrange(n) %>%
  mutate(
    lightning = ifelse(killer == "Lightning", TRUE, FALSE),
    killer = fct_inorder(killer)
  ) %>%
  ggplot(aes(x = n, y = killer, fill = lightning)) +
  geom_col() +
  geom_text(aes(label = n, x = n - .25), color = "white", size = 6, hjust = 1) +
  cowplot::theme_minimal_vgrid(16) +
  theme(
    axis.title.y = element_blank(), # we don't need this title because it's self explanatory
    legend.position = "none" # for the same reason, we don't need a legend
  ) +
  scale_fill_manual(name = NULL, values = c("#B0B0B0D0", "#BD3828D0")) +
  xlab("number of emperors")


label <- str_wrap("Carus, Roman emperor from 282–283, allegedly died of a lightning strike while campaigning against the Empire of Iranians. He was succeded by his sons, Carinus, who died in battle, and Numerian, whose cause of death is unknown.", 50)
lightning_plot +
  geom_label(data = data.frame(x = 5.8, y = 5, label = label), aes(x = x, y = y, label = label), hjust = 0, lineheight = .8, size = 5, inherit.aes = FALSE, label.size = NA) +
  geom_curve(
    data = data.frame(x = 5.6, y = 5, xend = 1.2, yend = 5),
    mapping = aes(x = x, y = y, xend = xend, yend = yend),
    colour = "grey75",
    size = 0.5,
    curvature = -0.1,
    arrow = arrow(length = unit(0.01, "npc"), type = "closed"),
    inherit.aes = FALSE
  )

la_heat_income %>%
  mutate(temp = kelvin2farenheit(X_median)) %>%
  ggplot() +
  geom_sf(aes(fill = temp), color = "white", size = .2) +
  cowplot::theme_map() +
  scale_fill_viridis_c(option = "inferno")


