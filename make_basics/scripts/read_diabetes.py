import polars as pl
import os

def main():
    # Read CSV; adjust the filename if needed.
    df = pl.read_csv("data/diabetes-buckingham.csv", null_values="NA")
    # Create a new column "diabetic" based on glyhb.
    df = df.with_columns(
        pl.when(pl.col("glyhb") >= 6.5)
          .then(pl.lit("Diabetic"))
          .when(pl.col("glyhb").is_null())
          .then(pl.lit("Missing"))
          .otherwise(pl.lit("Healthy"))
          .alias("diabetic")
    )
    # Ensure output directory exists.
    os.makedirs("parquet", exist_ok=True)
    df.write_parquet("parquet/diabetes.parquet")

if __name__ == "__main__":
    main()
