# Your Turn 3: Python Dockerfile with Quarto
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV QUARTO_VERSION=1.8.0

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    software-properties-common \
    gdebi-core \
    unzip \
    sudo \
    locales \
    && locale-gen en_US.UTF-8

COPY install-quarto.sh install-quarto.sh

RUN chmod +x install-quarto.sh && \
    QUARTO_VERSION=${QUARTO_VERSION} install-quarto.sh

CMD ["echo", "Hello from my Ubuntu container!"]