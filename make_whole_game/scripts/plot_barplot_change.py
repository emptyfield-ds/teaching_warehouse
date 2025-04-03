import polars as pl
import matplotlib.pyplot as plt
import seaborn as sns

def barplot_top_10_change(forest: pl.DataFrame, ax=None):
    """
    Create a bar plot of the top 10 absolute changes in forest conversion in 2010.
    
    If an Axes is provided, the plot is drawn onto it; otherwise, a new figure and Axes are created.
    """
    # Filter and process the data.
    df = forest.filter(pl.col("year") == 2010).filter(pl.col("entity") != "World")
    df = df.with_columns(pl.col("net_forest_conversion").abs().alias("abs_conversion"))
    df = df.sort("abs_conversion", descending=True).head(10)
    df_pd = df.collect().to_pandas().sort_values("net_forest_conversion")
    
    created_fig = False
    if ax is None:
        fig, ax = plt.subplots(figsize=(8, 6))
        created_fig = True
    
    sns.barplot(
        x="net_forest_conversion",
        y="entity",
        hue="entity",
        data=df_pd,
        ax=ax,
        palette="viridis",
    )
    # Remove legend if it exists.
    if ax.get_legend() is not None:
        ax.get_legend().remove()
    ax.set_xlabel("Net Forest Conversion (ha) in 2010")
    ax.set_ylabel("")
    
    if created_fig:
        return ax.figure
    else:
        return ax

def main():
    forest = pl.scan_parquet("data/forest.parquet")

    fig = barplot_top_10_change(forest)

    fig.savefig("figures/forest_change.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

if __name__ == "__main__":
    main()
