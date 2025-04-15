library(dplyr)
library(ggplot2)
library(bench)
library(glue)

path_data = "./data"

path_parquet_subset <- glue("{path_data}/RPindividus_24.parquet")
path_csv_subset <- glue("{path_data}/RPindividus_24.csv")
path_parquet <- glue("{path_data}/RPindividus.parquet")
path_parquet_partition <- glue("{path_data}/RPindividus")

source("R/benchmark_functions.R")

benchmark1 <- bench::mark(
    req_csv = req_csv(path_csv_subset),
    req_read_parquet = req_read_parquet(path_parquet_subset),
    req_open_dataset = req_open_dataset(path_parquet_subset),
    iterations = 1,
    check = FALSE
)

benchmark2 <- bench::mark(
    req_open_dataset_full = req_open_dataset_full(path_parquet),
    req_open_dataset_part = req_open_dataset_part(path_parquet),
    iterations = 1,
    check = FALSE
)

benchmark3 <- bench::mark(
    req_open_dataset_full = req_open_dataset_full(path_parquet),
    req_open_dataset_partitioned = req_open_dataset_part(path_parquet_partition),
)
