#!/bin/bash

# ejecutar desde local: ssh user@host 'bash -s' < <path_to_this_file>

POSTGRES_PASSWORD="***"

# Añadir el repositorio de Citus al empaquetador de Ubuntu
curl https://install.citusdata.com/community/deb.sh | sudo bash

# Instalar Postgres y Citus
sudo apt-get -y install postgresql-16-citus-12.1

# Precargar la extensión Citus
sudo pg_conftool 16 main set shared_preload_libraries citus

# Iniciar el servicio de Postgres y habilitarlo para arrancar al iniciar
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Modificamos la contraseña del usuario postgres
sudo -i -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';"

# Modficicamos el archivo /etc/postgres/16/main/postgresql.conf mediante comando
sudo pg_conftool 16 main set listen_addresses '*'

# Al archivo pg_hba.conf de nuestra versión instalada añadimos la siguiente línea
# que permite acceso desde todas las IP a todas las bases de datos, a todos los usuarios mediante acceso md5 (contraseña)
echo -e "\n# Allow access from all IP addresses\nhost   all     all     0.0.0.0/0      md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

# Reiniciamos el servicio
sudo systemctl restart postgresql

# Add .pgpass file to the postgres user's home directory for coordinator-worker and worker-worker traffic
# Los diferentes nodos del clúster deben de poder comunicarse entre sí
# Para ello, creamos el archivo .pgpass en el directorio $HOME del usuario postgres
# Postgres leerá de ese archivo las contraseñas de distintas conexiones
# Usamos * para indicarle que use la misma contraseñá para todas las conexiones
sudo bash -c "echo '*:*:*:*:${POSTGRES_PASSWORD}' > /var/lib/postgresql/.pgpass"

# Cambiamos permidos de lectura y escritura unicamente para el usuario postrges
sudo chown postgres:postgres /var/lib/postgresql/.pgpass
sudo chmod 600 /var/lib/postgresql/.pgpass

echo "Setup complete!"
