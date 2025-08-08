# patterns:

# facet with data shadows -------------------------------------------------

#  set up background geom
drop_facet <- function(x) select(x, -facet_variable)

#  use highlighting colors for the facets and greys for the background total
highlight_colors <- c(
  "all data label" = "grey85",
  value1 = "#E69F00",
  value2 = "#CC79A7"
)

data |>
  ggplot() +
  # first geom: all data, no facet variable
  geom_point(data = drop_facet, aes(color = "all data label")) +
  # second geom, split by facet variable
  geom_point(aes(color = facet_variable)) +
  # facet wrap the variable
  facet_wrap(vars(facet_variable)) +
  scale_color_manual(values = highlight_colors)


# insert y-axis direct labels ---------------------------------------------

# find the maximum of the line
direct_labels <- data |>
  group_by(line_variable) |>
  summarize(x = max(x), y = max(y))

line_plot <- data |>
  ggplot() +
  geom_line(aes(color = line_variable)) +
  # turn off legend
  theme(legend.position = "none")

# get the y axis and add a text geom
direct_labels_axis <- axis_canvas(line_plot, axis = "y") +
  geom_text(
    data = direct_labels, # direct label data
    aes(y = y, label = line_variable),
    x = 0.05, # a little buffer
    hjust = 0 # left align
  )

# add the laabels to the y axis
line_plot_direct_labels <- insert_yaxis_grob(line_plot, direct_labels_axis)

# draw the new plot
ggdraw(line_plot_direct_labels)

# as a function
direct_label <- function(p, .data, .labels, .x = x, .y = y, axis = "y", ...) {
  direct_labels_axis <- axis_canvas(p, axis = "y") +
    geom_text(data = .data, aes({{ .x }}, {{ .y }}, label = {{ .labels }}), ...)

  p_direct_labels <- insert_yaxis_grob(p, direct_labels_axis)

  ggdraw(p_direct_labels)
}

direct_label(p, data, x = 1, y = max(y), label = "label text")


# pointy notes ------------------------------------------------------------

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

label <- str_wrap("Plot annotation", 50)
text_df <- data.frame(x = 5.8, y = 5, label = label)
arrow_df <- data.frame(
  x = 5.6,
  y = 5,
  xend = 1.2,
  yend = 5
)

plot +
  geom_text(
    data = text_df,
    aes(x = x, y = y, label = label),
    hjust = 0
  ) +
  geom_curve(
    data = arrow_df,
    mapping = aes(x = x, y = y, xend = xend, yend = yend),
    curvature = -0.1,
    arrow = arrow()
  )
