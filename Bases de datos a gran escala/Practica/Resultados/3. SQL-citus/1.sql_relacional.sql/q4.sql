WITH jugadores_espanoles_ganadores AS (
    SELECT DISTINCT 
        j.id AS id_jugador, 
        j.nombre || ' ' || j.apellido AS jugador
    FROM 
        partido p, 
        jugador j, 
        edicion_torneo et
    WHERE 
        p.ganador = j.id
        AND p.torneo = et.torneo
        AND p.fecha = et.fecha
        AND j.pais = 'ES'
        AND p.ronda = 'F'
        AND et.nivel = 'G'
)
SELECT 
    jeg.jugador, 
    COUNT(p.num_partido) AS partidos,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN 1 ELSE 0 END) / 
          COUNT(p.num_partido), 1) AS pcje_victorias,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_aces_ganador ELSE p.num_aces_perdedor END) / 
          NULLIF(SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_ptos_servidos_ganador ELSE p.num_ptos_servidos_perdedor END), 0), 1) AS pcje_aces,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_dob_faltas_ganador ELSE p.num_dob_faltas_perdedor END) / 
          NULLIF(SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_ptos_servidos_ganador ELSE p.num_ptos_servidos_perdedor END), 0), 1) AS pcje_dobles_faltas,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN 
                          p.num_primeros_servicios_ganados_ganador + p.num_segundos_servicios_ganados_ganador
                      ELSE 
                          p.num_primeros_servicios_ganados_perdedor + p.num_segundos_servicios_ganados_perdedor 
                      END) / 
          NULLIF(SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_ptos_servidos_ganador ELSE p.num_ptos_servidos_perdedor END), 0), 1) AS pcje_servicios_ganados,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN 
                          p.num_ptos_servidos_perdedor - p.num_primeros_servicios_ganados_perdedor - p.num_segundos_servicios_ganados_perdedor
                      ELSE 
                          p.num_ptos_servidos_ganador - p.num_primeros_servicios_ganados_ganador - p.num_segundos_servicios_ganados_ganador 
                      END) / 
          NULLIF(SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_ptos_servidos_perdedor ELSE p.num_ptos_servidos_ganador END), 0), 1) AS pcje_restos_ganados,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_break_salvados_ganador ELSE p.num_break_salvados_perdedor END) / 
          NULLIF(SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_break_afrontados_ganador ELSE p.num_break_afrontados_perdedor END), 0), 1) AS pcje_breaks_salvados,
    ROUND(100.0 * SUM(CASE WHEN jeg.id_jugador = p.ganador THEN 
                          p.num_break_afrontados_perdedor - p.num_break_salvados_perdedor
                      ELSE 
                          p.num_break_afrontados_ganador - p.num_break_salvados_ganador 
                      END) / 
          NULLIF(SUM(CASE WHEN jeg.id_jugador = p.ganador THEN p.num_break_afrontados_perdedor ELSE p.num_break_afrontados_ganador END), 0), 1) AS pcje_breaks_ganados
FROM 
    jugadores_espanoles_ganadores jeg, 
    partido p
WHERE 
    jeg.id_jugador = p.ganador
    OR jeg.id_jugador = p.perdedor
GROUP BY 
    jeg.jugador;
