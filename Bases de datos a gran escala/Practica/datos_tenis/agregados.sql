-- tipo para pais
create type pais_info as (
	codigo_iso2 char(2),
	codigo_iso3 char(3),
	codigo_ioc char(3),
	nombre varchar(100)
);
create type torneo_info as (
	id integer,
	nombre varchar(100),
	pais pais_info
)
create type edicion_torneo_info as (
	torneo torneo_info,
	fecha date,
	superficie varchar(20),
	tamano integer,
	nivel char(1)
)
-- tipo set
CREATE TYPE set_info AS (
	torneo torneo_info,
	fecha date,
	num_partido integer,
   num_set integer,
  juegos_ganador integer,
  juegos_perdedor integer,
  puntos_tiebreak_perdedor integer
);
-- tipo para las stats del jugador durante el partido
create type jugador_stats as (
	num_aces integer,
	num_dob_faltas integer,
	num_ptos_servidos integer,
	num_primeros_servicios integer,
	num_primeros_servicios_ganados integer,
	num_segundos_servicios_ganados integer,
	num_juegos_servidos integer,
	num_break_salvados integer,
	num_break_afrontados integer
)
-- tipo jugador (un array es homogeneo, una tupla no !!)
CREATE TYPE jugador_info AS (
  id integer,
  nombre varchar(100),
  apellido varchar(100),
  diesto boolean,
  fecha_nacimiento date,
  pais pais_info,
  altura integer
);
CREATE TABLE partidos (
  torneo edicion_torneo_info,
  fecha date,
  num_partido integer,
  num_sets integer,
  info_sets set_info array, -- array de elemtnos de tipo set_info
  ronda varchar(5), -- R128, R32, R16, QF, SF, F. BR (3º y 4º puesto), RR (grupos-Round-Robin), ER (calificaición)
	desenlace char(1), -- N: Normal, R: Retirada durante el partido, P: Pase por retirada antes del partido, D: descalificacion
	ganador jugador_info,
	perdedor jugador_info,
	ganador_stats jugador_stats,
	perdedor_stats jugador_stats
);
select * from partidos
-- insertar datos
insert into partidos(
torneo, fecha, num_partido, num_sets, info_sets, ronda, desenlace, ganador, perdedor, ganador_stats, perdedor_stats)
select
  -- campo 'torneo' (tipo 'torneo_info')
  case
      when t.id is null then null
      else cast((cast((t.id, t.nombre, cast((pa.codigo_iso2, pa.codigo_iso3, pa.codigo_ioc, pa.nombre) as pais_info)) as torneo_info),
      et.fecha, et.superficie, et.tamano, et.nivel) as edicion_torneo_info)
  end as torneo,
   -- Campos directamente desde 'partido'
  p.fecha as fecha,
  p.num_partido as num_partido,
  p.num_sets as num_sets,
   -- Campo 'info_set' (array de 'set_info')
  array(select cast((cast((t.id, t.nombre, cast((pa.codigo_iso2, pa.codigo_iso3, pa.codigo_ioc, pa.nombre) as pais_info)) as torneo_info),
                     sp.fecha, sp.num_partido, sp.num_set, sp.juegos_ganador, sp.juegos_perdedor, sp.puntos_tiebreak_perdedor) as set_info)
        from public.sets_partido sp
        where sp.torneo = p.torneo
          and sp.torneo = t.id
        	and sp.fecha = p.fecha
        	and sp.num_partido = p.num_partido
        order by sp.num_set) as info_sets,
   -- Campos 'ronda' y 'desenlace'
  p.ronda as ronda,
  p.desenlace as desenlace,
   -- Campo 'ganador' (tipo 'jugador_info')
  case
      when jg.id is null then null
      else cast((jg.id, jg.nombre, jg.apellido, jg.diestro, jg.fecha_nacimiento,
      		   cast((pg.codigo_iso2, pg.codigo_iso3, pg.codigo_ioc, pg.nombre) as pais_info),
      		   jg.altura) as jugador_info)
  end as ganador,
   -- Campo 'perdedor' (tipo 'jugador_info')
  case
      when jp.id is null then null
      else cast((jp.id, jp.nombre, jp.apellido, jp.diestro, jp.fecha_nacimiento,
      		   cast((pp.codigo_iso2, pp.codigo_iso3, pp.codigo_ioc, pp.nombre) as pais_info),
      		   jp.altura) as jugador_info)
  end as perdedor,
   -- Campo 'ganador_stats' (tipo 'jugador_stats')
  case
      when jg.id is null and jp.id is null then null
      else cast((p.num_aces_ganador, p.num_dob_faltas_ganador,
          	   p.num_ptos_servidos_ganador, p.num_primeros_servicios_ganador,
          	   p.num_primeros_servicios_ganados_ganador, p.num_segundos_servicios_ganados_ganador,
          	   p.num_juegos_servidos_ganador, p.num_break_salvados_ganador,
          	   p.num_break_afrontados_ganador) as jugador_stats)
  end as ganador_stats,
   -- Campo 'perdedor_stats' (tipo 'jugador_stats')
  case
      when jg.id is null and jp.id is null then null
      else cast((p.num_aces_perdedor, p.num_dob_faltas_perdedor,
          	   p.num_ptos_servidos_perdedor, p.num_primeros_servicios_perdedor,
          	   p.num_primeros_servicios_ganados_perdedor, p.num_segundos_servicios_ganados_perdedor,
          	   p.num_juegos_servidos_perdedor, p.num_break_salvados_perdedor,
          	   p.num_break_afrontados_perdedor) as jugador_stats)
  end as perdedor_stats
from public.partido p join public.torneo t on p.torneo = t.id
  left join public.edicion_torneo et on et.torneo = t.id
  left join public.pais pa on t.pais = pa.codigo_iso2
  join public.jugador jg on p.ganador = jg.id
  left join public.pais pg on jg.pais = pg.codigo_iso2
  join public.jugador jp on p.perdedor = jp.id
  left join public.pais pp on jp.pais = pp.codigo_iso2;
 
 
 
 
 
 
 
 
 
 
 
 
 
--CONSULTAS
--Q1
select distinct (ganador).nombre, (ganador).apellido, extract(year from fecha) as ano
from partidos
where (torneo).torneo.nombre = 'Wimbledon'
	and ronda = 'F'
order by ano


--Q2 DUDA ((algo).algo).algo o (algo).algo.algo


--Q3
select distinct ronda, desenlace,
	(ganador).nombre || ' ' || (ganador).apellido as ganador,
	(perdedor).nombre || ' ' || (perdedor).apellido as perdedor,
	(select string_agg(iset.juegos_ganador || '-' || iset.juegos_perdedor ||
	case
		when iset.puntos_tiebreak_perdedor is not null then
			'(' || iset.puntos_tiebreak_perdedor || ')'
		else ''
	end, ', ' order by iset.num_set)
	from unnest(info_sets) as iset) as resultado
from partidos
where ronda in ('SF', 'F')
	and (torneo).torneo.nombre = 'Roland Garros'
	and extract(year from fecha) = '2018'
	
 
 
 
--Q4

 
 
 
--Q5
with rival_nadal as (
	select distinct case when (ganador).nombre = 'Rafael' then (perdedor).nombre || ' ' || (perdedor).apellido
						 else (ganador).nombre || ' ' || (ganador).apellido end as jugador
	from partidos
	where (((ganador).nombre = 'Rafael' and (ganador).apellido = 'Nadal') or
		  ((perdedor).nombre = 'Rafael' and(perdedor).apellido = 'Nadal'))
		and ronda = 'R128'
		and (torneo).torneo.nombre = 'Roland Garros'
		and extract(year from fecha) = '2018'
)
select distinct (p.perdedor).nombre || ' ' || (p.perdedor).apellido as jugador, (p.perdedor).pais.codigo_iso2 as pais
from partidos p, rival_nadal rn
where (p.ganador).nombre || ' ' || (p.ganador).apellido = rn.jugador
	and extract(year from p.fecha) = '2018'
order by jugador










































CREATE TABLE tenisjson AS
SELECT
   -- Columna 'jugador' como JSON
   jsonb_build_object(
       'id', j.id,
       'nombre', j.nombre,
       'apellido', j.apellido,
       'diestro', j.diestro,
       'fecha_nacimiento', j.fecha_nacimiento,
       'altura', j.altura
   ) AS jugador,
   -- Columna 'pais' como JSON
   jsonb_build_object(
       'codigo_iso2', p.codigo_iso2,
       'codigo_iso3', p.codigo_iso3,
       'codigo_ioc', p.codigo_ioc,
       'nombre', p.nombre
   ) AS pais,
   -- Columna 'partidos_ganados' como JSON
   (
       SELECT jsonb_agg(
           jsonb_build_object(
               'torneo', jsonb_build_object(
                   'nombre', t.nombre,
                   'pais', jsonb_build_object(
                       'codigo_iso2', pa.codigo_iso2,
                       'codigo_iso3', pa.codigo_iso3,
                       'codigo_ioc', pa.codigo_ioc,
                       'nombre', pa.nombre
                   ),
                   'fecha', et.fecha,
                   'superficie', et.superficie,
                   'tamano', et.tamano,
                   'nivel', et.nivel
               ),
               'fecha', pg.fecha,
               'sets', (
                   SELECT jsonb_agg(
                       jsonb_build_object(
                           'juegos_ganador', sp.juegos_ganador,
                           'juegos_perdedor', sp.juegos_perdedor,
                           'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
                       )
                   )
                   FROM public.sets_partido sp
                   WHERE sp.torneo = pg.torneo
                     AND sp.fecha = pg.fecha
                     AND sp.num_partido = pg.num_partido
                  
                   ORDER BY sp.num_set
               ),
               'ronda', pg.ronda,
               'desenlace', pg.desenlace,
               'rival', pg.perdedor,
               'stats', jsonb_build_object(
                   'num_aces_ganador', pg.num_aces_ganador,
                   'num_dob_faltas_ganador', pg.num_dob_faltas_ganador,
                   'num_ptos_servidos_ganador', pg.num_ptos_servidos_ganador,
                   'num_primeros_servicios_ganador', pg.num_primeros_servicios_ganador,
                   'num_primeros_servicios_ganados_ganador', pg.num_primeros_servicios_ganados_ganador,
                   'num_segundos_servicios_ganados_ganador', pg.num_segundos_servicios_ganados_ganador,
                   'num_juegos_servidos_ganador', pg.num_juegos_servidos_ganador,
                   'num_break_salvados_ganador', pg.num_break_salvados_ganador,
                   'num_break_afrontados_ganador', pg.num_break_afrontados_ganador
               ),
               'stats_rival', jsonb_build_object(
                   'num_aces_perdedor', pg.num_aces_perdedor,
                   'num_dob_faltas_perdedor', pg.num_dob_faltas_perdedor,
                   'num_ptos_servidos_perdedor', pg.num_ptos_servidos_perdedor,
                   'num_primeros_servicios_perdedor', pg.num_primeros_servicios_perdedor,
                   'num_primeros_servicios_ganados_perdedor', pg.num_primeros_servicios_ganados_perdedor,
                   'num_segundos_servicios_ganados_perdedor', pg.num_segundos_servicios_ganados_perdedor,
                   'num_juegos_servidos_perdedor', pg.num_juegos_servidos_perdedor,
                   'num_break_salvados_perdedor', pg.num_break_salvados_perdedor,
                   'num_break_afrontados_perdedor', pg.num_break_afrontados_perdedor
               )
           )
       )
       FROM public.partido pg, public.torneo t, public.edicion_torneo et, public.pais pa
       WHERE pg.ganador = j.id
         AND pg.torneo = t.id
         AND pg.torneo = et.torneo
         AND pg.fecha = et.fecha
         AND t.pais = pa.codigo_iso2
   ) AS partidos_ganados,
   -- Columna 'partidos_perdidos' como JSON
   (
       SELECT jsonb_agg(
           jsonb_build_object(
               'torneo', jsonb_build_object(
                   'nombre', t.nombre,
                   'pais', jsonb_build_object(
                       'codigo_iso2', pa.codigo_iso2,
                       'codigo_iso3', pa.codigo_iso3,
                       'codigo_ioc', pa.codigo_ioc,
                       'nombre', pa.nombre
                   ),
                   'fecha', et.fecha,
                   'superficie', et.superficie,
                   'tamano', et.tamano,
                   'nivel', et.nivel
               ),
               'fecha', pp.fecha,
               'sets', (
                   SELECT jsonb_agg(
                       jsonb_build_object(
                           'juegos_ganador', sp.juegos_ganador,
                           'juegos_perdedor', sp.juegos_perdedor,
                           'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
                       )
                   )
                   FROM public.sets_partido sp
                   WHERE sp.torneo = pp.torneo
                     AND sp.fecha = pp.fecha
                     AND sp.num_partido = pp.num_partido
                   group by sp.num_set
                   ORDER BY sp.num_set
               ),
               'ronda', pp.ronda,
               'desenlace', pp.desenlace,
               'rival', pp.ganador,
               'stats', jsonb_build_object(
                   'num_aces_perdedor', pp.num_aces_perdedor,
                   'num_dob_faltas_perdedor', pp.num_dob_faltas_perdedor,
                   'num_ptos_servidos_perdedor', pp.num_ptos_servidos_perdedor,
                   'num_primeros_servicios_perdedor', pp.num_primeros_servicios_perdedor,
                   'num_primeros_servicios_ganados_perdedor', pp.num_primeros_servicios_ganados_perdedor,
                   'num_segundos_servicios_ganados_perdedor', pp.num_segundos_servicios_ganados_perdedor,
                   'num_juegos_servidos_perdedor', pp.num_juegos_servidos_perdedor,
                   'num_break_salvados_perdedor', pp.num_break_salvados_perdedor,
                   'num_break_afrontados_perdedor', pp.num_break_afrontados_perdedor
               ),
               'stats_rival', jsonb_build_object(
                   'num_aces_ganador', pp.num_aces_ganador,
                   'num_dob_faltas_ganador', pp.num_dob_faltas_ganador,
                   'num_ptos_servidos_ganador', pp.num_ptos_servidos_ganador,
                   'num_primeros_servicios_ganador', pp.num_primeros_servicios_ganador,
                   'num_primeros_servicios_ganados_ganador', pp.num_primeros_servicios_ganados_ganador,
                   'num_segundos_servicios_ganados_ganador', pp.num_segundos_servicios_ganados_ganador,
                   'num_juegos_servidos_ganador', pp.num_juegos_servidos_ganador,
                   'num_break_salvados_ganador', pp.num_break_salvados_ganador,
                   'num_break_afrontados_ganador', pp.num_break_afrontados_ganador
               )
           )
       )
       FROM public.partido pp, public.torneo t, public.edicion_torneo et, public.pais pa
       WHERE pp.perdedor = j.id
         AND pp.torneo = t.id
         AND pp.torneo = et.torneo
         AND pp.fecha = et.fecha
         AND t.pais = pa.codigo_iso2
   ) AS partidos_perdidos
FROM public.jugador j
LEFT JOIN public.pais p ON j.pais = p.codigo_iso2;


