import shutil
from pathlib import Path


def copy_dockerfile_template(template, target="Dockerfile"):
    """
    Copy a Dockerfile template to the working directory.
    
    Args:
        template (str): The name of the Dockerfile template to copy.
        target (str): The target filename (default: "Dockerfile").
    
    Raises:
        FileNotFoundError: If the specified template file does not exist.
    """
    template_path = Path("templates") / template
    target_path = Path(target)
    
    if not template_path.exists():
        raise FileNotFoundError(
            f"{template_path} not found. "
            "Are you sure you're in the right working directory?"
        )
    
    shutil.copy(template_path, target_path)
    print(f"Copying {template_path} to {target_path}")