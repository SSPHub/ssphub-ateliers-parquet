library(dplyr)
library(ggplot2)
library(bench)
library(gt)

source("R/benchmark_functions.R")

path_data <- "./sessions/data"
path_parquet <- glue("{path_data}/RPindividus.parquet")
path_parquet_subset <- glue("{path_data}/RPindividus_24.parquet")
path_parquet_csv <- glue("{path_data}/RPindividus_24.csv")
path_parquet_partition <- glue("{path_data}/RPindividus")


benchmark3 <- bench::mark(
  req_open_dataset_full = req_open_dataset_full(path_parquet),
  req_open_dataset_part = req_open_dataset_part(path_parquet_partition),
  iterations = 1,
  check = FALSE
)


benchmark3 <- benchmark3 |> mutate(
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


benchmark3_table <- benchmark3 |>
    mutate(
        median = as.numeric(median, units="seconds"),
        mem_alloc = paste0(value, " ", unit),
        method = c("Parquet non partitionné", "Parquet partitionné"),
    )


gt(benchmark3_table) |>
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


all_benchmark <- bind_rows(
    list(
        benchmark1_table %>% mutate(exo = "Exercice 1: CSV -> Parquet"),
        benchmark2_table %>% mutate(exo = "Exercice 2: La lazy evaluation"),
        benchmark3_table %>% mutate(exo = "Exercice 3: Enjeux du partitionnement")
    )
)

gt(all_benchmark |> group_by(exo)) |>
    gtExtras::gt_plt_bar(column=median_bar, color = "#ff562c") |>
    gtExtras::gt_plt_bar(column=mem_alloc_bar, color = "#ff562c") |>
    cols_move(median_bar, after=median) |>
    cols_move(mem_alloc_bar, after=mem_alloc_bar) |>
    cols_hide(c(unit, value, starts_with("poids"))) |>
    tab_spanner(md("**Temps d'exécution**<br> _(sec.)_"), starts_with("median")) |>
    tab_spanner(md("**Mémoire allouée**<br> _(MB)_"), starts_with("mem_alloc")) |>
    tab_spanner(md("**Poids sur disque**<br> _(Mo)_"), starts_with("poids")) |>
    cols_label(everything() ~ '') |>
    fmt_number(median, decimals = 2) |>
    fmt_number(poids, decimals = 0) |>
    fmt_markdown(method) |>
    tab_style(
        style = list(
            cell_fill(color = "#4758AB"),
            cell_text(weight = "bold", color="white")
        ),
        locations = cells_row_groups()
    )

