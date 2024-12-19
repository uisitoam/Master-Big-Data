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
        .appName("Practica PySpark Luis") \
        .getOrCreate()

    # Reducir la verbosidad de los logs
    spark.sparkContext.setLogLevel("FATAL")

    # a) A partir del fichero cite75_99.txt obtener el número de citas que ha recibido cada patente
    # leemos el archivo cite75_99.txt desde HDFS
    df_cite = spark.read.csv(path_cite75_99, inferSchema=True, header=False)

    # renombramos las columnas
    df_cite = df_cite.withColumnRenamed("_c0", "citing").withColumnRenamed("_c1", "cited")

    # contamos el número de citas por patente citada
    df_ncitas = df_cite.groupBy("cited") \
        .count() \
        .withColumnRenamed("cited", "NPatente") \
        .withColumnRenamed("count", "ncitas")

    # conversion de tipos
    df_ncitas = df_ncitas.withColumn("NPatente", F.col("NPatente").cast("integer")) \
                         .withColumn("ncitas", F.col("ncitas").cast("integer"))
    
    #df_ncitas.show(5)

    # b) A partir del fichero apat63_99.txt, crear un DataFrame que contenga el 
    #número de patente, el país y el año de concesión (columna GYEAR), descartando 
    #el resto de campos del fichero.
    df_apat = spark.read.csv(
        path_apat63_99,
        header=True,  # El archivo tiene cabecera
        inferSchema=True  # Inferir tipos de datos automáticamente
    )

    # seleccionamos y renombramos las columnas 
    df_info = df_apat.select(
        F.col("PATENT").alias("NPatente"),
        F.col("COUNTRY").alias("Pais"),
        F.col("GYEAR").alias("Anho")
    )

    # convertimos los tipos de datos y filtramos los 'no disponible'
    df_info = df_info.withColumn("NPatente", F.col("NPatente").cast("integer")) \
                     .withColumn("Anho", F.col("Anho").cast("integer")) \
                     .filter(
                        (F.col("Pais").isNotNull()) & 
                        (F.col("Pais") != "") & 
                        (F.col("Anho").isNotNull()) & 
                        (F.col("Anho") >= 1963)
                     )
    
    #df_info.show(5)

    # Guardar los DataFrames en formato Parquet con compresión gzip
    df_ncitas.write.parquet(output_dfCitas, mode="overwrite", compression="gzip")
    df_info.write.parquet(output_dfInfo, mode="overwrite", compression="gzip")

    spark.stop()

if __name__ == "__main__":
    main()