library(glue)
library(stringr)
library(dplyr)
library(ggplot2)
library(bench)
library(gt)

source("R/benchmark_functions.R")

path_data <- "./data"
path_parquet <- glue("{path_data}/RPindividus.parquet")
path_parquet_subset <- glue("{path_data}/RPindividus_24.parquet")
path_parquet_csv <- glue("{path_data}/RPindividus_24.csv")


benchmark1 <- bench::mark(
    req_csv = req_csv(path_csv_subset),
    req_read_parquet = req_read_parquet(path_parquet_subset),
    iterations = 1,
    check = FALSE
)

poids_csv <- mesurer_taille(path_csv_subset)
poids_parquet <- mesurer_taille(path_parquet_subset)



benchmark1_table <- benchmark1 |>
    mutate(
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
    ) |>
    mutate(
        median = as.numeric(median, units="seconds"),
        poids = as.numeric(
            gsub(" Mo", "", c(poids_csv, poids_parquet))
        ),
        method = c("CSV avec `read_csv` (`readr`)", "Parquet `read_parquet` (`arrow`)"),
    ) |>
    mutate(
        median_bar = as.numeric(median, units="seconds"),
        mem_alloc = paste0(value, " ", unit),
        poids_bar = poids
        ) |>
    select(
        method, poids, poids_bar, median, median_bar, mem_alloc, mem_alloc_bar=mem_alloc_kb
        )


benchmark1 <- gt(benchmark1_table) |>
    gtExtras::gt_plt_bar(column=median_bar) |>
    gtExtras::gt_plt_bar(column=mem_alloc_bar) |>
    gtExtras::gt_plt_bar(column=poids_bar) |>
    cols_move(median_bar, after=median) |>
    cols_move(mem_alloc_bar, after=mem_alloc_bar) |>
    tab_spanner(md("**Temps d'exécution**<br> _(sec.)_"), starts_with("median")) |>
    tab_spanner(md("**Mémoire allouée**<br> _(MB)_"), starts_with("mem_alloc")) |>
    tab_spanner(md("**Poids sur disque**<br> _(Mo)_"), starts_with("poids")) |>
    cols_label(everything() ~ '') |>
    fmt_number(median, decimals = 2) |>
    fmt_number(poids, decimals = 0) |>
    fmt_markdown(method)


dir.create("./bench")
gtsave(benchmark1, "./bench/mark1.html")
