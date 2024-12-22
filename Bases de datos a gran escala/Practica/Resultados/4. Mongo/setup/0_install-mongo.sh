#!/bin/bash

# run from local with: ssh user@host 'bash -s' < <path_to_this_file>

# Importar la clave de mongo al llavero del sistema operativo
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc |  gpg --dearmor | sudo tee /usr/share/keyrings/mongodb.gpg > /dev/null

# Actualizar el repositorio de apt para incluir mongo-org
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Actualizar el controlador de paquetes del sistema
sudo apt update

# Instalar mongo
sudo apt install -y mongodb-org

# Mostrar versiones instaladas
mongod --version
mongosh --version

# Reiniciar el sistemaa
sudo reboot
