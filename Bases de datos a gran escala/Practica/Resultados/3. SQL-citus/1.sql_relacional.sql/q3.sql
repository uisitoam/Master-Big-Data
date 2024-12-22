select 
    p.ronda, p.desenlace,
    (select concat(j.nombre, ' ', j.apellido) from jugador j where p.ganador = j.id) as ganador,
    (select concat(j.nombre, ' ', j.apellido) from jugador j where p.perdedor = j.id) as perdedor,

    (
        select STRING_AGG(
            concat(
                s.juegos_ganador, '-', s.juegos_perdedor, 
                    case when s.puntos_tiebreak_perdedor IS NOT NULL then concat('(', s.puntos_tiebreak_perdedor, ')') end
                ), 
                ' '
            ) as resultado 
            from sets_partido s
        where s.torneo = p.torneo and s.fecha = p.fecha and s.num_partido = p.num_partido
    )


from edicion_torneo et
join torneo t on et.torneo = t.id
join partido p on p.torneo = et.torneo and p.fecha = et.fecha 

where 
    t.nombre = 'Roland Garros' and
    extract(year from et.fecha) = 2018 and
    p.ronda in ('F','SF')
