#!/bin/bash

# Debemos tener la base de datos "tenis" definida en Postgres
# Si no esta, conectar mediante psql -h <ip> -U postgres -d postgres y ejecutar "CREATE DATABASE tenis;"

# ------------------------------------------
# Ejecutar este archivo dentro de la TRABAJO
# ------------------------------------------

psql -h 51.210.241.66 -U postgres -c "DROP DATABASE IF EXISTS tenis;"
psql -h 51.210.241.66 -U postgres -c "CREATE DATABASE tenis;"

psql service=tenis -f ./0.setup/schema.sql

# Carga de datos
psql service=tenis -c "\copy pais            from ./0.setup/data/pais.csv            with (format csv)"
psql service=tenis -c "\copy torneo          from ./0.setup/data/torneo.csv          with (format csv)"
psql service=tenis -c "\copy edicion_torneo  from ./0.setup/data/edicion_torneo.csv  with (format csv)"
psql service=tenis -c "\copy jugador         from ./0.setup/data/jugador.csv         with (format csv)"
psql service=tenis -c "\copy ranking         from ./0.setup/data/ranking.csv         with (format csv)"
psql service=tenis -c "\copy partido         from ./0.setup/data/partido.csv         with (format csv)"
psql service=tenis -c "\copy sets_partido    from ./0.setup/data/sets_partido.csv    with (format csv)"
