COPY (
    SELECT 
        jsonb_build_object(
            'torneo', jsonb_build_object(
                'id', t.id,
                'nombre', t.nombre,
                'fecha', et.fecha,
                'pais', CASE 
                            WHEN tp.codigo_iso2 IS NOT NULL THEN jsonb_build_object(
                                'codigo_iso2', tp.codigo_iso2,
                                'codigo_iso3', tp.codigo_iso3,
                                'codigo_ioc', tp.codigo_ioc,
                                'nombre', tp.nombre
                            )
                            ELSE NULL 
                        END,
                'superficie', et.superficie,
                'tamano', et.tamano,
                'nivel', et.nivel
            ),
            'num_sets', p.num_sets,
            'ronda', p.ronda,
            'desenlace', p.desenlace,
            'ganador', CASE 
                           WHEN jg.id IS NOT NULL THEN jsonb_build_object(
                               'id', jg.id,
                               'nombre', jg.nombre,
                               'apellido', jg.apellido,
                               'diestro', jg.diestro,
                               'fecha_nacimiento', jg.fecha_nacimiento,
                               'altura', jg.altura,
                               'pais', CASE 
                                           WHEN pg.codigo_iso2 IS NOT NULL THEN jsonb_build_object(
                                               'codigo_iso2', pg.codigo_iso2,
                                               'codigo_iso3', pg.codigo_iso3,
                                               'codigo_ioc', pg.codigo_ioc,
                                               'nombre', pg.nombre
                                           )
                                           ELSE NULL 
                                       END,
                               'stats', jsonb_build_object(
                                   'aces', p.num_aces_ganador,
                                   'dobles_faltas', p.num_dob_faltas_ganador,
                                   'puntos_servidos', p.num_ptos_servidos_ganador,
                                   'primeros_servicios', p.num_primeros_servicios_ganador,
                                   'primeros_servicios_ganados', p.num_primeros_servicios_ganados_ganador,
                                   'segundos_servicios_ganados', p.num_segundos_servicios_ganados_ganador,
                                   'juegos_servidos', p.num_juegos_servidos_ganador,
                                   'breaks_salvados', p.num_break_salvados_ganador,
                                   'breaks_afrontados', p.num_break_afrontados_ganador
                               )
                           )
                           ELSE NULL 
                       END,
            'perdedor', CASE 
                            WHEN jp.id IS NOT NULL THEN jsonb_build_object(
                                'id', jp.id,
                                'nombre', jp.nombre,
                                'apellido', jp.apellido,
                                'diestro', jp.diestro,
                                'fecha_nacimiento', jp.fecha_nacimiento,
                                'altura', jp.altura,
                                'pais', CASE 
                                            WHEN pp.codigo_iso2 IS NOT NULL THEN jsonb_build_object(
                                                'codigo_iso2', pp.codigo_iso2,
                                                'codigo_iso3', pp.codigo_iso3,
                                                'codigo_ioc', pp.codigo_ioc,
                                                'nombre', pp.nombre
                                            )
                                            ELSE NULL 
                                        END,
                                'stats', jsonb_build_object(
                                    'aces', p.num_aces_perdedor,
                                    'dobles_faltas', p.num_dob_faltas_perdedor,
                                    'puntos_servidos', p.num_ptos_servidos_perdedor,
                                    'primeros_servicios', p.num_primeros_servicios_perdedor,
                                    'primeros_servicios_ganados', p.num_primeros_servicios_ganados_perdedor,
                                    'segundos_servicios_ganados', p.num_segundos_servicios_ganados_perdedor,
                                    'juegos_servidos', p.num_juegos_servidos_perdedor,
                                    'breaks_salvados', p.num_break_salvados_perdedor,
                                    'breaks_afrontados', p.num_break_afrontados_perdedor
                                )
                            )
                            ELSE NULL 
                        END,
            'sets', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'num_set', sp.num_set,
                        'juegos_ganador', sp.juegos_ganador,
                        'juegos_perdedor', sp.juegos_perdedor,
                        'puntos_tiebreak_perdedor', sp.puntos_tiebreak_perdedor
                    )
                )
                FROM sets_partido sp
                WHERE sp.torneo = p.torneo AND sp.fecha = p.fecha AND sp.num_partido = p.num_partido
            )
        )
    FROM 
        partido p
        JOIN edicion_torneo et ON p.torneo = et.torneo AND p.fecha = et.fecha
        JOIN torneo t ON et.torneo = t.id
        LEFT JOIN pais tp ON t.pais = tp.codigo_iso2
        LEFT JOIN jugador jg ON p.ganador = jg.id
        LEFT JOIN pais pg ON jg.pais = pg.codigo_iso2
        LEFT JOIN jugador jp ON p.perdedor = jp.id
        LEFT JOIN pais pp ON jp.pais = pp.codigo_iso2

) TO '/tmp/tenis.json';
