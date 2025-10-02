# Your Turn 7: Same as Your Turn 6
FROM stanfordhpds/base:latest

RUN uv python install 3.12

COPY pyproject.toml pyproject.toml
COPY uv.lock uv.lock

RUN uv sync

COPY Makefile Makefile
COPY penguins.py penguins.py

CMD ["make", "all"]