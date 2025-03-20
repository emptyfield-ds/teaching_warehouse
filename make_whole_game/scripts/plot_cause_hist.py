import matplotlib.pyplot as plt
import polars as pl
import seaborn as sns
from utils import to_sentence

def plot_cause_hist(brazil_loss):
    """
    Create a faceted bar plot showing forest loss by cause over time.
    """
    df = brazil_loss.drop(["entity", "code"])
    df = df.unpivot(index=["year"], variable_name="cause", value_name="hectacres")
    df = df.sort("hectacres", descending=True)
    df = df.with_columns(
        pl.col("cause").map_elements(to_sentence, return_dtype=pl.Utf8)
    )
    df_pd = df.collect().to_pandas()
    g = sns.FacetGrid(df_pd, col="cause", col_wrap=4, sharey=False)
    g.map_dataframe(sns.barplot, x="year", y="hectacres", color="#CC79A7")
    g.set_axis_labels("Year", "Forest loss (ha)")
    for ax in g.axes.flatten():
        for label in ax.get_xticklabels():
            label.set_rotation(45)
    plt.tight_layout()
    # Save the figure to a file.
    g.figure.savefig("brazil_causes_hist.png")
    return plt.gcf()


brazil_loss = pl.scan_parquet("data/brazil_loss.parquet")

fig = plot_cause_hist(brazil_loss)

fig.savefig("figures/brazil_causes_hist.png", dpi=300, bbox_inches="tight")
plt.close(fig)
