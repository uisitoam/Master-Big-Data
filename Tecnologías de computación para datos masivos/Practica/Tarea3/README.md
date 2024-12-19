# PROGRAMACIÓN MAP-REDUCE.
------------------------

Este archivo da las instrucciones de compilación y ejecución de cada uno de los programas. Lo haremos conectados al cluster del CESGA, lo cual se puede hacer por ssh con 
```
ssh cursoxxx@hadoop3.cesga.es
```

Con *cursoxxx* el nombre de usuario que se nos han asignado, en mi caso curso101.

## Preparación del entorno
-----------------------
Primero es necesario copiar los directorios y archivos a usar desde nuestra máquina al cluster. Debemos copiar los directorios con los proyectos java y los archivos .txt con los datos. Para eso, ejecutamos lo siguiente en nuestra máquina:
```
scp -r '/ruta/a/01-citingpatents' curso101@hadoop3.cesga.es:~ 

scp -r '/ruta/a/02-citationnumberbypatent_chained' curso101@hadoop3.cesga.es:~ 

scp -r '/ruta/a/03-simplereducesidejoin' curso101@hadoop3.cesga.es:~

scp -r '/ruta/a/apat63_99.txt' curso101@hadoop3.cesga.es:~ 

scp -r '/ruta/a/cite75_99.txt' curso101@hadoop3.cesga.es:~ 

scp -r '/ruta/a/country_codes.txt' curso101@hadoop3.cesga.es:~ 
```

donde /ruta/a/ es la ruta en nuestra máquina local. Dentro del cluster, cargamos `maven` para ejecutar los proyectos:
```
module load maven
```

Como son ficheros relativamente pequeños, especificamos un tamaño más pequeño de bloques. Esto, al tener más bloques por fichero y, por tanto, lanzar más maps, aumentará el paralelismo. Primero creamos el directorio `patentes` en HDFS
```
hdfs dfs -mkdir patentes
```

Ahora subimos los ficheros .txt a HDFS (excepto el fichero `country_codes.text`)
```
hdfs dfs -D dfs.block.size=32M -put cite75_99.txt apat63_99.txt patentes
```

## Actividad 1.
--------------------------

Dentro del directorio `01-citingpatents`, compilamos el proyecto con maven:
```
mvn package
```

y ejecutamos el job usando yarn (el fichero de salida se guardará como `salida1`, y en este caso usaremos la cola urgente del CESGA):
```
yarn jar target/citingpatents-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent patentes/cite75_99.txt salida1
```

Podemos recuperar el fichero de salida desde HDFS con:
``` 
hdfs dfs -get salida1
```





## Actividad 2.
--------------------------

Esta vez, para compilar, debemos copiar el fichero `citingpatents-0.0.1-SNAPSHOT.jar` generado en la actividad 1 al directorio `src/resources` de esta actividad. Para ello, ejecutamos:
```
cp 01-citingpatents/target/citingpatents-0.0.1-SNAPSHOT.jar 02-citationnumberbypatent_chained/src/resources
```

Ahora, compilamos de forma similar a la actividad anterior. Primero, nos movemos al directorio `02-citationnumberbypatent_chained` y ejecutamos
```
mvn package
```
Establecemos primero una variable de entorno con
```
export HADOOP_CLASSPATH="./src/resources/citingpatents-0.0.1-SNAPSHOT.jar"
```
y ejecutamos el job con yarn (el fichero de salida se guardará como `salida2`). Esta vez, no lo hacemos en la cola urgente:
```
yarn jar target/citationnumberbypatent_chained-0.0.1-SNAPSHOT.jar -libjars $HADOOP_CLASSPATH patentes/cite75_99.txt salida2
```

La salida es un fichero binario de tipo Sequence (formato clave/valor). Podemos ver el contenido de los ficheros de salida usando, por ejemplo:
```
hdfs dfs -text salida2/part-r-00000
```

## Actividad 3.
--------------------------

Para esta actividad, nos movemos al directorio `03-simplereducesidejoin` y compilamos con maven:
```
mvn package
```

Para compilar necesitamos los ficheros binarios de salida de la actividad 2. Para ello, en la ejecución del job con yarn (el fichero de salida se guardará como `salida3`), debemos especificar el fichero de salida de la actividad 2 (`salida2`):
```
yarn jar target/simplereducesidejoin-0.0.1-SNAPSHOT.jar salida2 patentes/apat63_99.txt salida3
```
De nuevo, podemos ever la salida con, por ejemplo, 
```
hdfs dfs -text salida3/part-r-00000
```

