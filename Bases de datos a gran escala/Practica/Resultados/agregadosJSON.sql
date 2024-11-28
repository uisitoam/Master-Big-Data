--insercion de datos 
create table tenisjson as
select 
	-- columna 'jugador' como objeto json
	jsonb_build_object(
		'id', j.id, 
		'nombre', j.nombre, 
		'apellido', j.apellido, 
		'diestro', j.diestro, 
		'fecha_nacimiento', j.fecha_nacimiento, 
		'altura', j.altura
	) as jugador,
  -- columna 'pais' como objeto json
	jsonb_build_object(
		'codigo_iso2', p.codigo_iso2, 
		'codigo_iso3', p.codigo_iso3, 
		'codigo_ioc', p.codigo_ioc, 
		'nombre', p.nombre
	) as pais,
  -- columna 'partidos_ganados' como agregado json
	(select jsonb_agg(jsonb_build_object(
		'torneo', jsonb_build_object(
			'nombre', t.nombre, 
			'pais', jsonb_build_object(
				'codigo_iso2', pa.codigo_iso2, 
				'codigo_iso3', pa.codigo_iso3, 
				'codigo_ioc', pa.codigo_ioc, 
				'nombre', pa.nombre), 
			'fecha', et.fecha, 
			'superficie', et.superficie, 
			'tamano', et.tamano, 
			'nivel', et.nivel), 
		'fecha', pg.fecha, 
		'ronda', pg.ronda, 
		'desenlace', pg.desenlace, 
		'num_partido', pg.num_partido, 
		'rival', pg.perdedor, 
		'sets', (select jsonb_agg(
			jsonb_build_object(
				'num_set', sp.num_set, 
				'juegos_ganador', sp.juegos_ganador, 
				'juegos_perdedor', sp.juegos_perdedor, 
				'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
			)
		) 
		from sets_partido sp 
		where sp.torneo = pg.torneo 
			and sp.fecha = pg.fecha 
			and sp.num_partido = pg.num_partido), 
		'stats', jsonb_build_object(
			'num_aces', pg.num_aces_ganador, 
			'num_dob_faltas', pg.num_dob_faltas_ganador, 
			'num_puntos_servidos', pg.num_ptos_servidos_ganador, 
			'num_primeros_servicios', pg.num_primeros_servicios_ganador, 
			'num_primeros_servicios_ganados', pg.num_primeros_servicios_ganados_ganador, 
			'num_segundos_servicios_ganados', pg.num_segundos_servicios_ganados_ganador, 
			'num_juegos_servidos', pg.num_juegos_servidos_ganador, 
			'num_break_salvados', pg.num_break_salvados_ganador, 
			'num_break_afrontados', pg.num_break_afrontados_ganador
		), 
		'stats_rival', jsonb_build_object(
			'num_aces', pg.num_aces_perdedor, 
			'num_dob_faltas', pg.num_dob_faltas_perdedor, 
			'num_puntos_servidos', pg.num_ptos_servidos_perdedor, 
			'num_primeros_servicios', pg.num_primeros_servicios_perdedor, 
			'num_primeros_servicios_ganados', pg.num_primeros_servicios_ganados_perdedor, 
			'num_segundos_servicios_ganados', pg.num_segundos_servicios_ganados_perdedor, 
			'num_juegos_servidos', pg.num_juegos_servidos_perdedor, 
			'num_break_salvados', pg.num_break_salvados_perdedor, 
			'num_break_afrontados', pg.num_break_afrontados_perdedor
		)
	)) 
	from public.partido pg 
		left join public.edicion_torneo et on pg.torneo = et.torneo and pg.fecha = et.fecha 
		left join public.torneo t on et.torneo = t.id 
		left join public.pais pa on t.pais = pa.codigo_iso2
	where pg.ganador = j.id) as partidos_ganados,
   -- columna 'partidos_perdidos' como json
	(select jsonb_agg(jsonb_build_object(
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
		'ronda', pp.ronda,
		'desenlace', pp.desenlace,
		'num_partido', pp.num_partido,
		'rival', pp.ganador,
		'sets', (select jsonb_agg(
			jsonb_build_object(
				'num_set', sp.num_set,
				'juegos_ganador', sp.juegos_ganador,
				'juegos_perdedor', sp.juegos_perdedor,
				'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
			)
		) 
		from sets_partido sp 
		where sp.torneo = pp.torneo 
			and sp.fecha = pp.fecha 
			and sp.num_partido = pp.num_partido),
		'stats', jsonb_build_object(
			'num_aces', pp.num_aces_perdedor,
			'num_dob_faltas', pp.num_dob_faltas_perdedor,
			'num_puntos_servidos', pp.num_ptos_servidos_perdedor,
			'num_primeros_servicios', pp.num_primeros_servicios_perdedor,
			'num_primeros_servicios_ganados', pp.num_primeros_servicios_ganados_perdedor,
			'num_segundos_servicios_ganados', pp.num_segundos_servicios_ganados_perdedor,
			'num_juegos_servidos', pp.num_juegos_servidos_perdedor,
			'num_break_salvados', pp.num_break_salvados_perdedor,
			'num_break_afrontados', pp.num_break_afrontados_perdedor
		),
		'stats_rival', jsonb_build_object(
			'num_aces', pp.num_aces_ganador,
			'num_dob_faltas', pp.num_dob_faltas_ganador,
			'num_puntos_servidos', pp.num_ptos_servidos_ganador,
			'num_primeros_servicios', pp.num_primeros_servicios_ganador,
			'num_primeros_servicios_ganados', pp.num_primeros_servicios_ganados_ganador,
			'num_segundos_servicios_ganados', pp.num_segundos_servicios_ganados_ganador,
			'num_juegos_servidos', pp.num_juegos_servidos_ganador,
			'num_break_salvados', pp.num_break_salvados_ganador,
			'num_break_afrontados', pp.num_break_afrontados_ganador
		)
	)) 
	from public.partido pp
		left join public.edicion_torneo et on pp.torneo = et.torneo and pp.fecha = et.fecha
		left join public.torneo t on et.torneo = t.id
		left join public.pais pa on t.pais = pa.codigo_iso2
	where pp.perdedor = j.id) as partidos_perdidos
from public.jugador j
	left join public.pais p on j.pais = p.codigo_iso2
where j.id in (select perdedor from public.partido)
	or j.id in (select ganador from public.partido)

  

 

















 	
 	
 	

--CONSULTAS


--Q1
select tj.jugador ->> 'nombre' as nombre, 
    tj.jugador ->> 'apellido' as apellido, 
    extract(year from (pg ->> 'fecha')::date) as ano
from tenisjson tj, jsonb_array_elements(partidos_ganados) as partidos(pg)
where pg ->> 'ronda' = 'F' 
    and pg -> 'torneo' ->> 'nombre' = 'Wimbledon'
order by ano

   
   


   
   
--Q2
select extract(year from (pg -> 'torneo' ->> 'fecha')::date) as ano,
    count(distinct pg -> 'torneo'->>'nombre') as numero_torneos,
    string_agg(pg -> 'torneo'->>'nombre', ', ' order by pg -> 'torneo' ->> 'fecha') as torneos
from tenisjson tj, jsonb_array_elements(partidos_ganados) as partidos(pg)
where tj.jugador ->> 'nombre' = 'Roger'
    and tj.jugador ->> 'apellido' = 'Federer'
    and pg ->> 'ronda' = 'F'
    and pg -> 'torneo'->>'nivel' in ('G', 'M')
group by ano
order by ano

   


--Q3
select pg ->> 'ronda' as ronda, pg ->> 'desenlace' as desenlace, 
	(tj.jugador ->> 'nombre')::text || ' ' || (tj.jugador ->> 'apellido')::text as ganador, 
	(tjr.jugador ->> 'nombre')::text || ' ' || (tjr.jugador ->> 'apellido')::text as perdedor, 
	string_agg((s ->> 'juegos_ganador')::text || '-' || (s ->> 'juegos_perdedor')::text || 
		case when s ->> 'puntos_tiebreak_perdedor' is not null 
			then '(' || (s ->> 'puntos_tiebreak_perdedor')::text || ')' 
			else '' end, ', ' order by s ->> 'num_set') as resultado
from tenisjson tj, jsonb_array_elements(tj.partidos_ganados) as partidos(pg), 
	jsonb_array_elements(pg -> 'sets') as setss(s), tenisjson tjr
where pg ->'torneo' ->> 'nombre' = 'Roland Garros'
    and extract(year from (pg ->> 'fecha')::date) = 2018
    and pg ->> 'ronda' in ('SF', 'F')
    and tjr.jugador->>'id' = pg ->> 'rival'
group by pg ->> 'ronda', pg ->> 'desenlace', 
	tj.jugador ->> 'nombre', tj.jugador ->> 'apellido', 
	tjr.jugador ->> 'nombre', tjr.jugador ->> 'apellido', pg ->> 'fecha'


   
   
   
--Q4
with jugadores_espanoles_ganadores as (
    select distinct (tj.jugador ->> 'id')::integer as id_jugador, 
    	(tj.jugador ->> 'nombre')::text || ' ' || (tj.jugador ->> 'apellido')::text as jugador
    from tenisjson tj, jsonb_array_elements(partidos_ganados) as partidos(pg)
    where tj.pais ->> 'codigo_iso2' = 'ES'
        and pg ->> 'ronda' = 'F'
        and pg -> 'torneo' ->> 'nivel' = 'G'
)

select jeg.jugador,
    count(*) as partidos,
    round(100.0 * count(case when pg ->> 'rival' = jeg.id_jugador::text then null else 1 end)::numeric / count(*), 1) as pcje_victorias,
    round(100.0 * sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    	then (pg -> 'stats_rival' ->> 'num_aces')::numeric 
    	else (pg -> 'stats' ->> 'num_aces')::numeric end) / 
    	nullif(sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    		then (pg -> 'stats_rival' ->> 'num_puntos_servidos')::numeric 
    		else (pg->'stats'->>'num_puntos_servidos')::numeric end), 0), 1) as pcje_aces,
    round(100.0 * sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    	then (pg -> 'stats_rival' ->> 'num_dob_faltas')::numeric 
    	else (pg -> 'stats' ->> 'num_dob_faltas')::numeric end) / 
    	nullif(sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    		then (pg -> 'stats_rival' ->> 'num_puntos_servidos')::numeric 
    		else (pg -> 'stats' ->> 'num_puntos_servidos')::numeric end), 0), 1) as pcje_dobles_faltas,
    round(100.0 * sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    	then (pg -> 'stats_rival' ->> 'num_primeros_servicios_ganados')::numeric + (pg -> 'stats_rival' ->> 'num_segundos_servicios_ganados')::numeric 
    	else (pg -> 'stats' ->> 'num_primeros_servicios_ganados')::numeric + (pg -> 'stats' ->> 'num_segundos_servicios_ganados')::numeric end) / 
    	nullif(sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    		then (pg -> 'stats_rival' ->> 'num_puntos_servidos')::numeric 
    		else (pg -> 'stats' ->> 'num_puntos_servidos')::numeric end), 0), 1) as pcje_servicios_ganados,
    round(100.0 * sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    	then (pg -> 'stats' ->> 'num_puntos_servidos')::numeric - (pg -> 'stats' ->> 'num_primeros_servicios_ganados')::numeric - 
    		 (pg -> 'stats' ->> 'num_segundos_servicios_ganados')::numeric 
    	else (pg -> 'stats_rival' ->> 'num_puntos_servidos')::numeric - (pg -> 'stats_rival' ->> 'num_primeros_servicios_ganados')::numeric - 
    		 (pg -> 'stats_rival' ->> 'num_segundos_servicios_ganados')::numeric end) / 	
    	nullif(sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    		then (pg -> 'stats' ->> 'num_puntos_servidos')::numeric 
    		else (pg -> 'stats_rival' ->> 'num_puntos_servidos')::numeric end), 0), 1) as pcje_restos_ganados,
    round(100.0 * sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    	then (pg->'stats_rival'->>'num_break_salvados')::numeric 
    	else (pg -> 'stats' ->> 'num_break_salvados')::numeric end) / 
    	nullif(sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    		then (pg -> 'stats_rival' ->> 'num_break_afrontados')::numeric 
    		else (pg -> 'stats' ->> 'num_break_afrontados')::numeric end), 0), 1) as pcje_breaks_salvados,
    round(100.0 * sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    	then (pg -> 'stats' ->> 'num_break_afrontados')::numeric - (pg -> 'stats' ->> 'num_break_salvados')::numeric
    	else (pg -> 'stats_rival' ->> 'num_break_afrontados')::numeric - (pg -> 'stats_rival' ->> 'num_break_salvados')::numeric end) / 
    	nullif(sum(case when pg ->> 'rival' = jeg.id_jugador::text 
    		then (pg -> 'stats' ->> 'num_break_afrontados')::numeric 
    		else (pg -> 'stats_rival' ->> 'num_break_afrontados')::numeric end), 0), 1) as pcje_breaks_ganados
from jugadores_espanoles_ganadores jeg, tenisjson tj, 
	jsonb_array_elements(tj.partidos_ganados) as partidos(pg)
where (tj.jugador ->> 'id')::integer = jeg.id_jugador 
	or pg ->> 'rival' = jeg.id_jugador::text
group by jeg.jugador






--Q5
with rival_nadal as (
	select case when tj.jugador ->> 'nombre' = 'Rafael' 
			then (pg ->> 'rival')::integer  
			else (tj.jugador ->> 'id')::integer end as id_jugador,
		case when tj.jugador ->> 'nombre' = 'Rafael' 
			then (tjr.jugador ->> 'nombre')::text || ' ' || (tjr.jugador ->> 'apellido')::text 
			else (tj.jugador ->> 'nombre')::text || ' ' || (tj.jugador ->> 'apellido')::text end as jugador
	from tenisjson tj, jsonb_array_elements(tj.partidos_ganados) as partidos(pg), tenisjson tjr
    where pg -> 'torneo' ->> 'nombre' = 'Roland Garros' 
    	and pg ->> 'ronda' = 'R128'
		and extract(year from (pg ->> 'fecha')::date) = 2018
        and tjr.jugador->>'id' = pg ->> 'rival'
        and ((tj.jugador ->> 'nombre' = 'Rafael' and tj.jugador ->> 'apellido' = 'Nadal') 
        	or (tjr.jugador ->> 'nombre' = 'Rafael' and tjr.jugador ->> 'apellido' = 'Nadal'))
)

select tj.jugador->>'nombre' || ' ' || (tj.jugador->>'apellido')::text as jugador, 
	tj.pais->>'codigo_iso2' as pais
from rival_nadal rn, tenisjson tj, jsonb_array_elements(tj.partidos_perdidos) as partidos(pg)
where rn.id_jugador = (pg->>'rival')::integer 
	and extract(year from (pg->>'fecha')::date) = 2018
   
