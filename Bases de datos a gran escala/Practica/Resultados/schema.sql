CREATE TABLE pais (
  codigo_iso2 char(2) primary key,
  codigo_iso3 char(3),
  codigo_ioc char(3),
  nombre varchar(100)
);

CREATE TABLE jugador (
	id integer PRIMARY key,
	nombre varchar(100),
	apellido varchar(100),
	diestro boolean,
	fecha_nacimiento date,
	pais char(2) REFERENCES pais(codigo_iso2),
	altura integer
);

CREATE TABLE torneo (
  id integer primary key,
  nombre varchar(100),
  pais char(2) REFERENCES pais(codigo_iso2)
);


CREATE TABLE edicion_torneo (
  torneo integer REFERENCES torneo(id),
  fecha date,
  superficie varchar(20),
  tamano integer, -- Número máximo de jugadores, a veces redondeado a pontencia de 2.
  nivel char(1), --'G' = Grand Slams, 'M' = Masters 1000s, 'A' = other tour-level events, 'C' = Challengers, 'S' = Satellites/ITFs, 'F' = Tour finals and other season-ending events
  PRIMARY KEY (torneo, fecha)
);

CREATE TABLE partido (
	torneo integer,
	fecha date,
	num_partido integer,
	num_sets integer,
	ronda varchar(5), -- R128, R32, R16, QF, SF, F. BR (3º y 4º puesto), RR (grupos-Round-Robin), ER (calificaición)
	desenlace char(1), -- N: Normal, R: Retirada durante el partido, P: Pase por retirada antes del partido, D: descalificacion
	ganador integer,
	perdedor integer,
	num_aces_ganador integer,
	num_dob_faltas_ganador integer,
	num_ptos_servidos_ganador integer,
	num_primeros_servicios_ganador integer,
	num_primeros_servicios_ganados_ganador integer,
	num_segundos_servicios_ganados_ganador integer,
	num_juegos_servidos_ganador integer,
	num_break_salvados_ganador integer,
	num_break_afrontados_ganador integer,
	num_aces_perdedor integer,
	num_dob_faltas_perdedor integer,
	num_ptos_servidos_perdedor integer,
	num_primeros_servicios_perdedor integer,
	num_primeros_servicios_ganados_perdedor integer,
	num_segundos_servicios_ganados_perdedor integer,
	num_juegos_servidos_perdedor integer,
	num_break_salvados_perdedor integer,
	num_break_afrontados_perdedor integer,
	PRIMARY KEY (torneo, fecha, num_partido),
	FOREIGN KEY (torneo, fecha) REFERENCES edicion_torneo(torneo, fecha)
);

CREATE TABLE sets_partido (
	torneo integer,
	fecha date,
	num_partido integer,
	num_set integer,
	juegos_ganador integer, --numero de juegos que el ganador del partido ganó en el set
	juegos_perdedor integer,  --numero de juegos que el perdedor del partido ganó en el set
	puntos_tiebreak_perdedor integer, --número de puntos que el perdedor del set ganó en el tie-break
	PRIMARY KEY (torneo, fecha, num_partido,num_set),
	FOREIGN KEY (torneo, fecha, num_partido) REFERENCES partido(torneo, fecha, num_partido)
);

CREATE TABLE ranking (
	jugador integer,
	fecha date,
	puntos integer,
	posicion integer,
	PRIMARY KEY (jugador, fecha),
	FOREIGN KEY (jugador) REFERENCES jugador(id)
);