#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function, division
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import sys

def load_country_codes(filename):
    """cargamos country_codes.txt como csv"""
    country_dict = {}
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) == 2:
                country_dict[parts[0].strip()] = parts[1].strip()
    return country_dict

def main():
    if len(sys.argv) != 5:
        print("Usar: p2.py dirNcitas dirInfo country_codes.txt output_dir")
        exit(-1)

    dir_ncitas = sys.argv[1]
    dir_info = sys.argv[2]
    country_codes_file = sys.argv[3]
    output_dir = sys.argv[4]

    spark = SparkSession \
        .builder \
        .appName("Practica 2 PySpark") \
        .getOrCreate()
    
    spark.sparkContext.setLogLevel("FATAL")

    # cargamos paises como diccionario 
    country_dict = load_country_codes(country_codes_file)
    # lo definimos como variable de broadcast
    country_broadcast = spark.sparkContext.broadcast(country_dict)

    # leemos los DataFrames Parquet
    df_citas = spark.read.parquet(dir_ncitas)
    df_info = spark.read.parquet(dir_info)

    # unimos las tablas y hacemos los calculos necesarios para cada columna
    df_resultado = df_info.join(df_citas, "NPatente") \
        .groupBy("Pais", "Anho") \
        .agg(
            F.count("NPatente").alias("NumPatentes"),
            F.sum("ncitas").alias("TotalCitas"),
            F.avg("ncitas").alias("MediaCitas"),
            F.max("ncitas").alias("MaxCitas")
        ) \
        .replace(country_dict, subset=["Pais"]) \
        .orderBy("Pais", "Anho")
    
    #df_resultado.show(15)

    # guardamos como csv con cabecera y sin comprimir
    df_resultado.coalesce(1) \
        .write \
        .mode("overwrite") \
        .option("header", "true") \
        .csv(output_dir)

    spark.stop()

if __name__ == "__main__":
    # quitar para ejecutar en terminal
    #sys.argv = [
    #    'p2.py', 
    #    'dfCitas.parquet', 
    #    'dfInfo.parquet',
    #    'country_codes.txt',
    #    'p2out'
    #]
    main()