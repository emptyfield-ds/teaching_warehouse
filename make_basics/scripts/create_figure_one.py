import polars as pl
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns
import os


def create_figure_one(diabetes: pl.DataFrame):
    diabetes = diabetes.drop_nulls()
    plt.figure(figsize=(9, 3.5))

    plt.subplot(1, 2, 1)
    sns.regplot(
        x='ratio', 
        y='glyhb', 
        data=diabetes, 
        fit_reg=True, 
        scatter_kws={'s': 2, 'color': 'white', 'edgecolor': 'grey'},
        line_kws={'color': 'steelblue', 'lw': 1}
    )

    plt.xscale('log')
    plt.xlabel('Hip/waist ratio')
    plt.ylabel('Hemoglobin A1c')
    plt.title('A')

    plt.subplot(1, 2, 2)
    sns.histplot(
        data=diabetes,
        x='ratio', 
        hue='diabetic', 
        element='step',
        fill=True, 
        palette=['steelblue', 'firebrick'], 
        alpha=0.8,
        bins=30
    )
    plt.xlabel('Hip/waist ratio')
    plt.title('B')
    patch1 = mpatches.Patch(color='steelblue', label='Healthy')
    patch2 = mpatches.Patch(color='firebrick', label='Diabetic')
    plt.legend(handles=[patch1, patch2], title='', loc='upper center')

    plt.tight_layout()
    return plt.gcf()

def main():
    diabetes = pl.read_parquet("parquet/diabetes.parquet")
    fig = create_figure_one(diabetes)
    os.makedirs("figures", exist_ok=True)
    fig.savefig("figures/figure_one.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

if __name__ == "__main__":
    main()
