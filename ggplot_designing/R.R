library(tidyverse)
library(sf)
library(gghighlight)
library(cowplot)
library(ggrepel)
nyc_squirrels <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-29/nyc_squirrels.csv"
)
nyc_squirrels |>
  ggplot(aes(x = long, y = lat)) +
  geom_point()

dog_sighting <- nyc_squirrels |>
  mutate(dog = str_detect(other_activities, "dog")) |>
  filter(dog)


central_park <- read_sf(
  "/Users/malcolmbarrett/Downloads/CentralAndProspectParks/"
)


# start

nyc_squirrels |>
  drop_na(primary_fur_color) |>
  ggplot() +
  geom_sf(data = central_park, color = "grey85") +
  geom_point(aes(x = long, y = lat, color = primary_fur_color)) +
  cowplot::theme_map(16) +
  colorblindr::scale_color_OkabeIto()

# complete
nyc_squirrels |>
  drop_na(primary_fur_color) |>
  ggplot() +
  geom_sf(data = central_park, color = "grey85") +
  geom_point(
    data = function(x) select(x, long, lat),
    aes(x = long, y = lat, color = "all squirrels")
  ) +
  geom_point(aes(x = long, y = lat, color = "highlighted group")) +
  cowplot::theme_map(16) +
  theme(legend.position = "bottom", legend.justification = "center") +
  facet_wrap(~primary_fur_color) +
  scale_color_manual(
    name = NULL,
    values = c("all squirrels" = "grey75", "highlighted group" = "#0072B2")
  ) +
  guides(color = guide_legend(override.aes = list(size = 3)))

nyc_squirrels |>
  mutate(
    activity = case_when(
      foraging = "foraging",
      running = "running",
      chasing = "chasing",
      "climbing",
      "eating"
    )
  )

nyc_squirrels |>
  drop_na(primary_fur_color) |>
  ggplot(aes(long, fill = primary_fur_color)) +
  geom_histogram() +
  gghighlight() +
  facet_wrap(~primary_fur_color, nrow = 1)


nyc_squirrels |>
  drop_na(primary_fur_color) |>
  group_by(hectare) |>
  summarise()

la_heat_income <- sf::read_sf(
  "https://raw.githubusercontent.com/nprapps/heat-income/master/data/output/analysis_out/final/los-angeles.geojson"
)
sf::read_sf(
  "https://raw.githubusercontent.com/nprapps/heat-income/master/data/output/analysis_out/los-angeles/a6_stats.geojson"
)

kelvin2farenheit <- function(k) (9 / 5) * (k - 273) + 32

la_heat_income |>
  mutate(temp = kelvin2farenheit(X_median)) |>
  ggplot() +
  geom_sf(aes(fill = temp), color = "white", size = .2) +
  cowplot::theme_map() +
  scale_fill_viridis_c(option = "inferno")

annotations <- tibble::tribble(
  ~x,
  ~y,
  ~label,
  -118.90,
  34.00,
  "The coolest corridor, from Santa Monica\nto Griffith Park, was also the richest,\nwith higher median household incomes\nthan the rest of Los Angeles",
  -118.20,
  34.22,
  "Census tracts in the north and southeast\nof Los Angeles were its hottest. Like a lot\nof US cities, these are also the places\nwhere its poorest residents live."
)

curves <- tibble::tribble(
  ~x,
  ~y,
  ~xend,
  ~yend,
  -118.73,
  34.035,
  -118.60,
  34.10, # west side, pointing northeast
  -118.21,
  34.195,
  -118.35,
  34.18, # northeast, pointing northwest
  -118.08,
  34.185,
  -118.15,
  34.10 # northeast, pointing southwest
)


la_heat_income |>
  mutate(temp = kelvin2farenheit(X_median)) |>
  ggplot() +
  geom_sf(aes(fill = temp), color = "white", size = .2) +
  geom_text(
    data = annotations,
    aes(x, y, label = label),
    hjust = 0,
    vjust = 0.5,
    lineheight = 0.8
  ) +
  geom_curve(
    data = curves,
    aes(x = x, y = y, xend = xend, yend = yend),
    colour = "grey75",
    size = 0.3,
    curvature = -0.1,
    arrow = arrow(length = unit(0.01, "npc"), type = "closed")
  ) +
  coord_sf(clip = "off") +
  cowplot::theme_map() +
  theme(legend.position = c(-118.73, 34.15)) +
  scale_fill_viridis_c(name = "temperature (F°)", option = "inferno")


library(gapminder)

gapminder |>
  filter(year == 2007) |>
  ggplot(aes(lifeExp, fill = continent)) +
  geom_histogram(bins = 40) +
  gghighlight() +
  facet_wrap(~continent)

diabetes <- read_csv("dplyr_5verbs/diabetes.csv")

diabetes |>
  ggplot(aes(glyhb, fill = gender)) +
  geom_density(col = "white", alpha = .8) +
  # gghighlight() +
  # facet_wrap(~ gender)
  scale_x_log10()


emperors <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-08-13/emperors.csv"
)


emperors |>
  count(cause) |>
  arrange(n) |>
  mutate(
    assassinated = ifelse(cause == "Assassination", TRUE, FALSE),
    cause = fct_inorder(cause)
  ) |>
  ggplot(aes(x = n, y = cause, fill = assassinated)) +
  geom_col() +
  geom_text(aes(label = n, x = n - .25), color = "white", size = 6, hjust = 1) +
  cowplot::theme_minimal_vgrid(16) +
  theme(
    axis.title.y = element_blank(), # we don't need this title because it's self explanatory
    legend.position = "none" # for the same reason, we don't need a legend
  ) +
  scale_fill_manual(name = NULL, values = c("#B0B0B0D0", "#BD3828D0")) +
  xlab("number of emperors")


lightning_plot <- emperors |>
  mutate(killer = fct_lump(killer, 10)) |>
  count(killer) |>
  arrange(n) |>
  mutate(
    lightning = ifelse(killer == "Lightning", TRUE, FALSE),
    killer = fct_inorder(killer)
  ) |>
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


label <- str_wrap(
  "Carus, Roman emperor from 282–283, allegedly died of a lightning strike while campaigning against the Empire of Iranians. He was succeded by his sons, Carinus, who died in battle, and Numerian, whose cause of death is unknown.",
  50
)
lightning_plot +
  geom_label(
    data = data.frame(x = 5.8, y = 5, label = label),
    aes(x = x, y = y, label = label),
    hjust = 0,
    lineheight = .8,
    size = 5,
    inherit.aes = FALSE,
    label.size = NA
  ) +
  geom_curve(
    data = data.frame(x = 5.6, y = 5, xend = 1.2, yend = 5),
    mapping = aes(x = x, y = y, xend = xend, yend = yend),
    colour = "grey75",
    size = 0.5,
    curvature = -0.1,
    arrow = arrow(length = unit(0.01, "npc"), type = "closed"),
    inherit.aes = FALSE
  )


sample_countries <- function(x) {
  x |>
    sample_n(11)
}

set.seed(1010)

countries <- gapminder |>
  sample_countries() |>
  pull(country)


gapminder |>
  filter(year == 2007) |>
  mutate(
    label = ifelse(country %in% countries, as.character(country), "")
  ) |>
  ggplot(aes(log(gdpPercap), lifeExp)) +
  geom_point(
    size = 3.5,
    alpha = .9,
    shape = 21,
    col = "white",
    fill = "#0162B2"
  ) +
  geom_text_repel(
    aes(label = label),
    size = 4.5,
    point.padding = .2,
    box.padding = .4,
    force = 1,
    min.segment.length = 0
  ) +
  theme_minimal(14) +
  theme(
    legend.position = "none",
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank()
  ) +
  labs(x = "log(GDP per capita)", y = "life expectancy")


gapminder |>
  filter(continent == "Africa") |>
  select(country, year, lifeExp) |>
  spread(year, lifeExp) |>
  mutate(le_dropped = `1992` > `2007`) |>
  select(country, le_dropped) |>
  left_join(gapminder, by = "country") |>
  filter(continent == "Africa") |>
  mutate(labels = "") |>
  ggplot(aes(year, lifeExp, col = country)) +
  geom_line(size = 1.2, alpha = .9, col = "#E58C23") +
  gghighlight(
    le_dropped,
    use_group_by = FALSE,
    label_key = labels,
    unhighlighted_colour = "grey90"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank()
  ) +
  scale_color_manual(values = country_colors) +
  labs(y = "life expectancy") +
  xlim(1950, 2015) +
  facet_wrap(~country)


density_colors <- c(
  male = "#56B4E9",
  female = "#009E73",
  "all participants" = "grey85"
)

diabetes |>
  ggplot(aes(glyhb, y = ..count..)) +
  geom_density(
    data = function(x) select(x, glyhb),
    aes(fill = "all participants", color = "all participants")
  ) +
  geom_density(aes(fill = gender, color = gender)) +
  scale_x_log10(name = "glycosylated hemoglobin a1c") +
  scale_color_manual(name = NULL, values = density_colors) +
  scale_fill_manual(name = NULL, values = density_colors) +
  facet_wrap(vars(gender)) +
  theme_minimal_hgrid(16) +
  theme(legend.position = "bottom", legend.justification = "center")
