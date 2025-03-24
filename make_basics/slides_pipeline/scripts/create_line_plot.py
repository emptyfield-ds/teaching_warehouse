import os
import polars as pl
import seaborn as sns
import matplotlib.pyplot as plt

def create_line_plot(df: pl.DataFrame) -> plt.Figure:
    """
    Create a faceted line plot from gapminder data using Seaborn.
    
    - Filters out rows where continent equals 'Oceania'.
    - Uses a FacetGrid to create subplots for each continent.
    - Plots a line for each country (grouped and colored by 'country').
    - Removes legends from the facets.
    """
    df = df.filter(pl.col("continent") != "Oceania")
    
    g = sns.FacetGrid(
        df, 
        col="continent", 
        col_wrap=2, 
        height=4, 
        sharey=True,
        hue="country"
    )
    
    g.map_dataframe(sns.lineplot, x="year", y="lifeExp", lw=1)
    
    # Remove legends from each facet
    for ax in g.axes.flat:
        leg = ax.get_legend()
        if leg is not None:
            leg.remove()
    
    g.figure.tight_layout()
    return g.figure

def main():
    gapminder = pl.read_csv("data/gapminder.csv")
    fig = create_line_plot(gapminder)
    
    # Ensure the output directory exists.
    os.makedirs("figures", exist_ok=True)
    
    # Save the figure as a PNG image.
    fig.savefig("figures/gapminder_plot.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

if __name__ == "__main__":
    main()
