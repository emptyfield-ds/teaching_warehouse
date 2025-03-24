import polars as pl
import os

def main():
    diabetes = pl.read_parquet("parquet/diabetes.parquet")
    # Group by 'diabetic' and compute count and means (rounded).
    description = diabetes.group_by("diabetic").agg([
        pl.len().alias("n"),
        pl.mean("glyhb").round(1),
        pl.mean("ratio").round(1),
        pl.mean("age").round(1)
    ])
    os.makedirs("parquet", exist_ok=True)
    description.write_parquet("parquet/description.parquet")

if __name__ == "__main__":
    main()
