# Your Turn 4: R with rig
FROM stanfordhpds/base:latest

RUN rig add R 4.5.1

RUN R -e "install.packages('ggplot2')"

COPY penguins.R penguins.R

CMD ["Rscript", "penguins.R"]