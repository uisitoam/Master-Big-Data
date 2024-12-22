#!/bin/bash

# Rutas de archivos y carpetas
MONGO_KEYFILE_NAME="mongo_keyfile"
MONGO_KEYFILE="./4.mongo/setup/${MONGO_KEYFILE_NAME}"
MONGO_CONFIGS="./4.mongo/setup/configs/*"
MONGO_CONFIGS_PATH="/home/ubuntu/mongo/config/"
MONGO_DB_PATH="/home/ubuntu/dbMongo/"

# Hosts
REMOTE_HOSTS=("ovh1" "ovh2" "ovh3")


for REMOTE_HOST in "${REMOTE_HOSTS[@]}"; do

  ssh "$REMOTE_HOST" "sudo rm -r $MONGO_DB_PATH"

  # Crear los directorios necesarios en cada máquina

  ssh "$REMOTE_HOST" "mkdir -p ${MONGO_CONFIGS_PATH}"

  ssh "$REMOTE_HOST" "mkdir -p ${MONGO_DB_PATH}/rsConfServer"
  ssh "$REMOTE_HOST" "mkdir -p ${MONGO_DB_PATH}/rsShard1"
  ssh "$REMOTE_HOST" "mkdir -p ${MONGO_DB_PATH}/rsShard2"
  ssh "$REMOTE_HOST" "mkdir -p ${MONGO_DB_PATH}/rsShard3"
  ssh "$REMOTE_HOST" "mkdir -p ${MONGO_DB_PATH}/mongos"

  # Copiar el archivo keyFile
  scp "$MONGO_KEYFILE" "${REMOTE_HOST}:~/"

  # Copiar los archivos de configuración
  scp $MONGO_CONFIGS "${REMOTE_HOST}:${MONGO_CONFIGS_PATH}"

  # Dar permisos de lectura y escritura para el archivo keyFile
  ssh "$REMOTE_HOST" "sudo chmod 600 ~/$MONGO_KEYFILE_NAME"

done
