# Your Turn 6: R with targets pipeline
FROM stanfordhpds/base:latest

RUN rig add R 4.5.1

COPY renv.lock renv.lock
COPY renv/activate.R renv/activate.R
RUN echo "source('renv/activate.R')" > .Rprofile

RUN R -e "renv::restore()"

COPY _targets.R _targets.R
COPY R/ R/

CMD ["R", "-e", "targets::tar_make()"]