#!/bin/bash

HOSTS=(
    "51.210.241.66   ovh1"
    "51.210.241.239  ovh2"
    "51.210.241.207  ovh3"
)

# Añadir pareja {ip: alias} a /etc/hosts si no existen
for ENTRY in "${HOSTS[@]}"; do
  IP=$(echo "${ENTRY}" | awk '{print $1}')
  HOSTNAME=$(echo "${ENTRY}" | awk '{print $2}')
  
  if grep -q "${IP}" /etc/hosts; then
    echo "Entry '${ENTRY}' already exists in /etc/hosts. Skipping."
  else
    echo "Adding '${ENTRY}' to /etc/hosts"
    echo "${ENTRY}" | sudo tee -a /etc/hosts > /dev/null
  fi
done

echo "All entries processed."
echo "Tail of /etc/hosts:"

tail /etc/hosts -n 5
