import shutil
import os
import io
from pathlib import Path
import polars as pl
import polars.selectors as cs

import shutil
from pathlib import Path

def copy_qmd_template(template):
    """
    Copy an updated version of the exercise template.

    Args:
        template (str): The name of the `.qmd` template to copy.

    Raises:
        FileNotFoundError: If the specified template file does not exist.
    """
    if template == "your_turn_3.qmd":
        shutil.copy("templates/references.bib", "references.bib")
    
    template_path = Path("templates") / template
    target_path = "whole_game.qmd"
    
    if not template_path.exists():
        raise FileNotFoundError(f"{template_path} not found. Are you sure you're in the right working directory?")
    
    shutil.copy(template_path, target_path)
    print(f"Copying {template_path} to {target_path}")

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
    
    dtypes = [pl.Utf8] + [pl.Float64] * 6

    # Use a string buffer to read the CSV string of the summary table into a Polars DataFrame
    coefficients_df = pl.read_csv(io.StringIO(coefficients_csv), dtypes=dtypes)

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