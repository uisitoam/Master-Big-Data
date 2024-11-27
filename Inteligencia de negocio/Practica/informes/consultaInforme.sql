with scores as(
    select distinct on (t.ano)
        d.nombre as directores, p.nombre as productores, string_agg(pa.nombre, ', ') as productoras, f.ingresos - f.coste as beneficio, cast(avg(su.satisfaccion_usuario) as numeric(2, 1)) as valoracion, sum(su.votos) as votos, t.ano as ano, cast(avg(su.satisfaccion_usuario) as numeric(2, 1))*(f.ingresos - f.coste) as score
    from public.satisfaccion_usuarios su, public.director d, public.productor p, public.productora pa, public.tiempo t, public.finanzas f
    where su.director = d.id 
        and su.productor = p.id 
        and su.productora = pa.id
        and su.tiempo_emision = t.id 
        and f.director = su.director 
        and f.productor = su.productor
        and f.productora = su.productora
    group by d.id, p.id, f.ingresos, f.coste, t.ano, d.nombre, p.nombre
    order by t.ano, score desc
)

select directores, productores, productoras, beneficio, valoracion, votos, ano 
from scores
where ano > 2003 
order by ano
