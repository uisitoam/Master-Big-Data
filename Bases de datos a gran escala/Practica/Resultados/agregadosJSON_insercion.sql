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