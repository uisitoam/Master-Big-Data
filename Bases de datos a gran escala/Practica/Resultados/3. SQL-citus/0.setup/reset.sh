ssh ovh1 'bash -s' < 3.sql-citus/0.setup/all_nodes_citus.sh
ssh ovh2 'bash -s' < 3.sql-citus/0.setup/all_nodes_citus.sh
ssh ovh3 'bash -s' < 3.sql-citus/0.setup/all_nodes_citus.sh

ssh ovh1 'bash -s' < 3.sql-citus/0.setup/coordinador_citus.sh

