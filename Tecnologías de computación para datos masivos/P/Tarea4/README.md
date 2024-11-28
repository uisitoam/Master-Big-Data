# PROGRAMACIÓN Apache PySpark.
------------------------

Este archivo da las instrucciones de ejecución (aunque sea un único comando) de cada uno de los programas. Lo haremos conectados al cluster del CESGA, lo cual se puede hacer por ssh con 
```
ssh cursoxxx@hadoop3.cesga.es
```

Con *cursoxxx* el nombre de usuario que se nos han asignado, en mi caso curso101.

## Preparación del entorno
-----------------------
Primero es necesario copiar los directorios y archivos a usar desde nuestra máquina al cluster. Debemos copiar los directorios con los proyectos java y los archivos .txt con los datos. Para eso, ejecutamos lo siguiente en nuestra máquina:
```
scp -r /ruta/a/p1_LuisArdevol.py curso101@hadoop3.cesga.es:~
scp -r /ruta/a/p2_LuisArdevol.py curso101@hadoop3.cesga.es:~
scp -r /ruta/a/p3_LuisArdevol.py curso101@hadoop3.cesga.es:~
scp -r /ruta/a/p4_LuisArdevol.py curso101@hadoop3.cesga.es:~
```

En caso de tener los ficheros `.txt` necesarios en HDFS, se puede pasar al ejercicio 1 directamente. En caso de no tener los archivos `.txt` de la práctica anterior, también es necesario copiarlos al cluster:
```
scp -r '/ruta/a/apat63_99.txt' curso101@hadoop3.cesga.es:~ 

scp -r '/ruta/a/cite75_99.txt' curso101@hadoop3.cesga.es:~ 

scp -r '/ruta/a/country_codes.txt' curso101@hadoop3.cesga.es:~
```

Como son ficheros relativamente pequeños, especificamos un tamaño más pequeño de bloques. Esto, al tener más bloques por fichero y, por tanto, lanzar más maps, aumentará el paralelismo. Primero creamos el directorio `patentes` en HDFS
```
hdfs dfs -mkdir patentes
```

Ahora subimos los ficheros .txt a HDFS (excepto el fichero `country_codes.text`)
```
hdfs dfs -D dfs.block.size=32M -put cite75_99.txt apat63_99.txt patentes
```

## Actividad 1 (p1_LuisArdevol.py).
--------------------------

Extraer información de los ficheros `cite75_99.txt` y `apat63_99.txt`. Crear un script que haga lo siguiente:
* A partir del fichero `cite75_99.txt` obtener el número de citas que ha recibido cada patente.
* A partir del fichero `apat63_99.txt`, crear un DataFrame que contenga el número de patente, el país y el año de concesión (columna GYEAR), descartando el resto de campos del fichero.

Para ejecutar el script usando la cola urgente, simplemente usamos
```
spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent p1_LuisArdevol.py cite75_99.txt apat63_99.txt dfCitas.parquet dfInfo.parquet
```

donde `cite75_99.txt` y `apat63_99.txt` son los ficheros de entrada, y `dfCitas.parquet` y `dfInfo.parquet` son los ficheros de salida.

## Actividad 2 (p2_LuisArdevol.py).
--------------------------
Script que, a partir de los datos en Parquet de la práctica anterior, obtenga para cada país y para cada año el total de patentes, el total de citas obtenidas por todas las patentes, la media de citas y el máximo número de citas.

Para ejecutar el script usando la cola urgente, simplemente usamos
```
spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent p2_LuisArdevol.py dfCitas.parquet dfInfo.parquet country_codes.txt p2out
```

donde `dfCitas.parquet` y `dfInfo.parquet` son los ficheros de entrada, `country_codes.txt` es el fichero con los códigos de país, y `p2out` es el directorio de salida. Para ver el csv generado, recuperamos el directorio de salida hdfs con
```
hdfs dfs -get p2out
```

y dentro del mismo estará el csv generado.

## Actividad 3 (opcional) (p3_LuisArdevol.py).
--------------------------
Obtener a partir de los fichero Parquet creados en la actividad 1 un DataFrame que proporcione, para un grupo de países especificado, las patentes ordenadas por número de citas, de mayor a menor, junto con una columna que indique el rango (posición de la patente en esa país/año según las citas obtenidas).

Para ejecutar el script usando la cola urgente, simplemente usamos
```
spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent p3_LuisArdevol.py dfCitas.parquet dfInfo.parquet FR,ES outdir_op1
```

donde `dfCitas.parquet` y `dfInfo.parquet` son los ficheros de entrada, `FR,ES` es la lista de países a considerar (ejemplo contemplado en el campus virtual), y `outdir_op1` es el directorio de salida. Para ver el csv generado, recuperamos el directorio de salida hdfs con
```
hdfs dfs -get outdir_op1
```

y dentro del mismo estará el csv generado.

## Actividad 4 (opcional) (p4_LuisArdevol.py).
--------------------------
Obtener a partir del fichero Parquet con la información de (Npatente, Pais y Año) un DataFrame que nos muestre el número de patentes asociadas a cada país por cada década (entendemos por década los años del 0 al 9, es decir de 1970 a 1979 es una década). Adicionalmente, debe mostrar el aumento o disminución del número de patentes para cada país y década con respecto al la década anterior.

Para ejecutar el script usando la cola urgente, simplemente usamos
```
spark-submit --master yarn --num-executors 8 --driver-memory 4g --queue urgent p4_LuisArdevol.py dfInfo.parquet outdir_op2
```

donde `dfInfo.parquet` es el fichero de entrada, y `outdir_op2` es el directorio de salida. Para ver el csv generado, recuperamos el directorio de salida hdfs con
```
hdfs dfs -get outdir_op2
```

y dentro del mismo estará el csv generado.