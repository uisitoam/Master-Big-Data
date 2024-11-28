#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
from pyspark.sql import Window
import pyspark.sql.functions as F
import sys

def main():
    if len(sys.argv) != 3:
        print("Usar: p4.py dfInfo.parquet output_dir")
        exit(-1)

    input_parquet = sys.argv[1]
    output_dir = sys.argv[2]

    spark = SparkSession \
        .builder \
        .appName("Practica Opcional 2 PySpark") \
        .getOrCreate()
    
    spark.sparkContext.setLogLevel("FATAL")

    # leemos los DataFrames Parquet
    df_info = spark.read.parquet(input_parquet)

    # creamos una columna para las decadas
    df_decadas = df_info \
        .withColumn("Decada", (F.floor(F.col("Anho") / 10) * 10).cast("integer"))

    # agrupamos por pais y decada y contamos las patentes
    df_conteo = df_decadas \
        .groupBy("Pais", "Decada") \
        .agg(F.count("NPatente").alias("NPatentes"))

    # creamos una ventana para calcular la diferencia con la decada anterior
    windowSpec = Window \
        .partitionBy("Pais") \
        .orderBy("Decada")

    # calculamos la diferencia y ordenamos el resultado
    df_resultado = df_conteo \
        .withColumn("Dif", 
            F.col("NPatentes") - F.lag("NPatentes").over(windowSpec)
        ) \
        .fillna(0, subset=["Dif"]) \
        .orderBy("Pais", "Decada")

    # guardamos como csv con cabecera y sin comprimir
    df_resultado.coalesce(1) \
        .write \
        .mode("overwrite") \
        .option("header", "true") \
        .csv(output_dir)

    spark.stop()

if __name__ == "__main__":
    main()