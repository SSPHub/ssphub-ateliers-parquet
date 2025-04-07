#!/bin/bash

DOWNLOAD_URL_ENV=
uv pip install -r pyprojects/api.toml

curl -L $DOWNLOAD_URL -o "${WORK_DIR}/${CHAPTER}.ipynb"

code-server --install-extension quarto.quarto
