select 
    extract(year from et.fecha) as ano, 
    count(et.torneo) as torneos,
    STRING_AGG(t.nombre, ', ' ORDER BY et.fecha) as torneos
from partido p
join edicion_torneo et on p.torneo = et.torneo and p.fecha = et.fecha
join torneo t on et.torneo = t.id
join jugador j on p.ganador = j.id
where 
    p.ronda = 'F' and 
    j.nombre = 'Roger' and
    j.apellido = 'Federer' and
    et.nivel in ('G','M')
group by ano
order by ano;
