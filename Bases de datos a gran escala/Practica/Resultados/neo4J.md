## Indices
-----------
```
CREATE INDEX IF NOT EXISTS FOR (j:Jugador) ON (j.id);
CREATE INDEX IF NOT EXISTS FOR (et:EdicionTorneo) ON (et.torneo, et.fecha);
CREATE INDEX IF NOT EXISTS FOR (p:Partido) ON (p.num_partido, p.fecha);
CREATE INDEX IF NOT EXISTS FOR (p:Pais) ON (p.codigo_iso2);
CREATE INDEX IF NOT EXISTS FOR (t:Torneo) ON (t.id);
CREATE INDEX partido_fecha_num IF NOT EXISTS FOR (p:Partido) ON (p.num_partido, p.fecha);
```

## Cargamos los paises
----------------------
```
WITH "jdbc:postgresql://localhost:5432/tenis?user=alumnogreibd&password=greibd2021" as url
CALL apoc.load.jdbc(url, "SELECT codigo_iso2, codigo_iso3, codigo_ioc, nombre FROM pais") YIELD row
CREATE (p:Pais {
codigo_iso2: row.codigo_iso2,
codigo_iso3: row.codigo_iso3,
codigo_ioc: row.codigo_ioc,
nombre: row.nombre
});
```

## Cargamos los jugadores
----------------------

Los jugaodres deben estar relacionados con sus respectivos paises: 
```
WITH "jdbc:postgresql://localhost:5432/tenis?user=alumnogreibd&password=greibd2021" AS url
CALL apoc.load.jdbc(url, 
"SELECT id, nombre, apellido, diestro, fecha_nacimiento, pais, altura FROM jugador") YIELD row
MATCH (pa:Pais {codigo_iso2: row.pais})
CREATE (j:Jugador {
    id: row.id,
    nombre: row.nombre,
    apellido: row.apellido,
    diestro: row.diestro,
    fecha_nacimiento: row.fecha_nacimiento,
    altura: row.altura
})
CREATE (j)-[:REPRESENTA_A]->(pa);
```

## Cargamos los torneos 
----------------------
Los torneos deben estar relacionados con sus respectivos países
```
WITH "jdbc:postgresql://localhost:5432/tenis?user=alumnogreibd&password=greibd2021" AS url
CALL apoc.load.jdbc(url,
"SELECT id, nombre, pais FROM torneo") YIELD row
CREATE (t:Torneo {
    id: row.id,
    nombre: row.nombre
})
WITH t, row
OPTIONAL MATCH (pa:Pais {codigo_iso2: row.pais})
WITH t, pa
WHERE pa IS NOT NULL
CREATE (t)-[:SE_CELEBRA_EN]->(pa);
```

## Cargamos las ediciones de los torneos
----------------------

La edición de cada torneo debe estar relacionada con el propio torneo
```
WITH "jdbc:postgresql://localhost:5432/tenis?user=alumnogreibd&password=greibd2021" AS url
CALL apoc.load.jdbc(url,
"SELECT torneo, fecha, superficie, tamano, nivel FROM edicion_torneo") YIELD row
MATCH (t:Torneo {id: row.torneo})
CREATE (et:EdicionTorneo {
    fecha: row.fecha,
    superficie: row.superficie,
    tamano: row.tamano,
    nivel: row.nivel,
    torneo: row.torneo
})
CREATE (et)-[:EDICION_DE]->(t);
```

## Cargamos los partidos
----------------------

Cada partido se debe relacionar con su torneo y los jugadores que participaron en él.
```
WITH "jdbc:postgresql://localhost:5432/tenis?user=alumnogreibd&password=greibd2021" AS url
CALL apoc.load.jdbc(url,
"SELECT p.torneo, p.fecha, p.num_partido, p.num_sets, p.ronda, p.desenlace,
p.ganador, p.perdedor,
p.num_aces_ganador, p.num_dob_faltas_ganador, p.num_ptos_servidos_ganador,
p.num_primeros_servicios_ganador, p.num_primeros_servicios_ganados_ganador,
p.num_segundos_servicios_ganados_ganador, p.num_juegos_servidos_ganador,
p.num_break_salvados_ganador, p.num_break_afrontados_ganador,
p.num_aces_perdedor, p.num_dob_faltas_perdedor, p.num_ptos_servidos_perdedor,
p.num_primeros_servicios_perdedor, p.num_primeros_servicios_ganados_perdedor,
p.num_segundos_servicios_ganados_perdedor, p.num_juegos_servidos_perdedor,
p.num_break_salvados_perdedor, p.num_break_afrontados_perdedor
FROM partido p
WHERE p.fecha IS NOT NULL AND p.torneo IS NOT NULL
ORDER BY p.fecha, p.torneo, p.num_partido
LIMIT 10000 OFFSET 0") YIELD row

// Crear el partido independientemente de las referencias
CREATE (p:Partido {
num_partido: row.num_partido,
fecha: row.fecha,
num_sets: row.num_sets,
ronda: row.ronda,
desenlace: row.desenlace,
torneo_id: row.torneo // Guardamos la referencia al torneo aunque no exista el nodo
})

// Intentar vincular con el torneo si existe
WITH p, row
OPTIONAL MATCH (t:Torneo {id: row.torneo})
WITH p, row, t
WHERE t IS NOT NULL
CREATE (p)-[:SE_JUEGA_EN]->(t)

// Intentar vincular con el ganador si existe
WITH p, row
OPTIONAL MATCH (ganador:Jugador {id: toInteger(row.ganador)})
WITH p, row, ganador
WHERE ganador IS NOT NULL
CREATE (p)-[:GANADO_POR {
num_aces: row.num_aces_ganador,
num_dob_faltas: row.num_dob_faltas_ganador,
num_ptos_servidos: row.num_ptos_servidos_ganador,
num_primeros_servicios: row.num_primeros_servicios_ganador,
num_primeros_servicios_ganados: row.num_primeros_servicios_ganados_ganador,
num_segundos_servicios_ganados: row.num_segundos_servicios_ganados_ganador,
num_juegos_servidos: row.num_juegos_servidos_ganador,
num_break_salvados: row.num_break_salvados_ganador,
num_break_afrontados: row.num_break_afrontados_ganador
}]->(ganador)

// Intentar vincular con el perdedor si existe
WITH p, row
OPTIONAL MATCH (perdedor:Jugador {id: toInteger(row.perdedor)})
WITH p, row, perdedor
WHERE perdedor IS NOT NULL
CREATE (p)-[:PERDIDO_POR {
num_aces: row.num_aces_perdedor,
num_dob_faltas: row.num_dob_faltas_perdedor,
num_ptos_servidos: row.num_ptos_servidos_perdedor,
num_primeros_servicios: row.num_primeros_servicios_perdedor,
num_primeros_servicios_ganados: row.num_primeros_servicios_ganados_perdedor,
num_segundos_servicios_ganados: row.num_segundos_servicios_ganados_perdedor,
num_juegos_servidos: row.num_juegos_servidos_perdedor,
num_break_salvados: row.num_break_salvados_perdedor,
num_break_afrontados: row.num_break_afrontados_perdedor
}]->(perdedor);
```


## Cargamos los sets de cada partido
----------------------

Cada set se debe relacionar con el partido al que pertenece
```
WITH "jdbc:postgresql://localhost:5432/tenis?user=alumnogreibd&password=greibd2021" AS url
CALL apoc.load.jdbc(url,
"SELECT * FROM sets_partido LIMIT 10000 OFFSET 0") YIELD row
OPTIONAL MATCH (p:Partido {num_partido: row.num_partido, fecha: row.fecha})
WITH row, p
WHERE p IS NOT NULL
CREATE (sp:SetPartido {
num_set: row.num_set,
juegos_ganador: row.juegos_ganador,
juegos_perdedor: row.juegos_perdedor,
puntos_tiebreak_perdedor: row.puntos_tiebreak_perdedor
})
CREATE (sp)-[:PERTENECE_A]->(p);
```


## Q1
----------------------

``` 
MATCH (j:Jugador)<-[gp:GANADO_POR]-(p:Partido)-[:SE_JUEGA_EN]->(t:Torneo)
WHERE t.nombre = 'Wimbledon'
AND p.ronda = 'F'
RETURN j.nombre AS nombre,
j.apellido AS apellido,
substring(toString(p.fecha), 0, 4) AS ano
ORDER BY ano;
```





## Q2
----------------------
```
MATCH (j:Jugador)<-[:GANADO_POR]-(p:Partido)-[:SE_JUEGA_EN]->(t:Torneo)
MATCH (et:EdicionTorneo)-[:EDICION_DE]->(t)
WHERE j.nombre = 'Roger'
AND j.apellido = 'Federer'
AND p.ronda = 'F'
AND et.nivel IN ['G', 'M']
AND et.fecha = p.fecha
AND et.torneo = t.id
WITH substring(toString(p.fecha), 0, 4) AS ano, 
     collect({nombre: t.nombre, fecha: p.fecha}) AS torneos
UNWIND torneos AS torneo
WITH ano, torneo.nombre AS nombre, torneo.fecha AS fecha
ORDER BY fecha
RETURN ano, count(DISTINCT nombre) AS num_torneos, 
    reduce(s = head(collect(nombre)), x IN tail(collect(nombre)) | s + ', ' + x) AS torneos
ORDER BY ano;
```





## Q3
----------------------
```
MATCH (jg:Jugador)<-[:GANADO_POR]-(p:Partido)-[:PERDIDO_POR]-(jp:Jugador),
(p)-[:SE_JUEGA_EN]->(t:Torneo),
(sp:SetPartido)-[:PERTENECE_A]->(p)
WHERE t.nombre = 'Roland Garros'
AND p.ronda IN ['SF', 'F']
AND substring(toString(p.fecha), 0, 4) = '2018'
WITH p, jg, jp, sp
ORDER BY sp.num_set
WITH p, jg, jp,
collect(sp.juegos_ganador + '-' + sp.juegos_perdedor +
CASE sp.puntos_tiebreak_perdedor
WHEN null THEN ''
ELSE '(' + toString(sp.puntos_tiebreak_perdedor) + ')'
END) as sets
RETURN p.ronda as ronda,
p.desenlace as desenlace,
jg.nombre + ' ' + jg.apellido as ganador,
jp.nombre + ' ' + jp.apellido as perdedor,
reduce(s = head(sets), x IN tail(sets) | s + ', ' + x) as resultado
ORDER BY p.fecha;
```

## Q4
----------------------
```
// buscamos jugadores españoles que han ganado finales de Grand Slam (para eliminar duplicados, sino lo haciamos directamente con las estadísticas)
MATCH (j:Jugador)-[:REPRESENTA_A]->(p:Pais {codigo_iso2: 'ES'})
MATCH (j)<-[:GANADO_POR]-(partido:Partido)-[:SE_JUEGA_EN]->(t:Torneo)
MATCH (et:EdicionTorneo)-[:EDICION_DE]->(t)
WHERE partido.ronda = 'F'
AND et.nivel = 'G'
AND et.fecha = partido.fecha
AND et.torneo = t.id
WITH DISTINCT j.id AS id_jugador, j.nombre + ' ' + j.apellido AS jugador

// calculamos las estadísticas de estos jugadores
MATCH (j:Jugador)
WHERE j.id = id_jugador
MATCH (p:Partido)
MATCH (j)<-[r:GANADO_POR|PERDIDO_POR]-(p)
// necesitamos las estadisticas de sus rivales
OPTIONAL MATCH (p)-[rp:PERDIDO_POR]->(rival_j:Jugador)
OPTIONAL MATCH (p)-[rg:GANADO_POR]->(rival_g:Jugador)
WITH jugador, p, j, r, type(r) AS tipo, rp, rg,
CASE type(r) WHEN 'GANADO_POR' THEN 1 ELSE 0 END AS es_ganador,
r.num_aces AS aces,
r.num_ptos_servidos AS ptos_servidos,
r.num_dob_faltas AS dobles_faltas,
r.num_primeros_servicios_ganados + r.num_segundos_servicios_ganados AS servicios_ganados,
// restos ganados
CASE type(r)
WHEN 'GANADO_POR' THEN rp.num_ptos_servidos - rp.num_primeros_servicios_ganados - rp.num_segundos_servicios_ganados
ELSE rg.num_ptos_servidos - rg.num_primeros_servicios_ganados - rg.num_segundos_servicios_ganados END AS restos_ganados,
CASE type(r)
WHEN 'GANADO_POR' THEN rp.num_ptos_servidos
ELSE rg.num_ptos_servidos END AS ptos_servidos_rival,
r.num_break_salvados AS breaks_salvados,
r.num_break_afrontados AS breaks_afrontados,
CASE type(r)
WHEN 'GANADO_POR' THEN rp.num_break_afrontados - rp.num_break_salvados
ELSE rg.num_break_afrontados - rg.num_break_salvados END AS breaks_ganados,
CASE type(r)
WHEN 'GANADO_POR' THEN rp.num_break_afrontados
ELSE rg.num_break_afrontados END AS breaks_rival

WITH jugador,
count(p) AS partidos,
100.0 * sum(es_ganador) / count(p) AS pcje_victorias,
CASE WHEN sum(ptos_servidos) = 0 THEN 0
ELSE 100.0 * sum(aces) / sum(ptos_servidos) END AS pcje_aces,
CASE WHEN sum(ptos_servidos) = 0 THEN 0
ELSE 100.0 * sum(dobles_faltas) / sum(ptos_servidos) END AS pcje_dobles_faltas,
CASE WHEN sum(ptos_servidos) = 0 THEN 0
ELSE 100.0 * sum(servicios_ganados) / sum(ptos_servidos) END AS pcje_servicios_ganados,
CASE WHEN sum(ptos_servidos_rival) = 0 THEN 0
ELSE 100.0 * sum(restos_ganados) / sum(ptos_servidos_rival) END AS pcje_restos_ganados,
CASE WHEN sum(breaks_afrontados) = 0 THEN 0
ELSE 100.0 * sum(breaks_salvados) / sum(breaks_afrontados) END AS pcje_breaks_salvados,
CASE WHEN sum(breaks_rival) = 0 THEN 0
ELSE 100.0 * sum(breaks_ganados) / sum(breaks_rival) END AS pcje_breaks_ganados
RETURN
jugador,
partidos,
round(pcje_victorias, 1) AS pcje_victorias,
round(pcje_aces, 1) AS pcje_aces,
round(pcje_dobles_faltas, 1) AS pcje_dobles_faltas,
round(pcje_servicios_ganados, 1) AS pcje_servicios_ganados,
round(pcje_restos_ganados, 1) AS pcje_restos_ganados,
round(pcje_breaks_salvados, 1) AS pcje_breaks_salvados,
round(pcje_breaks_ganados, 1) AS pcje_breaks_ganados
ORDER BY jugador;
```







## Q5
----------------------
```
// encontramos al rival de Nadal en Roland Garros 2018 R128
MATCH (nadal:Jugador {nombre: 'Rafael', apellido: 'Nadal'})
MATCH (rival:Jugador)
MATCH (p:Partido)-[:SE_JUEGA_EN]->(t:Torneo {nombre: 'Roland Garros'})
WHERE p.ronda = 'R128'
AND substring(toString(p.fecha), 0, 4) = '2018'
AND ((nadal)<-[:GANADO_POR]-(p)-[:PERDIDO_POR]->(rival) OR
(nadal)<-[:PERDIDO_POR]-(p)-[:GANADO_POR]->(rival))


// buscamos los partidos donde este rival perdió en 2018
WITH rival
MATCH (rival)<-[:GANADO_POR]-(derrotas:Partido)-[:PERDIDO_POR]->(perdedor:Jugador)
WHERE substring(toString(derrotas.fecha), 0, 4) = '2018'
MATCH (perdedor)-[:REPRESENTA_A]->(pais:Pais)
RETURN DISTINCT
perdedor.nombre + ' ' + perdedor.apellido as jugador,
pais.codigo_iso2 as pais
ORDER BY jugador;
```



































