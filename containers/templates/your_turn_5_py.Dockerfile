# Your Turn 5: Python with uv dependency management
FROM stanfordhpds/base:latest

WORKDIR /workspace

RUN uv python install 3.12

COPY pyproject.toml pyproject.toml
COPY uv.lock uv.lock

RUN uv sync

COPY penguins.py penguins.py

CMD ["uv", "run", "penguins.py"]
