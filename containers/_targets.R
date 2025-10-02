library(targets)
tar_option_set(packages = c("ggplot2"))
tar_source()

list(
  tar_target(
    penguins_plot,
    plot_penguins(penguins)
  ),
  tar_target(
    penguins_figure,
    {
      dir.create("figures", showWarnings = FALSE)
      ggsave(
        "figures/penguins_targets.png",
        plot = penguins_plot,
        width = 6,
        height = 4
      )
    },
    format = "file"
  )
)
