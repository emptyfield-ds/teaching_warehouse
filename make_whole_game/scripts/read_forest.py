import polars as pl

pl.read_csv("data/forest.csv").write_parquet("data/forest.parquet")
