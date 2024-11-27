-- tarda mucho
create table tenisjson as
select
  -- columna jugador como json
  jsonb_build_object(
      'id', j.id,
      'nombre', j.nombre,
      'apellido', j.apellido,
      'diestro', j.diestro,
      'fecha_nacimiento', j.fecha_nacimiento,
      'altura', j.altura
  ) as jugador,
  -- columna 'pais' como json
  jsonb_build_object(
      'codigo_iso2', p.codigo_iso2,
      'codigo_iso3', p.codigo_iso3,
      'codigo_ioc', p.codigo_ioc,
      'nombre', p.nombre
  ) as pais,
  -- columna 'partidos_ganados' como json
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
      'fecha', pg.fecha,
      'ronda', pg.ronda,
      'desenlace', pg.desenlace,
      'num_partido', pg.num_partido,
      'rival', pg.perdedor,
      'sets', (select jsonb_agg(
          jsonb_build_object(
              'juegos_ganador', sp.juegos_ganador,
              'juegos_perdedor', sp.juegos_perdedor,
              'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
          )
      ) from sets_partido sp where sp.torneo = pg.torneo
      and sp.fecha = pg.fecha and sp.num_partido = pg.num_partido),
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
  )) from public.partido pg, public.torneo t, public.edicion_torneo et, public.pais pa
  where pg.ganador = j.id
      and pg.torneo = t.id
      and t.id = et.torneo
      and pg.torneo = et.torneo
      and pg.fecha = et.fecha
      and t.pais = pa.codigo_iso2) as partidos_ganados,
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
              'juegos_ganador', sp.juegos_ganador,
              'juegos_perdedor', sp.juegos_perdedor,
              'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
          )
      ) from sets_partido sp where sp.torneo = pp.torneo
      and sp.fecha = pp.fecha and sp.num_partido = pp.num_partido),
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
  )) from public.partido pp, public.torneo t, public.edicion_torneo et, public.pais pa
  where pp.perdedor = j.id
      and pp.torneo = t.id
      and t.id = et.torneo
      and pp.torneo = et.torneo
      and pp.fecha = et.fecha
      and t.pais = pa.codigo_iso2) as partidos_perdidos
from public.jugador j
  left join public.pais p on j.pais = p.codigo_iso2




























--Q1
SELECT
    j.jugador->>'nombre' AS nombre,
    j.jugador->>'apellido' AS apellido,
    EXTRACT(YEAR FROM (pg->>'fecha')::date) AS ano
FROM
    tenisjson j
    CROSS JOIN LATERAL jsonb_array_elements(j.partidos_ganados) AS pg
WHERE
    pg->'torneo'->>'nombre' = 'Wimbledon'
    AND pg->>'ronda' = 'F'
ORDER BY
    ano;

   
   
   
   
   
--Q2
SELECT
    EXTRACT(YEAR FROM (pg->'torneo'->>'fecha')::date) AS ano,
    COUNT(DISTINCT pg->'torneo'->>'nombre') AS numero_torneos,
    STRING_AGG(pg->'torneo'->>'nombre', ', ' ORDER BY pg->'torneo'->>'fecha') AS torneos
FROM
    tenisjson j
    CROSS JOIN LATERAL jsonb_array_elements(j.partidos_ganados) AS pg
WHERE
    j.jugador->>'nombre' = 'Roger'
    AND j.jugador->>'apellido' = 'Federer'
    AND pg->>'ronda' = 'F'
    AND pg->'torneo'->>'nivel' IN ('G', 'M')
GROUP BY
    ano
ORDER BY
    ano;

   
   
--Q3
SELECT
    p.ronda,
    p.desenlace,
    jg.nombre || ' ' || jg.apellido AS ganador,
    jp.nombre || ' ' || jp.apellido AS perdedor,
    STRING_AGG(
        sp.juegos_ganador || '-' || sp.juegos_perdedor ||
        CASE
            WHEN sp.puntos_tiebreak_perdedor IS NOT NULL THEN
                '(' || sp.puntos_tiebreak_perdedor || ')'
            ELSE
                ''
        END,
        ', ' ORDER BY sp.num_set
    ) AS resultado
FROM
    tenisjson j
    -- Unir partidos ganados
    CROSS JOIN LATERAL jsonb_array_elements(j.partidos_ganados) AS pg
    -- Unir sets de cada partido ganado
    CROSS JOIN LATERAL jsonb_array_elements(pg.sets) AS sp
    -- Obtener información del perdedor desde la tabla de jugadores
    JOIN tenisjson jp ON jp.jugador->>'id' = pg.rival
WHERE
    pg.torneo->>'nombre' = 'Roland Garros'
    AND EXTRACT(YEAR FROM (pg.torneo->>'fecha')::date) = 2018
    AND pg.ronda IN ('SF', 'F')
GROUP BY
    p.ronda,
    p.desenlace,
    jg.nombre,
    jg.apellido,
    jp.nombre,
    jp.apellido,
    p.fecha
ORDER BY
    p.fecha;
   
   
   
   
   
--Q4
with jugadores_espanoles_ganadores as (
    select distinct j.id as id_jugador, j.nombre || ' ' || j.apellido as jugador
    from partido p, jugador j, edicion_torneo et 
    where p.ganador = j.id 
        and p.torneo = et.torneo 
        and p.fecha = et.fecha
        and j.pais = 'ES'
        and p.ronda = 'F'
        and et.nivel = 'G'
)

select jeg.jugador, count(p.num_partido) as partidos,
    round(100.0 * sum(case when jeg.id_jugador = p.ganador then 1 else 0 end) / count(p.num_partido), 1) as pcje_victorias, 
    round(100.0 * sum(case when jeg.id_jugador = p.ganador then p.num_aces_ganador else p.num_aces_perdedor end) / 
        nullif(sum(case when jeg.id_jugador = p.ganador then p.num_ptos_servidos_ganador  else p.num_ptos_servidos_perdedor end), 0), 1) as pcje_aces, 
    round(100.0 * sum(case when jeg.id_jugador = p.ganador then p.num_dob_faltas_ganador  else p.num_dob_faltas_perdedor  end) / 
        nullif(sum(case when jeg.id_jugador = p.ganador then p.num_ptos_servidos_ganador  else p.num_ptos_servidos_perdedor end), 0), 1) as pcje_dobles_faltas, 
    round(100.0 * sum(case when jeg.id_jugador = p.ganador then p.num_primeros_servicios_ganados_ganador + p.num_segundos_servicios_ganados_ganador 
            else p.num_primeros_servicios_ganados_perdedor + p.num_segundos_servicios_ganados_perdedor end) / 
        nullif(sum(case when jeg.id_jugador = p.ganador then p.num_ptos_servidos_ganador  else p.num_ptos_servidos_perdedor end), 0), 1) as pcje_servicios_ganados, 
    round(100.0 * sum(case when jeg.id_jugador = p.ganador 
            then p.num_ptos_servidos_perdedor - p.num_primeros_servicios_ganados_perdedor - p.num_segundos_servicios_ganados_perdedor 
            else p.num_ptos_servidos_ganador - p.num_primeros_servicios_ganados_ganador - p.num_segundos_servicios_ganados_ganador end) / 
        nullif(sum(case when jeg.id_jugador = p.ganador then p.num_ptos_servidos_perdedor else p.num_ptos_servidos_ganador end), 0), 1) as pcje_restos_ganados,
    round(100.0 * sum(case when jeg.id_jugador = p.ganador then p.num_break_salvados_ganador else p.num_break_salvados_perdedor end) / 
        nullif(sum(case when jeg.id_jugador = p.ganador then p.num_break_afrontados_ganador else p.num_break_afrontados_perdedor end), 0), 1) as pcje_breaks_salvados, 
    round(100.0 * sum(case when jeg.id_jugador = p.ganador then p.num_break_afrontados_perdedor - p.num_break_salvados_perdedor 
            else p.num_break_afrontados_ganador - p.num_break_salvados_ganador end) / 
        nullif(sum(case when jeg.id_jugador = p.ganador then p.num_break_afrontados_perdedor else p.num_break_afrontados_ganador end), 0), 1) as pcje_breaks_ganados
from jugadores_espanoles_ganadores jeg, partido p
where jeg.id_jugador = p.ganador 
	or jeg.id_jugador = p.perdedor
group by jeg.jugador






--Q5
WITH rival_nadal AS (
    SELECT
        CASE
            WHEN jg.jugador->>'nombre' = 'Rafael' THEN jp.jugador->>'id'
            ELSE jg.jugador->>'id'
        END AS id_jugador,
        CASE
            WHEN jg.jugador->>'nombre' = 'Rafael' THEN jp.jugador->>'nombre' || ' ' || jp.jugador->>'apellido'
            ELSE jg.jugador->>'nombre' || ' ' || jg.jugador->>'apellido'
        END AS jugador
    FROM
        tenisjson jg
        CROSS JOIN LATERAL jsonb_array_elements(jg.partidos_ganados) AS pg_g
        LEFT JOIN tenisjson jp ON pg_g->>'perdedor' = jp.jugador->>'id'
        CROSS JOIN LATERAL jsonb_array_elements(jg.partidos_perdidos) AS pg_p
        LEFT JOIN tenisjson jp_p ON pg_p->>'ganador' = jp_p.jugador->>'id'
    WHERE
        (
            (jg.jugador->>'nombre' = 'Rafael' AND jg.jugador->>'apellido' = 'Nadal')
            OR
            (jp.jugador->>'nombre' = 'Rafael' AND jp.jugador->>'apellido' = 'Nadal')
        )
        AND (
            (pg_g->>'torneo.nombre' = 'Roland Garros'
             AND pg_g->>'ronda' = 'R128'
             AND EXTRACT(YEAR FROM (pg_g->>'fecha')::date) = 2018)
            OR
            (pg_p->>'torneo.nombre' = 'Roland Garros'
             AND pg_p->>'ronda' = 'R128'
             AND EXTRACT(YEAR FROM (pg_p->>'fecha')::date) = 2018)
        )
)

SELECT
    j.jugador->>'nombre' || ' ' || j.jugador->>'apellido' AS jugador,
    j.jugador->>'pais' AS pais
FROM
    rival_nadal rn
    JOIN tenisjson j ON rn.id_jugador = j.jugador->>'id'
ORDER BY
    jugador;