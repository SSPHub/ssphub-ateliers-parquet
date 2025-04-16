#!/bin/bash

git clone https://github.com/SSPHub/ssphub-ateliers-parquet --depth 1

cp ssphub-ateliers-parquet/python/_s3.qmd s3.qmd
cp ssphub-ateliers-parquet/pyproject.toml pyproject.toml

uv pip install -r pyproject.toml --system
quarto render s3.qmd --to ipynb --execute

rm -rf ssphub-ateliers-parquet