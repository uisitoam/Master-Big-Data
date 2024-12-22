select concat(j.nombre, ' ', j.apellido) as jugador, j.pais
from partido p
join (select j.id 
    from (
        select p.ganador, p.perdedor
        from partido p 
        join edicion_torneo et on p.torneo = et.torneo and p.fecha = et.fecha 
        join torneo t on et.torneo = t.id
        join jugador j on p.perdedor = j.id or p.ganador = j.id
        where 
            t.nombre = 'Roland Garros' and 
            extract(year from et.fecha) = 2018 and
            p.ronda = 'R128' and 
            j.nombre = 'Rafael' and
            j.apellido = 'Nadal') as jugadores_garros
    join jugador j on jugadores_garros.ganador = j.id or jugadores_garros.perdedor = j.id
    where 
        j.nombre != 'Rafael' and 
        j.apellido != 'Nadal') as rival_nadal
on p.ganador = rival_nadal.id
join jugador j on p.perdedor = j.id
where extract(year from p.fecha) = 2018;
