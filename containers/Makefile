.PHONY: all clean

all: figures/penguins.png

figures/penguins.png: penguins.py
	@mkdir -p figures
	uv run python penguins.py

clean:
	rm -rf figures