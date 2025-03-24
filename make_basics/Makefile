# this tells Make that the `all` and `clean` targets
# will NOT create files it needs track
.PHONY: all clean

# -- START OF PIPELINE --
all: out.txt

# execute the Python file using uv run.
# `run` depends on the file `example.py`
out.txt: example.py
	uv run example.py > out.txt

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
	rm -f example.py out.txt
