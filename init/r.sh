#!/bin/bash

sudo apt-get update -y
sudo apt-get install libudunits2-dev \
  libgdal-dev \
  libgeos-dev \
  libproj-dev \
  libfontconfig1-dev \
  libharfbuzz-dev libfribidi-dev

mkdir -p data

curl -o "data/RPindividus.parquet" "https://minio.lab.sspcloud.fr/projet-formation/bonnes-pratiques/data/RPindividus.parquet"

Rscript ./sessions/create_environment.R