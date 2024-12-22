# Local

# generar la tabla y el archivo partidos.json
psql service=tenis -f 4.mongo/sql_to_json.sql

# sacarlo de la maquina ovh3 a local
scp -3 ovh1:~/partidos.json 4.mongo

# moverlo de local a la maquina ovh2 con mongo





# En OVH2
sudo mv /tmp/partidos.json .
mongoimport --db=tenis --collection partidos --file=partidos.json

