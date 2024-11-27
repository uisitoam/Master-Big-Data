with "jdbc:postgresql:bdge?user=alumnogreibd&password=greibd2021" as url
call apoc.load.jdbc(url, 
"select codigo_iso2, codigo_iso3, codigo_ioc, nombre from pais") yield row
create (:Pais {
  codigo_iso2: row.codigo_iso2,
  codigo_iso3: row.codigo_iso3,
  codigo_ioc: row.codigo_ioc,
  nombre: row.nombre
});


with "jdbc:postgresql:bdge?user=alumnogreibd&password=greibd2021" as url
call apoc.load.jdbc(url, 
"select id, nombre, apellido, diestro, fecha_nacimiento, pais, altura from jugador") yield row
match (pa:Pais {codigo_iso2: row.pais})
create (j:Jugador {
  id: row.id,
  nombre: row.nombre,
  apellido: row.apellido,
  diestro: row.diestro,
  fecha_nacimiento: row.fecha_nacimiento,
  altura: row.altura
})
create (j)-[:REPRESENTA_A]->(pa);


with "jdbc:postgresql:bdge?user=alumnogreibd&password=greibd2021" as url
call apoc.load.jdbc(url, 
"select id, nombre, pais from torneo") yield row
match (pa:Pais {codigo_iso2: row.pais})
create (t:Torneo {
  id: row.id,
  nombre: row.nombre
})
create (t)-[:SE_CELEBRA_EN]->(pa);


with "jdbc:postgresql:bdge?user=alumnogreibd&password=greibd2021" as url
call apoc.load.jdbc(url, 
"select torneo, fecha, superficie, tamano, nivel from edicion_torneo") yield row
match (t:Torneo {id: row.torneo})
create (e:EdicionTorneo {
  --torneo_id: row.torneo,
  fecha: row.fecha,
  superficie: row.superficie,
  tamano: row.tamano,
  nivel: row.nivel
})
create (e)-[:EDICION_DE]->(t);




with "jdbc:postgresql:bdge?user=alumnogreibd&password=greibd2021" as url
call apoc.load.jdbc(url, 
"select torneo, fecha, num_partido, num_sets, ronda, desenlace, ganador, perdedor from partido") yield row
match (e:EdicionTorneo {torneo_id: row.torneo, fecha: row.fecha})
match (g:Jugador {id: row.ganador})
match (p:Jugador {id: row.perdedor})
create (partido:Partido {
  num_partido: row.num_partido,
  num_sets: row.num_sets,
  ronda: row.ronda,
  desenlace: row.desenlace
})
create (partido)-[:SE_JUEGA_EN]->(e)
create (partido)-[:GANADO_POR {num_aces: row.num_aces_ganador, 
                               num_dob_faltas: row.num_dob_faltas_ganador, 
                               num_ptos_servidos: row.num_ptos_servidos_ganador, 
                               num_primeros_servicios: row.num_primeros_servicios_ganador, 
                               num_primeros_servicios_ganados: row.num_primeros_servicios_ganados_ganador, 
                               num_segundos_servicios_ganados: row.num_segundos_servicios_ganados_ganador, 
                               num_juegos_servidos: row.num_juegos_servidos_ganador, 
                               num_break_salvados: row.num_break_salvados_ganador, 
                               num_break_afrontados: row.num_break_afrontados_ganador}]->(g)
create (partido)-[:PERDIDO_POR {num_aces: row.num_aces_perdedor, 
                                num_dob_faltas: row.num_dob_faltas_perdedor, 
                                num_ptos_servidos: row.num_ptos_servidos_perdedor, 
                                num_primeros_servicios: row.num_primeros_servicios_perdedor, 
                                num_primeros_servicios_ganados: row.num_primeros_servicios_ganados_perdedor, 
                                num_segundos_servicios_ganados: row.num_segundos_servicios_ganados_perdedor, 
                                num_juegos_servidos: row.num_juegos_servidos_perdedor, 
                                num_break_salvados: row.num_break_salvados_perdedor, 
                                num_break_afrontados: row.num_break_afrontados_perdedor}]->(p);


with "jdbc:postgresql:bdge?user=alumnogreibd&password=greibd2021" as url
call apoc.load.jdbc(url, 
"select torneo, fecha, num_partido, num_set, juegos_ganador, juegos_perdedor, puntos_tiebreak_perdedor from sets_partido") yield row
match (partido:Partido {num_partido: row.num_partido})
create (s:SetPartido {
  num_set: row.num_set,
  juegos_ganador: row.juegos_ganador,
  juegos_perdedor: row.juegos_perdedor,
  puntos_tiebreak_perdedor: row.puntos_tiebreak_perdedor
})
create (s)-[:PERTENECE_A]->(partido);






-- indices
create index for (p:Pais) on (p.codigo_iso2);
create index for (j:Jugador) on (j.id);
create index for (t:Torneo) on (t.id);
create index for (e:EdicionTorneo) on (e.torneo_id, e.fecha);