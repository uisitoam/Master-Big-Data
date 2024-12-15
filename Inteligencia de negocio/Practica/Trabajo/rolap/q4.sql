--4. Media móvil de valoraciones de satisfacción
--Consulta para calcular una media móvil de tres meses para las 
--valoraciones del restaurante.

SELECT 
    r.ciudad AS ciudad,
    t.ano,
    t.mes,
    f.valoracion_ambiente,
    f.valoracion_personal,
    f.valoracion_comida,
    ROUND(
        (f.valoracion_ambiente + f.valoracion_personal + f.valoracion_comida) / 3.0, 2
    ) AS valoracion_total,
    ROUND(
        AVG((f.valoracion_ambiente + f.valoracion_personal + f.valoracion_comida) / 3.0) OVER (
            PARTITION BY r.ciudad, r.id ORDER BY t.ano, t.mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS media_movil_3_meses
FROM 
    fact_satisfaccion f
JOIN 
    dim_restaurante r ON f.restaurante = r.id
JOIN 
    dim_tiempo t ON f.fecha = t.id
ORDER BY 
    r.ciudad, r.id, t.ano, t.mes;

