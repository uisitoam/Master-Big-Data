## Consulta SQL que obtiene un ranking directores
-------------
```
select d.nombre as director, cast(avg(su.satisfaccion) as numeric(2,1)) as valoracion, sum(su.votos) as votos
from public.satisfaccion_usuarios su, public.tiempo t, public.director d
where su.director = d.id
	and su.tiempo_emision = t.id
group by d.id
order by valoracion desc
```

## Consulta MDX para el ROI promedio por director/es
-------------
```
WITH
  MEMBER [Measures].[roiPromedio] AS
    ([Measures].[beneficio] / [Measures].[coste])
SET [~ROWS_director_director.jerarquiadirector] AS
    {[director.jerarquiadirector].[niveldirector].Members} -- Solo directores
SELECT
  NON EMPTY {[Measures].[roiPromedio]} ON COLUMNS,
  NON EMPTY TopCount(
    [~ROWS_director_director.jerarquiadirector], 
    30, 
    [Measures].[roiPromedio]
  ) ON ROWS
FROM [finanzas]
```

## Consulta SQL que obtiene un ranking de productoras
-------------
```
select p.nombre as productora, cast(avg(su.satisfaccion) as numeric(2,1)) as valoracion, sum(su.votos) as votos
from public.satisfaccion_usuarios su, public.tiempo t, public.productora p
where su.productora = p.id
	and su.tiempo_emision = t.id
	and position(',' in p.nombre) = 0
group by p.id
order by valoracion desc
```

## Consulta MDX para la cuota de mercado de las productoras en 2001
-------------

```
WITH
  MEMBER [Measures].[cuotaMercado] AS
    ((100 * [Measures].[ingresos]) / 
      Sum([productora].[nivelproductora].Members, [Measures].[ingresos]))
SET [~ROWS_productora_productora.jerarquiaproductora] AS
    {[productora.jerarquiaproductora].[nivelproductora].Members}
SET [~ROWS_tiempoemision_tiempoemision.jerarquiatiempo] AS
    {[tiempoemision.jerarquiatiempo].[anno].[2001]}
SELECT
  NON EMPTY {[Measures].[cuotaMercado]} ON COLUMNS,
  NON EMPTY TopCount(
    NonEmptyCrossJoin(
      [~ROWS_productora_productora.jerarquiaproductora], 
      [~ROWS_tiempoemision_tiempoemision.jerarquiatiempo]
    ), 
    10, 
    [Measures].[ingresos]
  ) ON ROWS
FROM [finanzas]
```