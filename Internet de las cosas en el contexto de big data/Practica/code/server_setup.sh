# Instalar Fiware - Orion Context Broker
sudo yum install wget
wget https://nexus.lab.fiware.org/repository/el/8/x86_64/release/contextBroker-3.6.0-1.x86_64.rpm
sudo yum localinstall contextBroker-3.6.0-1.x86_64.rpm


# Instalar MongoDB
MONGO_REPO_FILE="/etc/yum.repos.d/mongodb-org.repo"

cat <<EOF > "$MONGO_REPO_FILE"
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
EOF

yum repolist
sudo yum install mongodb-org

# Instalar MySQL (MariaDB)
sudo yum install mariadb-server

# Instalar Cygnus
sudo wget -P /etc/yum.repos.d/ https://nexus.lab.fiware.org/repository/raw/public/repositories/el/7/x86_64/fiware-release.repo
sudo yum install cygnus-ngsi
sudo yum install java-1.8.0-openjdk
sudo yum -y install firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Configuración del Server
# Revisar si el puerto está bien
sudo firewall-cmd --zone=public --add-port=1026/tcp --permanent
sudo firewall-cmd --reload

## Iniciar MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

## Iniciar el ContextBroker
sudo /etc/init.d/contextBroker start
sudo /etc/init.d/contextBroker enable

echo "Copiar ficheros de configuración de cygnus (no tocar) en la carpeta /usr/cygnus/conf/"
