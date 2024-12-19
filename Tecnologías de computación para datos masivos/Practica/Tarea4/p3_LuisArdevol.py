#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
from pyspark.sql import Window
import pyspark.sql.functions as F
import sys

def main():
    if len(sys.argv) != 5:
        print("Usar: p3.py dirNcitas dirInfo paises output_dir")
        exit(-1)

    dir_ncitas = sys.argv[1]
    dir_info = sys.argv[2]
    paises = sys.argv[3].split(',')  # Lista de países separados por coma
    output_dir = sys.argv[4]

    spark = SparkSession \
        .builder \
        .appName("Practica Opcional 1 PySpark") \
        .getOrCreate()
    
    spark.sparkContext.setLogLevel("FATAL")

    # leemos los DataFrames Parquet
    df_citas = spark.read.parquet(dir_ncitas)
    df_info = spark.read.parquet(dir_info)

    # unimos las tablas y filtramos por paises
    df_join = df_info.join(df_citas, "NPatente") \
        .filter(F.col("Pais").isin(paises))

    # creamos una ventana para calcular el rango por país y año
    windowSpec = Window \
        .partitionBy("Pais", "Anho") \
        .orderBy(F.col("ncitas").desc())

    # calculamos el rango y cogemos las columnas para el resultado final
    df_resultado = df_join \
        .select(
            "Pais",
            "Anho",
            F.col("NPatente"),
            F.col("ncitas").alias("Ncitas"),
            F.dense_rank().over(windowSpec).alias("Rango")
        ) \
        .orderBy("Pais", "Anho", F.col("Ncitas").desc())

    # guardamos como csv con cabecera y sin comprimir
    df_resultado.coalesce(1) \
        .write \
        .mode("overwrite") \
        .option("header", "true") \
        .csv(output_dir)

    spark.stop()

if __name__ == "__main__":
    main()