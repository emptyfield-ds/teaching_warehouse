import dill as pickle
import polars as pl
from great_tables import GT, md
import os

def table_brazil_causes(brazil_causes_2010):
    return (
        GT(brazil_causes_2010)
        .fmt_number("hectacres", decimals=0)
        .cols_label(cause=md("*Cause*"), hectacres=md("*Hectacres*"))
    )


brazil_causes_2010 = pl.read_parquet("data/brazil_causes_2010.parquet")

table_obj = table_brazil_causes(brazil_causes_2010)

os.makedirs("pickles", exist_ok=True)
with open("pickles/brazil_causes_table.pkl", "wb") as f:
    pickle.dump(table_obj, f)
