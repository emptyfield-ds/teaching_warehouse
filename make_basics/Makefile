# this tells Make that the `run` and `clean` targets
# will NOT create files it needs track
.PHONY: run clean

# -- START OF PIPELINE --

# execute the Python file using uv run.
# `run` depends on the file `example.py`
run: example.py
	uv run example.py

# create a Python file called `example.py`.
# we need this for `run`!
example.py:
	@echo "Creating example.py..."
	@echo "print('Hello, Make!')" > example.py

# -- END OF PIPELINE --

# this is a helper target to clean up generated files.
# since no other target depends on it, it is independent
# and needs to be called directly: `make clean`
clean:
	rm -f example.py
