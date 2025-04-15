library(ggplot2)
library(stringr)
library(dplyr)
library(duckdb)
library(bench)
library(gt)

source("R/benchmark_functions.R")

path_data <- "./data"
path_parquet <- glue("{path_data}/RPindividus.parquet")
path_parquet_subset <- glue("{path_data}/RPindividus_24.parquet")
path_parquet_csv <- glue("{path_data}/RPindividus_24.csv"


# PARTIE 1: TESTS SANS EXECUTION ---------

# Execution avec arrow

arrow::open_dataset(path_parquet_subset) |>
    head(5)


arrow::open_dataset(path_parquet_subset) |>
    filter(DEPT == "36") |>
    group_by(AGED, DEPT) |>
    summarise(n_indiv = sum(IPONDI))


# Execution avec duckdb
con <- dbConnect(duckdb())
table_individu <- tbl(con, glue('read_parquet("{path_parquet_subset}")'))

class(
  table_individu %>% head(5)
)
class(
  table_individu %>% head(5) %>% collect()
)

direct_duckdb <- dbGetQuery(con, glue('SELECT * FROM read_parquet("{path_parquet_subset}") LIMIT 1000'))

class(
    direct_duckdb
)


# PARTIE 2: COMPARATIF -------------------

benchmark2 <- bench::mark(
    req_read_parquet = req_read_parquet(path_parquet_subset),
    req_open_dataset = req_open_dataset(path_parquet_subset),
    iterations = 1,
    check = FALSE
)


benchmark2 <- benchmark2 |> mutate(
    value = as.numeric(str_extract(mem_alloc, "\\d+(\\.\\d+)?")),
    unit = str_extract(mem_alloc, "[KMGTP]B"),
    mem_alloc_kb = case_when(
      unit == "KB" ~ value,
      unit == "MB" ~ value * 1024,
      unit == "GB" ~ value * 1024^2,
      unit == "TB" ~ value * 1024^3,
      unit == "PB" ~ value * 1024^4,
      TRUE ~ NA_real_  # Par défaut, si l'unité n'est pas reconnue
    )
  ) %>%
  mutate(
        median = as.numeric(median, units="seconds"),
        poids = as.numeric(
            gsub(" Mo", "", c(poids_csv, poids_parquet))
        ),
        method = c("`read_parquet`", "`open_dataset`"),
    ) |>
    select(method, value, unit, median, mem_alloc_bar=mem_alloc_kb) |>
    mutate(median_bar=median)


benchmark2_table <- benchmark2 |>
    mutate(
        median = as.numeric(median, units="seconds"),
        mem_alloc = paste0(value, " ", unit),
        method = c("Parquet avec `read_parquet`", "Parquet `open_dataset` (`arrow`)"),
    )


table2 <- gt(benchmark2_table) |>
    cols_hide(c(value, unit)) |>
    gtExtras::gt_plt_bar(column=median_bar) |>
    gtExtras::gt_plt_bar(column=mem_alloc_bar) |>
    cols_move(median_bar, after=median) |>
    cols_move(mem_alloc, after=mem_alloc_bar) |>
    tab_spanner(md("**Temps d'exécution**<br> _(sec.)_"), starts_with("median")) |>
    tab_spanner(md("**Mémoire allouée**<br> _(MB)_"), starts_with("mem_alloc")) |>
    tab_spanner(md("**Poids sur disque**<br> _(Mo)_"), starts_with("poids")) |>
    fmt_number(median, decimals = 2) |>
    cols_label(everything() ~ '') |>
    fmt_markdown(method)

gtsave(table2, "./bench/mark2.html")


# PARTIE 3

url_bpe <- "https://minio.lab.sspcloud.fr/lgaliana/diffusion/BPE23.parquet" #pb temporaire github actions avec insee.fr
con <- dbConnect(duckdb())

dbExecute(
  con,
  glue(
    "INSTALL httpfs;",
    "LOAD httpfs;"
  )
)



plan1 <- dbGetQuery(
  con,
  glue(
    'EXPLAIN ANALYZE ',
    'SELECT * FROM read_parquet("{url_bpe}") LIMIT 5'
  )
)

plan2 <- dbGetQuery(
  con,
  glue(
    'EXPLAIN ANALYZE ',
    'SELECT TYPEQU, LONGITUDE, LATITUDE FROM read_parquet("{url_bpe}") LIMIT 10000'
  )
)


plan1
plan2
