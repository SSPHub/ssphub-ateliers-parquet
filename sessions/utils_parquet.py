import os
import time
import math
from functools import wraps
import warnings

import pyarrow.parquet as pq
import pyarrow as pa

from memory_profiler import memory_usage


def convert_size(size_bytes):
  if size_bytes == 0:
      return "0B"
  size_name = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
  i = int(math.floor(math.log(size_bytes, 1024)))
  p = math.pow(1024, i)
  s = round(size_bytes / p, 2)
  return "%s %s" % (s, size_name[i])


# Decorator to measure execution time and memory usage
def measure_performance(func, return_output=False):
  @wraps(func)
  def wrapper(return_output=False, *args, **kwargs):
    warnings.filterwarnings("ignore")
    start_time = time.time()
    mem_usage = memory_usage((func, args, kwargs), interval=0.1)
    end_time = time.time()
    warnings.filterwarnings("always")

    exec_time = end_time - start_time
    peak_mem = max(mem_usage)  # Peak memory usage
    exec_time_formatted = f"\033[92m{exec_time:.4f} sec\033[0m"
    peak_mem_formatted = f"\033[92m{convert_size(1024*peak_mem)}\033[0m"

    print(f"{func.__name__} - Execution Time: {exec_time_formatted} | Peak Memory Usage: {peak_mem_formatted}")
    if return_output is True:
      return func(*args, **kwargs)

  return wrapper


def download_dataset_mc(
    filename_table_individu: str = "data/RPindividus.parquet",
    engine: str = "curl"
):

    # Copier le fichier depuis le stockage distant (remplacer par une méthode adaptée si nécessaire)
    if engine == "curl":
        os.system(
            f"curl -o {filename_table_individu} "
            f"https://projet-formation/bonnes-pratiques/data/{filename_table_individu}"
            )
    else:
        os.system(
            f"mc cp s3/projet-formation/bonnes-pratiques/{filename_table_individu} "
            f"{filename_table_individu}"
        )


    # Charger le fichier Parquet
    table = pq.read_table(filename_table_individu)
    df = table.to_pandas()

    # Filtrer les données pour REGION == "24"
    df_filtered = df.loc[df["REGION"] == "24"]

    # Sauvegarder en CSV
    df_filtered.to_csv("data/RPindividus_24.csv", index=False)

    # Sauvegarder en Parquet
    pq.write_table(
        pa.Table.from_pandas(df_filtered),
        "data/RPindividus_24.parquet"
    )
