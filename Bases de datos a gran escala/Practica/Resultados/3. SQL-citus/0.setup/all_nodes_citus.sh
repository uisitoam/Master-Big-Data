# Eliminar extension y base de datos citus
sudo -i -u postgres psql -d citus -c "DROP EXTENSION citus CASCADE;"
sudo -i -u postgres psql -c "DROP DATABASE citus;"

# Recrear base de datos citus
sudo -i -u postgres psql -c "CREATE DATABASE citus;"

# Añadir la extension citus a la base de datos citus
sudo -i -u postgres psql -d citus -c "CREATE EXTENSION citus;"

# Verificamos que citus se ha instalado correctamente
sudo -i -u postgres psql -d citus -c "SELECT * FROM citus_version();"
