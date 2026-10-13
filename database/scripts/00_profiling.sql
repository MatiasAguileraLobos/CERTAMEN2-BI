USE Albarran_OLTP;
GO

-- 1. Nulos por columna crítica
SELECT 'clientes' AS tabla, COUNT(*) AS filas,
       SUM(CASE WHEN nombre IS NULL THEN 1 ELSE 0 END) AS nulos_nombre,
       SUM(CASE WHEN appaterno IS NULL THEN 1 ELSE 0 END) AS nulos_appaterno,
       SUM(CASE WHEN fecha_nacimiento IS NULL THEN 1 ELSE 0 END) AS nulos_fecha_nac
FROM clientes;

SELECT 'productos' AS tabla, COUNT(*) AS filas,
       SUM(CASE WHEN precio IS NULL THEN 1 ELSE 0 END) AS nulos_precio,
       SUM(CASE WHEN categoria_id IS NULL THEN 1 ELSE 0 END) AS nulos_categoria
FROM productos;

SELECT 'detalle_ventas' AS tabla, COUNT(*) AS filas,
       SUM(CASE WHEN descuento IS NULL THEN 1 ELSE 0 END) AS nulos_descuento,
       SUM(CASE WHEN cantidad <= 0 THEN 1 ELSE 0 END) AS cantidad_invalida,
       SUM(CASE WHEN precio_unitario <= 0 THEN 1 ELSE 0 END) AS precio_invalido
FROM detalle_ventas;

-- 2. Duplicados en claves de negocio
SELECT cliente_id, COUNT(*)
FROM clientes
GROUP BY cliente_id
HAVING COUNT(*) > 1;

SELECT producto_id, COUNT(*)
FROM productos
GROUP BY producto_id
HAVING COUNT(*) > 1;

SELECT venta_id, COUNT(*)
FROM ventas
GROUP BY venta_id
HAVING COUNT(*) > 1;

-- 3. Huérfanos
SELECT COUNT(*) AS detalle_sin_venta
FROM detalle_ventas d
LEFT JOIN ventas v ON d.venta_id = v.venta_id
WHERE v.venta_id IS NULL;

SELECT COUNT(*) AS ventas_sin_cliente
FROM ventas v
LEFT JOIN clientes c ON v.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;

SELECT COUNT(*) AS productos_sin_categoria
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.categoria_id
WHERE c.categoria_id IS NULL;

-- 4. Rangos inválidos en fechas
SELECT COUNT(*) AS fechas_futuras
FROM ventas
WHERE fecha > CAST(GETDATE() AS DATE);

SELECT COUNT(*) AS fechas_antes_2000
FROM ventas
WHERE fecha < '2000-01-01';

-- 5. Revisión de descuento
SELECT TOP 20 descuento
FROM detalle_ventas
ORDER BY descuento DESC;

SELECT MAX(descuento) AS max_desc,
       AVG(descuento) AS avg_desc
FROM detalle_ventas;

-- 6. Valores negativos
SELECT COUNT(*)
FROM empleados
WHERE sueldo_base < 0;

SELECT COUNT(*)
FROM productos
WHERE precio < 0;
