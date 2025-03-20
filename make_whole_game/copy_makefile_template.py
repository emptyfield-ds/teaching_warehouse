import os
import shutil

def copy_makefile_template(template):
    """
    Copy a Makefile template from the templates directory to the project root.

    Parameters
    ----------
    template : str
        The filename of the template to copy from the "templates/" folder.

    Raises
    ------
    FileNotFoundError
        If the template file does not exist.
    """
    source = os.path.join("templates", template)
    destination = "Makefile"

    if not os.path.exists(source):
        raise FileNotFoundError(
            f"{source} not found. Are you sure you're in the right working directory?"
        )

    shutil.copy(source, destination)
    print(f"Copied {os.path.abspath(source)} to {os.path.abspath(destination)}")
