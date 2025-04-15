# Image de base identique à celle utilisée dans GitHub Actions
FROM inseefrlab/onyxia-rstudio:r4.3.3-2025.04.07

# Pour éviter les prompts durant l'installation
ARG DEBIAN_FRONTEND=noninteractive

# Installation des dépendances système
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY DESCRIPTION app/DESCRIPTION

WORKDIR /app

# Installer les dépendances R via {remotes} et {pak} (comme `setup-r-dependencies`)
RUN R -e "install.packages(c('devtools'))" && \
    R -e "devtools::install_deps(upgrade='never')"

# Installer Quarto (version 1.6.42 spécifiée)
RUN curl -fsSL https://quarto.org/download/v1.6.42/quarto-1.6.42-linux-amd64.deb -o quarto.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# Copier le reste des fichiers (optionnel)
# COPY . /app

# Lancer un shell ou RStudio à la fin selon ton besoin
CMD ["/init"]
