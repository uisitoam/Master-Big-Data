--6. Identificación de nuevos clientes y su contribución
--Consulta para identificar el porcentaje de nuevos clientes 
--respecto al total por mes y restaurante.

SELECT 
    r.ciudad AS ciudad,
    t.ano,
    t.mes,
    SUM(f.nuevos_clientes_presencial + f.nuevos_clientes_domicilio) AS nuevos_clientes,
    SUM(f.numero_clientes_presencial + f.numero_clientes_domicilio) AS total_clientes,
    ROUND(
        SUM(f.nuevos_clientes_presencial + f.nuevos_clientes_domicilio) * 100.0 
        / SUM(f.numero_clientes_presencial + f.numero_clientes_domicilio), 2
    ) AS porcentaje_nuevos_clientes
FROM 
    fact_finanzas f
JOIN 
    dim_restaurante r ON f.restaurante = r.id
JOIN 
    dim_tiempo t ON f.fecha = t.id
GROUP BY 
    r.ciudad, t.ano, t.mes
ORDER BY 
    r.ciudad, t.ano, t.mes;

