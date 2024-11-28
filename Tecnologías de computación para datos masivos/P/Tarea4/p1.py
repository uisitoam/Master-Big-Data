#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import sys

def main():
    # Comprueba el número de argumentos
    if len(sys.argv) != 5:
        print("Usar: p1.py cite75_99.txt apat63_99.txt dfCitas.parquet dfInfo.parquet")
        exit(-1)

    path_cite75_99 = sys.argv[1]
    path_apat63_99 = sys.argv[2]
    output_dfCitas = sys.argv[3]
    output_dfInfo = sys.argv[4]

    spark = SparkSession \
        .builder \
        .appName("Practica 1 de Tomas") \
        .getOrCreate()

    # Reducir la verbosidad de los logs
    spark.sparkContext.setLogLevel("FATAL")

    # a) Procesar cite75_99.txt para obtener el número de citas por patente
    # Leer el archivo cite75_99.txt desde HDFS
    df_cite = spark.read.csv(path_cite75_99, inferSchema=True, header=False)

    # Renombrar las columnas
    df_cite = df_cite.withColumnRenamed("_c0", "citing").withColumnRenamed("_c1", "cited")

    # Contar el número de citas por patente citada
    df_ncitas = df_cite.groupBy("cited") \
        .count() \
        .withColumnRenamed("cited", "NPatente") \
        .withColumnRenamed("count", "ncitas")

    # Convertir NPatente y ncitas a enteros
    df_ncitas = df_ncitas.withColumn("NPatente", F.col("NPatente").cast("integer")) \
                         .withColumn("ncitas", F.col("ncitas").cast("integer"))

    # b) Procesar apat63_99.txt para obtener NPatente, Pais y Anho
    # Leer el archivo apat63_99.txt como texto desde HDFS
    df_apat = spark.read.text(path_apat63_99)

    # Extraer las columnas de interés según las posiciones de los caracteres
    df_info = df_apat.select(
        F.trim(F.substring(df_apat.value, 1, 7)).alias("NPatente"),
        F.trim(F.substring(df_apat.value, 58, 2)).alias("Pais"),
        F.trim(F.substring(df_apat.value, 66, 4)).alias("Anho")
    )

    # Convertir tipos de datos
    df_info = df_info.withColumn("NPatente", F.col("NPatente").cast("integer")) \
                     .withColumn("Anho", F.col("Anho").cast("integer"))

    # Guardar los DataFrames en formato Parquet con compresión gzip
    df_ncitas.write.parquet(output_dfCitas, mode="overwrite", compression="gzip")
    df_info.write.parquet(output_dfInfo, mode="overwrite", compression="gzip")

    # Mostrar el número de particiones y archivos generados
    num_partitions_ncitas = df_ncitas.rdd.getNumPartitions()
    print("DataFrame df_ncitas tiene {} particiones.".format(num_partitions_ncitas))

    num_partitions_info = df_info.rdd.getNumPartitions()
    print("DataFrame df_info tiene {} particiones.".format(num_partitions_info))

    spark.stop()

if __name__ == "__main__":
    main()