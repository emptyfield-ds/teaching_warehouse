def to_sentence(x):
    """Replace underscores with spaces and convert to sentence case."""
    s = x.replace("_", " ")
    return s.capitalize()
