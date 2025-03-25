report.html: report.qmd figures/gapminder_plot.png data/gapminder.csv
  uv run quarto render report.qmd

figures/gapminder_plot.png: scripts/create_line_plot.py data/gapminder.csv
  uv run scripts/create_line_plot.py
