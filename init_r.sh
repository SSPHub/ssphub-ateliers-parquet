#!/bin/bash

git clone https://github.com/SSPHub/ssphub-ateliers-parquet --depth 1
cp ssphub-ateliers-parquet/R R/ -r
cp ssphub-ateliers-parquet/DESCRIPTION DESCRIPTION

Rscript -e "remotes::install_deps(upgrade='never')"

sudo apt-get update -y
sudo apt-get install libudunits2-dev \
  libgdal-dev \
  libgeos-dev \
  libproj-dev \
  libfontconfig1-dev \
  libharfbuzz-dev libfribidi-dev

mkdir -p data

curl -o "data/RPindividus.parquet" "https://minio.lab.sspcloud.fr/projet-formation/bonnes-pratiques/data/RPindividus.parquet"

Rscript R/create_environment.R

rm -rf ssphub-ateliers-parquet