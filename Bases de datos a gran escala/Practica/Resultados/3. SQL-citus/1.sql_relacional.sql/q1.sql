select j.nombre, j.apellido, extract(year from p.fecha) as ano
from torneo t
join partido p on t.id = p.torneo
join jugador j on p.ganador = j.id 
where 
    t.nombre = 'Wimbledon' and
    p.ronda = 'F'
order by ano;
