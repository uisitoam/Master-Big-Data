--5. Comparación de ingresos entre restaurantes (percentil)
--Consulta para calcular el percentil de cada restaurante en 
--términos de ingresos totales (presenciales + domicilio).

WITH ingresos_anuales AS (
    SELECT 
        r.ciudad AS ciudad,
        SUM(f.ingresos_presencial + f.ingresos_domicilio) AS ingresos_totales_anuales
    FROM 
        fact_finanzas f
    JOIN 
        dim_restaurante r ON f.restaurante = r.id
    JOIN 
        dim_tiempo t ON f.fecha = t.id
    GROUP BY 
        r.ciudad
)
SELECT 
    ciudad,
    ingresos_totales_anuales,
    ROUND(PERCENT_RANK() OVER (ORDER BY ingresos_totales_anuales DESC)::numeric * 100, 2) AS percentil
FROM 
    ingresos_anuales
ORDER BY 
    percentil;



