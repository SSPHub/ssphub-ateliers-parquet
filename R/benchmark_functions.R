library(dplyr)
library(ggplot2)
library(bench)
library(stringr)

path_data <- "./data"
path_parquet <- glue("{path_data}/RPindividus.parquet")
path_parquet_subset <- glue("{path_data}/RPindividus_24.parquet")
path_csv_subset <- glue("{path_data}/RPindividus_24.csv")


req_csv <- function(path="data/RPindividus_24.csv") {
  res <- readr::read_csv(path) |>
    filter(DEPT == "36") |>
    group_by(AGED, DEPT) |>
    summarise(n_indiv = sum(IPONDI))

  return(res)
}

req_read_parquet <- function(path="data/RPindividus_24.parquet") {
  res <- arrow::read_parquet(path) |>
    filter(DEPT == "36") |>
    group_by(AGED, DEPT) |>
    summarise(n_indiv = sum(IPONDI))

  return(res)
}

req_open_dataset <- function(path="data/RPindividus_24.parquet") {
  res <- arrow::open_dataset(path) |>
    filter(DEPT == "36") |>
    group_by(AGED, DEPT) |>
    summarise(n_indiv = sum(IPONDI)) |>
    collect()

  return(res)
}

req_open_dataset_full <- function(path="data/RPindividus.parquet") {
  res <- arrow::open_dataset(path) |>
    filter(DEPT == "36") |>
    group_by(AGED, DEPT) |>
    summarise(n_indiv = sum(IPONDI)) |>
    collect()

  return(res)
}

req_open_dataset_part <- function(path="data/RPindividus_partitionne.parquet") {
  res <- arrow::open_dataset(path, hive_style = TRUE) |>
    filter(DEPT == "36") |>
    group_by(AGED, DEPT) |>
    summarise(n_indiv = sum(IPONDI)) |>
    collect()

  return(res)
}


mesurer_taille <- function(path){
  poids <- file.size(path)
  taille <- convertir_taille(poids)
  return(taille)
}

# Fonction pour convertir les octets en Mo ou Go
convertir_taille <- function(octets) {
  if (octets >= 1024^3) {
    return(paste(round(octets / 1024^3, 2), "Go"))
  } else if (octets >= 1024^2) {
    return(paste(round(octets / 1024^2, 2), "Mo"))
  } else {
    return(paste(octets, "octets"))
  }
}





