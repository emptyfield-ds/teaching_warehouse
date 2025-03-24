import polars as pl

pl.read_csv("data/brazil_loss.csv").write_parquet("data/brazil_loss.parquet")
