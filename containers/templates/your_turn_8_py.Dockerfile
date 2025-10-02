# Your Turn 8: Same as previous - ready for cleanup
FROM stanfordhpds/base:latest

WORKDIR /workspace

RUN uv python install 3.12

COPY pyproject.toml pyproject.toml
COPY uv.lock uv.lock

RUN uv sync

COPY Makefile Makefile
COPY penguins.py penguins.py

CMD ["make", "all"]