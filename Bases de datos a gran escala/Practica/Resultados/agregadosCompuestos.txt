-- creacion de tipos compuestos
create type pais_info as (
	codigo_iso2 char(2),
	codigo_iso3 char(3),
	codigo_ioc char(3),
	nombre varchar(100)
)

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

create type set_info as (
	torneo torneo_info, --quitar
	fecha date, --quitar
	num_partido integer, --quitar
    num_set integer,
   juegos_ganador integer,
   juegos_perdedor integer,
   puntos_tiebreak_perdedor integer
)

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

create type jugador_info as (
   id integer,
   nombre varchar(100),
   apellido varchar(100),
   diesto boolean,
   fecha_nacimiento date,
   pais pais_info,
   altura integer
)





-- creacion de tabla
create table partidos (
    torneo edicion_torneo_info,
    fecha date,
    num_partido integer,
    num_sets integer,
    info_sets set_info array, -- array de elementos de tipo set_info
    ronda varchar(5), 
    desenlace char(1), 
    ganador jugador_info,
    perdedor jugador_info,
    ganador_stats jugador_stats,
    perdedor_stats jugador_stats
)





-- insertar datos
insert into partidos(
torneo, fecha, num_partido, num_sets, info_sets, ronda, desenlace, ganador, perdedor, ganador_stats, perdedor_stats)
select
   -- campo 'torneo' (tipo 'edicion_torneo_info')
   case
       when t.id is null then null
       else cast((cast((t.id, t.nombre, cast((pa.codigo_iso2, pa.codigo_iso3, pa.codigo_ioc, pa.nombre) as pais_info)) as torneo_info), 
       et.fecha, et.superficie, et.tamano, et.nivel) as edicion_torneo_info)
   end as torneo,
  
   p.fecha as fecha,
   p.num_partido as num_partido,
   p.num_sets as num_sets,
  
   -- campo 'info_set' (array de 'set_info')
   array(select cast((cast((t.id, t.nombre, cast((pa.codigo_iso2, pa.codigo_iso3, pa.codigo_ioc, pa.nombre) as pais_info)) as torneo_info),
                      sp.fecha, sp.num_partido, sp.num_set, sp.juegos_ganador, sp.juegos_perdedor, sp.puntos_tiebreak_perdedor) as set_info)
         from public.sets_partido sp
         where sp.torneo = p.torneo
         	and sp.fecha = p.fecha
         	and sp.num_partido = p.num_partido
         order by sp.num_set) as info_sets,
  
   p.ronda as ronda,
   p.desenlace as desenlace,
  
   -- campo 'ganador' (tipo 'jugador_info')
   case
       when jg.id is null then null
       else cast((jg.id, jg.nombre, jg.apellido, jg.diestro, jg.fecha_nacimiento,
       		   cast((pg.codigo_iso2, pg.codigo_iso3, pg.codigo_ioc, pg.nombre) as pais_info),
       		   jg.altura) as jugador_info)
   end as ganador,
  
   -- campo 'perdedor' (tipo 'jugador_info')
   case
       when jp.id is null then null
       else cast((jp.id, jp.nombre, jp.apellido, jp.diestro, jp.fecha_nacimiento,
       		   cast((pp.codigo_iso2, pp.codigo_iso3, pp.codigo_ioc, pp.nombre) as pais_info),
       		   jp.altura) as jugador_info)
   end as perdedor,
  
   -- campo 'ganador_stats' (tipo 'jugador_stats')
   case
       when jg.id is null and jp.id is null then null
       else cast((p.num_aces_ganador, p.num_dob_faltas_ganador,
           	   p.num_ptos_servidos_ganador, p.num_primeros_servicios_ganador,
           	   p.num_primeros_servicios_ganados_ganador, p.num_segundos_servicios_ganados_ganador,
           	   p.num_juegos_servidos_ganador, p.num_break_salvados_ganador,
           	   p.num_break_afrontados_ganador) as jugador_stats)
   end as ganador_stats,
  
   -- campo 'perdedor_stats' (tipo 'jugador_stats')
   case
       when jg.id is null and jp.id is null then null
       else cast((p.num_aces_perdedor, p.num_dob_faltas_perdedor,
           	   p.num_ptos_servidos_perdedor, p.num_primeros_servicios_perdedor,
           	   p.num_primeros_servicios_ganados_perdedor, p.num_segundos_servicios_ganados_perdedor,
           	   p.num_juegos_servidos_perdedor, p.num_break_salvados_perdedor,
           	   p.num_break_afrontados_perdedor) as jugador_stats)
   end as perdedor_stats
from public.partido p join public.edicion_torneo et on et.fecha = p.fecha and et.torneo = p.torneo 
	left join public.torneo t on t.id = et.torneo
	left join public.pais pa on t.pais = pa.codigo_iso2
	left join public.jugador jg on p.ganador = jg.id
	left join public.pais pg on jg.pais = pg.codigo_iso2
	left join public.jugador jp on p.perdedor = jp.id
	left join public.pais pp on jp.pais = pp.codigo_iso2




	
	


-- CONSULTAS

-- Q1
select (ganador).nombre, (ganador).apellido, extract(year from fecha) as ano
from partidos
where (torneo).torneo.nombre = 'Wimbledon'
	and ronda = 'F'
order by ano





-- Q2
select extract(year from (torneo).fecha) as ano, count(distinct (torneo).torneo.id) as numero_torneos, 
	string_agg((torneo).torneo.nombre, ', ' order by (torneo).fecha) as torneos
from partidos
where (torneo).nivel in ('G', 'M')
	and (ganador).nombre = 'Roger'
	and (ganador).apellido = 'Federer'
	and ronda = 'F'
group by ano





-- Q3
select ronda, desenlace, 
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





-- Q4
with jugadores_espanoles_ganadores as (
    select distinct (ganador).id as id_jugador, (ganador).nombre || ' ' || (ganador).apellido AS jugador
    from partidos
    where (ganador).pais.codigo_iso2 = 'ES'
        and ronda = 'F'
        and (torneo).nivel = 'G'
)

select
    jeg.jugador,
    count(p.num_partido) as partidos,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id then 1 else 0 end) / count(p.num_partido), 1) as pcje_victorias,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_aces else (p.perdedor_stats).num_aces end) /
        nullif(sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_ptos_servidos else (p.perdedor_stats).num_ptos_servidos end), 0), 1) as pcje_aces,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_dob_faltas else (p.perdedor_stats).num_dob_faltas end) /
        nullif(sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_ptos_servidos else (p.perdedor_stats).num_ptos_servidos end), 0), 1) as pcje_dobles_faltas,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_primeros_servicios_ganados + (p.ganador_stats).num_segundos_servicios_ganados
            else (p.perdedor_stats).num_primeros_servicios_ganados + (p.perdedor_stats).num_segundos_servicios_ganados end) /
        nullif(sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_ptos_servidos else (p.perdedor_stats).num_ptos_servidos end), 0), 1) as pcje_servicios_ganados,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id
            then (p.perdedor_stats).num_ptos_servidos - (p.perdedor_stats).num_primeros_servicios_ganados - (p.perdedor_stats).num_segundos_servicios_ganados
            else (p.ganador_stats).num_ptos_servidos - (p.ganador_stats).num_primeros_servicios_ganados - (p.ganador_stats).num_segundos_servicios_ganados end) /
        nullif(sum(case when jeg.id_jugador = (p.ganador).id then (p.perdedor_stats).num_ptos_servidos else (p.ganador_stats).num_ptos_servidos end), 0), 1) as pcje_restos_ganados,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_break_salvados else (p.perdedor_stats).num_break_salvados end) /
        nullif(sum(case when jeg.id_jugador = (p.ganador).id then (p.ganador_stats).num_break_afrontados else (p.perdedor_stats).num_break_afrontados end), 0), 1) as pcje_breaks_salvados,
    round(100.0 * sum(case when jeg.id_jugador = (p.ganador).id then (p.perdedor_stats).num_break_afrontados - (p.perdedor_stats).num_break_salvados
            else (p.ganador_stats).num_break_afrontados - (p.ganador_stats).num_break_salvados end) /
        nullif(sum(case when jeg.id_jugador = (p.ganador).id then (p.perdedor_stats).num_break_afrontados else (p.ganador_stats).num_break_afrontados end), 0), 1) as pcje_breaks_ganados
from jugadores_espanoles_ganadores jeg, partidos p
where jeg.id_jugador = (p.ganador).id
    or jeg.id_jugador = (p.perdedor).id
group by jeg.jugador





-- Q5
with rival_nadal as (
	select case when (ganador).nombre = 'Rafael' then (perdedor).nombre || ' ' || (perdedor).apellido 
						 else (ganador).nombre || ' ' || (ganador).apellido end as jugador
	from partidos 
	where (((ganador).nombre = 'Rafael' and (ganador).apellido = 'Nadal') or 
		  ((perdedor).nombre = 'Rafael' and(perdedor).apellido = 'Nadal'))
		and ronda = 'R128'
		and (torneo).torneo.nombre = 'Roland Garros'
		and extract(year from fecha) = '2018'
)

select (p.perdedor).nombre || ' ' || (p.perdedor).apellido as jugador, (p.perdedor).pais.codigo_iso2 as pais
from partidos p, rival_nadal rn
where (p.ganador).nombre || ' ' || (p.ganador).apellido = rn.jugador
	and extract(year from p.fecha) = '2018'
order by jugador