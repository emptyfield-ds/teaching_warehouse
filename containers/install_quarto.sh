#!/bin/bash
set -e

QUARTO_VERSION=${QUARTO_VERSION:-1.7.23}

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    QUARTO_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    QUARTO_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

wget https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz
tar -xzf quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz
mv quarto-${QUARTO_VERSION} /opt/quarto
ln -s /opt/quarto/bin/quarto /usr/local/bin/quarto
rm quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz
