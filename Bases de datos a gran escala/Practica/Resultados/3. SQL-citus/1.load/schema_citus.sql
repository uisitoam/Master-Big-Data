DROP TABLE IF EXISTS pais CASCADE;
DROP TABLE IF EXISTS jugador CASCADE;
DROP TABLE IF EXISTS torneo CASCADE;
DROP TABLE IF EXISTS edicion_torneo CASCADE;
DROP TABLE IF EXISTS partido CASCADE;
DROP TABLE IF EXISTS sets_partido CASCADE;
DROP TABLE IF EXISTS ranking CASCADE;

SET citus.shard_replication_factor = 1;

CREATE TABLE pais (
    codigo_iso2     CHAR(2)         PRIMARY KEY,
    codigo_iso3     CHAR(3)         UNIQUE NOT NULL,
    codigo_ioc      CHAR(3)         UNIQUE,
    nombre          VARCHAR(100)    UNIQUE NOT NULL
);

CREATE TABLE jugador (
    id                      INT             PRIMARY KEY,
    nombre                  VARCHAR(100)    NOT NULL,
    apellido                VARCHAR(100)    NOT NULL,
    diestro                 BOOLEAN         NOT NULL,
    fecha_nacimiento        DATE,
    pais                    CHAR(2)         REFERENCES pais(codigo_iso2),
    altura                  INT
);

CREATE TABLE torneo (
    id                      INT             PRIMARY KEY,
    nombre                  VARCHAR(100)    NOT NULL,
    pais                    CHAR(2)         REFERENCES pais(codigo_iso2)
);

CREATE TABLE edicion_torneo (
    torneo                  INT             REFERENCES torneo(id) NOT NULL,
    fecha                   DATE,
    superficie              VARCHAR(20),
    tamano                  INT             NOT NULL, -- Número máximo de jugadores, a veces redondeado a pontencia de 2.
    nivel                   CHAR(1)         NOT NULL, --'G' = Grand Slams, 'M' = Masters 1000s, 'A' = other tour-level events, 'C' = Challengers, 'S' = Satellites/ITFs, 'F' = Tour finals and other season-ending events
    PRIMARY KEY (torneo, fecha)
    
);

CREATE TABLE partido (
    torneo                  INT,
    fecha                   DATE,
    num_partido             INT,
    num_sets                INT,
    ronda                   VARCHAR(4), -- R128, R32, R16, QF, SF, F, BR (3º y 4º puesto), RR (grupos-Round-Robin), ER (calificaición)
	desenlace               CHAR(1), -- N: Normal, R: Retirada durante el partido, P: Pase por retirada antes del partido, D: descalificacion
	ganador                 INT,
	perdedor                INT,
	num_aces_ganador                        INT,
	num_dob_faltas_ganador                  INT,
	num_ptos_servidos_ganador               INT,
	num_primeros_servicios_ganador          INT,
	num_primeros_servicios_ganados_ganador  INT,
	num_segundos_servicios_ganados_ganador  INT,
	num_juegos_servidos_ganador             INT,
	num_break_salvados_ganador              INT,
	num_break_afrontados_ganador            INT,
	num_aces_perdedor                       INT,
	num_dob_faltas_perdedor                 INT,
	num_ptos_servidos_perdedor              INT,
	num_primeros_servicios_perdedor         INT,
	num_primeros_servicios_ganados_perdedor INT,
	num_segundos_servicios_ganados_perdedor INT,
	num_juegos_servidos_perdedor            INT,
	num_break_salvados_perdedor             INT,
	num_break_afrontados_perdedor           INT,

    PRIMARY KEY (torneo, fecha, num_partido)
    -- FOREIGN KEY (torneo, fecha) REFERENCES edicion_torneo(torneo, fecha)
);

CREATE TABLE sets_partido (
    torneo                          INT,
    fecha                           DATE NOT NULL,
    num_partido                     INT,
    num_set                         INT NOT NULL,
    juegos_ganador                  INT NOT NULL,
    juegos_perdedor                 INT NOT NULL,
    puntos_tiebreak_perdedor        INT,
    PRIMARY KEY (torneo, fecha, num_partido, num_set)
    -- FOREIGN KEY (torneo, fecha, num_partido) REFERENCES partido (torneo, fecha, num_partido)
);

CREATE TABLE ranking (
    jugador     INT REFERENCES jugador(id) NOT NULL,
    fecha       DATE NOT NULL,
    puntos      INT,
    posicion    INT,
    --
    PRIMARY KEY (jugador, fecha)
);

-- Tablas de referencia (copiadas a todos los worker)
SELECT create_reference_table('pais');
SELECT create_reference_table('torneo');
SELECT create_reference_table('jugador');

-- Tablas distribuidas
SELECT create_distributed_table('partido', 'torneo');
SELECT create_distributed_table('edicion_torneo', 'torneo', colocate_with => 'partido');
SELECT create_distributed_table('sets_partido', 'torneo', colocate_with => 'partido');
SELECT create_distributed_table('ranking', 'jugador');

-- Despues de distribuir las tablas, podemos crear las claves foraneas, no antes

-- Clave foranea para partido
ALTER TABLE partido 
ADD CONSTRAINT partido_torneo_fecha_fkey
FOREIGN KEY (torneo, fecha) 
REFERENCES edicion_torneo (torneo, fecha);

-- Clave foranea para sets_partido
ALTER TABLE sets_partido 
ADD CONSTRAINT sets_partido_torneo_fecha_num_partido_fkey
FOREIGN KEY (torneo, fecha, num_partido) 
REFERENCES partido (torneo, fecha, num_partido);

SELECT * FROM citus_tables;
