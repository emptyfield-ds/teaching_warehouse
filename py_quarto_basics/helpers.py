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
    target_path = "exercises.qmd"
    
    if not template_path.exists():
        raise FileNotFoundError(f"{template_path} not found. Are you sure you're in the right working directory?")
    
    shutil.copy(template_path, target_path)
    print(f"Copying {template_path} to {target_path}")
