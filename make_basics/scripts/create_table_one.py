import polars as pl
from great_tables import GT
import os
import pickle

def create_table_one_df(diabetes: pl.DataFrame) -> pl.DataFrame:
    stats =  {group[0]: df.describe() for group, df in diabetes.select(pl.col("glyhb", "ratio", "age", "chol", "diabetic")).group_by(["diabetic"])}

    diabetes_desc = (stats["Diabetic"]
        .with_columns(pl.lit("Diabetic").alias("diabetic"))
        .vstack(
            stats["Healthy"]
            .with_columns(pl.lit("Healthy").alias("diabetic"))
    ))

    return diabetes_desc

def main():
    diabetes = pl.read_parquet("parquet/diabetes.parquet")
    diabetes_desc = create_table_one_df(diabetes)
    tbl1 = (GT(
        diabetes_desc, 
        rowname_col="statistic", 
        groupname_col="diabetic"
    )
    # TODO:
    # add formatting for the numeric columns here
    # .fmt_number(["glyhb", "ratio", "age", "chol"], decimals=1)
    .cols_label(
        diabetic="Diabetes Status", 
        glyhb="Hemoglobin A1c",
        ratio="Waist/Hip Ratio", 
        age="Age", 
        chol="Cholesterol"
    ))

    os.makedirs("pickles", exist_ok=True)
    with open("pickles/table_one.pickle", "wb") as f:
        pickle.dump(tbl1, f)

if __name__ == "__main__":
    main()
