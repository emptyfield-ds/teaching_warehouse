# Your Turn 4: Python with uv
FROM stanfordhpds/base:latest

RUN uv python install 3.12

RUN uv init --no-readme
RUN uv add matplotlib seaborn pandas

COPY penguins.py penguins.py

CMD ["uv", "run", "penguins.py"]
