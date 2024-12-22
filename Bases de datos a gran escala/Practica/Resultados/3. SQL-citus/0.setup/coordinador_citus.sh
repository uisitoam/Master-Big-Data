# Registrar la dirección del nodo coordinador
sudo -i -u postgres psql -d citus -c "SELECT citus_set_coordinator_host('51.210.241.66', 5432);"

# Añadir los nodos worker
sudo -i -u postgres psql -d citus -c "SELECT * from citus_add_node('51.210.241.239', 5432);"
sudo -i -u postgres psql -d citus -c "SELECT * from citus_add_node('51.210.241.207', 5432);"

# Verificar clúster
sudo -i -u postgres psql -d citus -c "SELECT * FROM citus_get_active_worker_nodes();"
