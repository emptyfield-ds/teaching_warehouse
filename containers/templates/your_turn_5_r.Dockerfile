# Your Turn 5: R with renv dependency management
FROM stanfordhpds/base:latest

RUN rig add R 4.5.1

COPY renv.lock renv.lock
COPY renv/activate.R renv/activate.R
RUN echo "source('renv/activate.R')" > .Rprofile

RUN R -e "renv::restore()"

COPY penguins.R penguins.R

CMD ["Rscript", "penguins.R"]