import polars as pl
import geopandas as gpd
import matplotlib.pyplot as plt
import os
# used later in `plot_top_change_2010()`
from plot_barplot_change import barplot_top_10_change  


def map_2010_forest_conversion(forest, ax=None):
    """
    Create a map showing net forest conversion in 2010.
    Uses geopandas for world geometries and overlays forest data.
    
    If an Axes is provided, it plots onto that Axes and returns it.
    Otherwise, it creates a new figure and returns the figure.
    """
    import geopandas as gpd
    import matplotlib.pyplot as plt

    # Load world geometries.
    world = gpd.read_file(
        "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson"
    )
    world["NAME"] = world["NAME"].replace({"USA": "United States"})
    
    # Filter the forest data for 2010.
    forest_df = (
        forest.filter(pl.col("year") == 2010)
              .filter(pl.col("entity") != "World")
              .collect()
              .to_pandas()
    )
    merged = world.merge(forest_df, left_on="NAME", right_on="entity", how="left")
    merged = merged[merged["NAME"] != "Antarctica"]
    
    created_fig = False
    if ax is None:
        fig, ax = plt.subplots(1, 1, figsize=(8, 6))
        created_fig = True

    merged.plot(
        column="net_forest_conversion",
        ax=ax,
        cmap="viridis",
        edgecolor="white",
        linewidth=0.5,
        missing_kwds={"color": "lightgrey"},
    )
    ax.axis("off")
    
    if created_fig:
        return fig
    else:
        return ax

def plot_top_change_2010(forest):
    """
    Create a composite figure that combines a map (from map_2010_forest_conversion)
    and a bar plot (from barplot_top_10_change in plot_barplot_change.py).
    """
    fig = plt.figure(constrained_layout=True, figsize=(12, 10))
    gs = fig.add_gridspec(2, 3, height_ratios=[2, 1])
    
    # Map: occupy the full top row.
    ax_map = fig.add_subplot(gs[0, :])
    map_2010_forest_conversion(forest, ax=ax_map)
    
    # Bar plot: place in the center cell of the bottom row.
    ax_bar = fig.add_subplot(gs[1, 1])
    barplot_top_10_change(forest, ax=ax_bar)
    
    return fig

forest = pl.scan_parquet("data/forest.parquet")
fig = map_2010_forest_conversion(forest)

os.makedirs("figures", exist_ok=True)
fig.savefig("figures/forest_map.png", dpi=300, bbox_inches="tight")
plt.close(fig)
