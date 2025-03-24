import polars as pl
from utils import to_sentence

def clean_2010_causes(brazil_loss):
    """
    Process Brazil loss data for 2010.
    Drops non-cause columns, pivots data into long format, and formats cause names.
    """
    df = brazil_loss.filter(pl.col("year") == 2010)
    # Drop columns 'entity' and 'year'
    df = df.drop(["entity", "year"])
    df = df.unpivot(index=[], variable_name="cause", value_name="hectacres")
    df = df.sort("hectacres", descending=True)
    df = df.with_columns(
        pl.col("cause").map_elements(to_sentence, return_dtype=pl.Utf8)
    )
    df = df.filter(pl.col("cause") != "Code").with_columns(
        pl.col("hectacres").cast(pl.Int64)
    )
    return df


brazil_loss = pl.scan_parquet("data/brazil_loss.parquet")

cleaned_brazil_loss = clean_2010_causes(brazil_loss)

cleaned_brazil_loss.collect().write_parquet("data/brazil_causes_2010.parquet")
