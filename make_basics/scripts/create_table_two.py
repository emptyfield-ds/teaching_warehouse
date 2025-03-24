import polars as pl
import polars.selectors as cs
import statsmodels.formula.api as smf
import statsmodels.api as sm
from great_tables import GT
import pickle
import io
import os

def coefs_to_polars(model, suffix):
    """
    Extracts the coefficients table from a fitted model summary,
    converts it to a Polars DataFrame with specified data types.

    Parameters:
    - model: The fitted model object from which to extract the summary.

    Returns:
    - A Polars DataFrame containing the coefficients from the model summary.
    """
    model_summary = model.summary()
    coefficients_csv = model_summary.tables[1].as_csv()
    
    schema_overrides = [pl.Utf8] + [pl.Float64] * 6

    # Use a string buffer to read the CSV string of the summary table into a Polars DataFrame
    coefficients_df = pl.read_csv(io.StringIO(coefficients_csv), schema_overrides=schema_overrides)

    coefficients_df = (coefficients_df
      .rename(lambda col: col.strip())
      .rename({
        "": "term",
        "[0.025": "ci_lower",
        "0.975]": "ci_upper",
      })
      .select(pl.col("term", "coef", "ci_lower", "ci_upper"))
      .with_columns(pl.col("term").str.strip_chars_start().str.strip_chars_end())
      .with_columns(pl.all().name.suffix(f"_{suffix}"))
      .select(cs.ends_with(f"_{suffix}"))
    )
    
    return coefficients_df

def main():
    diabetes = pl.read_parquet("parquet/diabetes.parquet")
    lm_model = smf.ols("glyhb ~ ratio + age", data=diabetes).fit()
    lm_coefficients_df = coefs_to_polars(lm_model, suffix="lm")

    diabetes = diabetes.with_columns(
        pl.when(pl.col('diabetic') == "Diabetic").then(1).otherwise(0).alias("diabetic_bin")
    )

    logistic_model = smf.glm(
        formula='diabetic_bin ~ ratio + age', 
        data=diabetes, 
        family=sm.families.Binomial()
    ).fit()

    glm_coefficients_df = (coefs_to_polars(logistic_model, suffix="glm")
        .select(pl.exclude("term_glm"))
        # we want odds ratios for this model
        .with_columns(
            pl.all().exp()
        )
    )
    
    coef_dfs = lm_coefficients_df.hstack(glm_coefficients_df)
    tbl = (GT(coef_dfs)
        .tab_spanner(label="Linear Model", columns=cs.ends_with("_lm"))
        .tab_spanner(label="Logistic Model", columns=cs.ends_with("_glm"))
        .cols_label(
            term_lm = "Term",
            coef_lm = "Coef",
            ci_lower_lm = "Lower 95% CI",
            ci_upper_lm = "Upper 95% CI",
            coef_glm = "Odds Ratio",
            ci_lower_glm = "Lower 95% CI",
            ci_upper_glm = "Upper 95% CI",
        )
        .fmt_number(
            columns=["coef_lm", "ci_lower_lm", "ci_upper_lm", "coef_glm", "ci_lower_glm", "ci_upper_glm"], 
            decimals=2
        )
    )

    os.makedirs("pickles", exist_ok=True)
    with open("pickles/table_two.pickle", "wb") as f:
        pickle.dump(tbl, f)


if __name__ == "__main__":
    main()
