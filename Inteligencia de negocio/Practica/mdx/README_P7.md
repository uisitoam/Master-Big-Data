# Práctica 7: Consultas MDX

Para esta práctica usaremos Saiku. Proponer 5 consultas datos de finanzas o de satisfacción de usuarios. Describir la consulta y por qué puede ser interesante para una productora. Entregar el enunciado, la descripción, los resultados y el código MDX.


## CONSULTA 1
--------------
```
WITH
MEMBER [Measures].[roiPromedio] AS
	(([Measures].[beneficio]) / [Measures].[coste])
SET [~ROWS_productor_productor.jerarquiaproductor] AS
	{[productor.jerarquiaproductor].[nivelproductor].Members}
SET [~ROWS_director_director.jerarquiadirector] AS
	{[director.jerarquiadirector].[niveldirector].Members}
SELECT
NON EMPTY {[Measures].[roiPromedio]} ON COLUMNS,
NON EMPTY Order(TopCount(NonEmptyCrossJoin([~ROWS_productor_productor.jerarquiaproductor], [~ROWS_director_director.jerarquiadirector]), 30, ([Measures].[beneficio] / [Measures].[coste])), [Measures].[beneficio]/[Measures].[coste], DESC) ON ROWS
FROM [finanzas]
```



## CONSULTA 2
--------------
```
WITH
MEMBER [Measures].[tendencia] AS
	(([tiempoemision].[anno].CurrentMember, [Measures].[ingresos]) - [tiempoemision].[anno].PrevMembe)
SET [~ROWS] AS
	Order({[productora.jerarquiaproductora].[nivelproductora].Members}, ([tiempoemision].[anno].CurrentMember, [Measures].[ingresos]) - [tiempoemision].[anno].PrevMembe, [Measures].[ingresos], ASC)
SELECT
NON EMPTY {[Measures].[tendencia]} ON COLUMNS,
NON EMPTY [~ROWS] ON ROWS
FROM [finanzas]
```


## CONSULTA 3
--------------
```
WITH
MEMBER [Measures].[cuotaMercado] AS
	((100 * [Measures].[ingresos]) / Sum([productora].[nivelproductora].Members, [Measures].[ingresos]))
SET [~ROWS_productora_productora.jerarquiaproductora] AS
	{[productora.jerarquiaproductora].[nivelproductora].Members}
SET [~ROWS_tiempoemision_tiempoemision.jerarquiatiempo] AS
	{[tiempoemision.jerarquiatiempo].[anno].Members}
SELECT
NON EMPTY {[Measures].[cuotaMercado]} ON COLUMNS,
NON EMPTY TopCount(NonEmptyCrossJoin([~ROWS_productora_productora.jerarquiaproductora], [~ROWS_tiempoemision_tiempoemision.jerarquiatiempo]), 10, [Measures].[ingresos]) ON ROWS
FROM [finanzas]
```


## CONSULTA 4
--------------
```
WITH
SET [~ROWS_productora_productora.jerarquiaproductora] AS
	{[productora.jerarquiaproductora].[nivelproductora].Members}
SET [~ROWS_tiempoemision_tiempoemision.jerarquiatiempo] AS
	{[tiempoemision.jerarquiatiempo].[anno].Members}
SELECT
NON EMPTY {[Measures].[ingresos]} ON COLUMNS,
NON EMPTY Order(TopCount(NonEmptyCrossJoin([~ROWS_productora_productora.jerarquiaproductora], [~ROWS_tiempoemision_tiempoemision.jerarquiatiempo]), 30, [Measures].[ingresos]), [productora.jerarquiaproductora].[nivelproductora].CURRENTMEMBER.ORDERKEY, ASC) ON ROWS
FROM [finanzas]
```

## CONSULTA 5
--------------
```
WITH
SET [~ROWS] AS
	Order(TopCount({[director.jerarquiadirector].[niveldirector].Members}, 20, [Measures].[beneficio]), [Measures].[beneficio], DESC)
SELECT
NON EMPTY {[Measures].[coste], [Measures].[ingresos], [Measures].[beneficio]} ON COLUMNS,
NON EMPTY [~ROWS] ON ROWS
FROM [finanzas]
```