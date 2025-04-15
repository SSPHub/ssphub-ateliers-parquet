library(arrow)
library(dplyr)
library(readr)
library(fs)

# Chemin du fichier d'entrée
filename_table_individu <- "data/RPindividus.parquet"

# Lire le fichier Parquet
df <- read_parquet(filename_table_individu)

# Filtrer les données pour REGION == "24"
df_filtered <- df %>% filter(REGION == "24")

# Sauvegarder en CSV
write_csv(df_filtered, "data/RPindividus_24.csv")

# Sauvegarder en Parquet
write_parquet(df_filtered, "data/RPindividus_24.parquet")

# Créer le dossier si nécessaire
dir_create("data/RPindividus")

# Sauvegarder en Parquet partitionné par REGION et DEPT
write_dataset(
  df,
  path = "data/RPindividus",
  format = "parquet",
  partitioning = c("REGION", "DEPT")
)
