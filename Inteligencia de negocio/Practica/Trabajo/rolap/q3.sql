--3. Variación porcentual mensual de ingresos por restaurante
--Consulta para calcular la variación porcentual mensual de los ingresos 
--presenciales por restaurante.

SELECT 
    r.ciudad AS ciudad,
    t.ano,
    t.mes_texto AS mes,
    SUM(f.ingresos_presencial) AS ingresos_mes,
    LAG(SUM(f.ingresos_presencial)) OVER (PARTITION BY r.id ORDER BY t.ano, t.mes) AS ingresos_mes_anterior,
    CASE 
        WHEN LAG(SUM(f.ingresos_presencial)) OVER (PARTITION BY r.id ORDER BY t.ano, t.mes) IS NULL THEN NULL
        ELSE ROUND(
            (SUM(f.ingresos_presencial) - LAG(SUM(f.ingresos_presencial)) OVER (PARTITION BY r.id ORDER BY t.ano, t.mes)) 
            / LAG(SUM(f.ingresos_presencial)) OVER (PARTITION BY r.id ORDER BY t.ano, t.mes) * 100, 2)
    END AS variacion_porcentual
FROM 
    fact_finanzas f
JOIN 
    dim_restaurante r ON f.restaurante = r.id
JOIN 
    dim_tiempo t ON f.fecha = t.id
GROUP BY 
    r.id, r.ciudad, t.ano, t.mes, t.mes_texto
ORDER BY 
    r.ciudad, t.ano, t.mes;
