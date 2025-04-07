#!/bin/bash

DOWNLOAD_URL_ENV="https://raw.githubusercontent.com/InseeFrLab/ssphub-ateliers/refs/heads/main/pyprojects/api.toml"
curl -L $DOWNLOAD_URL_ENV -o "pyproject.toml"
uv pip install -r pyproject.toml

DOWNLOAD_URL_NOTEBOOK="https://inseefrlab.github.io/ssphub-ateliers/sessions/api.ipynb"
curl -L $DOWNLOAD_URL_NOTEBOOK -o "api.ipynb"

code-server --install-extension quarto.quarto
