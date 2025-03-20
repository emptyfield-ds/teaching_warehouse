import polars as pl
import matplotlib.pyplot as plt
import seaborn as sns
import geopandas as gpd

def map_2010_forest_conversion(forest):
    """
    Create a map showing net forest conversion in 2010.
    Uses geopandas for world geometries and overlays forest data.
    """
    # Use a direct URL to load the Natural Earth dataset.
    world = gpd.read_file(
        "https://raw.githubusercontent.com/geopandas/geopandas/main/geopandas/datasets/naturalearth_lowres/naturalearth_lowres.shp"
    )
    world["name"] = world["name"].replace({"USA": "United States"})
    # Filter forest data (assumes forest is a Polars DataFrame).
    forest_df = (
        forest.filter(pl.col("year") == 2010)
        .filter(pl.col("entity") != "World")
        .to_pandas()
    )
    merged = world.merge(forest_df, left_on="name", right_on="entity", how="left")
    merged = merged[merged["name"] != "Antarctica"]
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    merged.plot(
        column="net_forest_conversion",
        ax=ax,
        cmap="viridis",
        edgecolor="white",
        linewidth=0.5,
        missing_kwds={"color": "lightgrey"},
    )
    ax.axis("off")
    plt.tight_layout()
    return fig

def plot_top_change_2010(forest):
    """
    Combine the map and bar plot into one figure.
    """
    fig = plt.figure(constrained_layout=True, figsize=(12, 10))
    gs = fig.add_gridspec(2, 3, height_ratios=[2, 1])

    # Map (occupies the full top row)
    ax_map = fig.add_subplot(gs[0, :])
    world = gpd.read_file(
        "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson"
    )
    forest_df = (
        forest.filter(pl.col("year") == 2010)
        .filter(pl.col("entity") != "World")
        .collect()
        .to_pandas()
    )
    merged = world.merge(forest_df, left_on="NAME", right_on="entity", how="left")
    merged = merged[merged["NAME"] != "Antarctica"]
    merged.plot(
        column="net_forest_conversion",
        ax=ax_map,
        cmap="viridis",
        edgecolor="white",
        linewidth=0.5,
        missing_kwds={"color": "lightgrey"},
    )
    ax_map.axis("off")

    # Bar plot in the middle of the bottom row.
    ax_bar = fig.add_subplot(gs[1, 1])
    df = forest.filter(pl.col("year") == 2010).filter(pl.col("entity") != "World")
    df = df.with_columns(pl.col("net_forest_conversion").abs().alias("abs_conversion"))
    df = df.sort("abs_conversion", descending=True).head(10)
    df_pd = df.collect().to_pandas().sort_values("net_forest_conversion")
    sns.barplot(
        x="net_forest_conversion",
        y="entity",
        hue="entity",
        data=df_pd,
        ax=ax_bar,
        palette="viridis",
    )
    if ax_bar.get_legend() is not None:
        ax_bar.get_legend().remove()
    ax_bar.set_xlabel("Net Forest Conversion (ha) in 2010")
    ax_bar.set_ylabel("")

    return fig

forest = pl.scan_parquet("data/forest.parquet")
fig = map_2010_forest_conversion(forest)

fig.savefig("figures/forest_map.png", dpi=300, bbox_inches="tight")
plt.close(fig)
