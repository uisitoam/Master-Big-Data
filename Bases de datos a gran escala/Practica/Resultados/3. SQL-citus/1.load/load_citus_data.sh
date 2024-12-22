#!/bin/bash
./3.sql-citus/0.setup/reset.sh

# ------------------------------------------
# This script sets up the Citus database based on the selected mode
# ------------------------------------------

# Ask the user for the mode (normal, replicate, columnar)
echo "Choose the mode (normal/replicate/columnar):"
read mode

# Validate the input mode
if [[ "$mode" == "normal" ]]; then
    echo "NORMAL_MODE."
    # Execute the normal schema setup
    psql service=citus -f './3.sql-citus/1.load/schema_citus.sql'
elif [[ "$mode" == "replicate" ]]; then
    echo "REPLICATION_MODE."
    # Execute the replicate schema setup
    psql service=citus -f './3.sql-citus/1.load/schema_replication_2.sql'
elif [[ "$mode" == "columnar" ]]; then
    echo "COLUMNAR_MODE."
    # Execute the columnar schema setup
    psql service=citus -f './3.sql-citus/1.load/schema_columnar.sql'
else
    echo "Invalid mode selected. Please choose 'normal', 'replicate', or 'columnar'."
    exit 1
fi

psql service=citus -c "\copy pais            from ./0.setup/data/pais.csv            with (format csv)"
psql service=citus -c "\copy torneo          from ./0.setup/data/torneo.csv          with (format csv)"
psql service=citus -c "\copy edicion_torneo  from ./0.setup/data/edicion_torneo.csv  with (format csv)"
psql service=citus -c "\copy jugador         from ./0.setup/data/jugador.csv         with (format csv)"
psql service=citus -c "\copy ranking         from ./0.setup/data/ranking.csv         with (format csv)"
psql service=citus -c "\copy partido         from ./0.setup/data/partido.csv         with (format csv)"
psql service=citus -c "\copy sets_partido    from ./0.setup/data/sets_partido.csv    with (format csv)"

# Show tables
psql service=citus -c "SELECT * FROM citus_tables;"
