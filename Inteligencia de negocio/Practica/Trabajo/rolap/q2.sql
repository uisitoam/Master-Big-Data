--2. Ranking de productos más vendidos por restaurante
--Consulta para obtener el ranking de los productos más vendidos en cada restaurante,
--basado en las ventas totales.

SELECT 
    r.ciudad  AS ciudad,
    p.nombre AS producto,
    SUM(v.ventas) AS total_ventas,
    RANK() OVER (PARTITION BY r.id ORDER BY SUM(v.ventas) DESC) AS ranking_producto
FROM 
    fact_ventas v
JOIN 
    dim_restaurante r ON v.restaurante = r.id
JOIN 
    dim_productos p ON v.producto = p.id
GROUP BY 
    r.id, p.nombre
ORDER BY 
    r.id, ranking_producto;
