
USE Albarran_DW;
GO

/* =========================================================
   1. CONTEO DE REGISTROS POR TABLA
   ========================================================= */

SELECT 'Dim_Cliente' AS Tabla, COUNT(*) AS TotalFilas
FROM dbo.Dim_Cliente
UNION ALL
SELECT 'Dim_Empleado', COUNT(*)
FROM dbo.Dim_Empleado
UNION ALL
SELECT 'Dim_Producto', COUNT(*)
FROM dbo.Dim_Producto
UNION ALL
SELECT 'Dim_Sucursal', COUNT(*)
FROM dbo.Dim_Sucursal
UNION ALL
SELECT 'Dim_Tiempo', COUNT(*)
FROM dbo.Dim_Tiempo
UNION ALL
SELECT 'Fact_Ventas', COUNT(*)
FROM dbo.Fact_Ventas;
GO

/* =========================================================
   2. VALIDACION DE MIEMBROS DESCONOCIDOS
   ========================================================= */

SELECT 'Dim_Cliente' AS Tabla,
       COUNT(*) AS MiembrosDesconocidos
FROM dbo.Dim_Cliente
WHERE EsDesconocido = 1

UNION ALL

SELECT 'Dim_Empleado', COUNT(*)
FROM dbo.Dim_Empleado
WHERE EsDesconocido = 1

UNION ALL

SELECT 'Dim_Producto', COUNT(*)
FROM dbo.Dim_Producto
WHERE EsDesconocido = 1

UNION ALL

SELECT 'Dim_Sucursal', COUNT(*)
FROM dbo.Dim_Sucursal
WHERE EsDesconocido = 1;
GO

/* =========================================================
   3. VALIDACION DE CLAVES DIMENSIONALES EN LOS HECHOS
   ========================================================= */

SELECT
    COUNT(*) AS TotalHechos,
    SUM(CASE WHEN t.Tiempo_SK IS NULL THEN 1 ELSE 0 END)
        AS FechasSinCorrespondencia,
    SUM(CASE WHEN c.Cliente_SK IS NULL THEN 1 ELSE 0 END)
        AS ClientesSinCorrespondencia,
    SUM(CASE WHEN e.Empleado_SK IS NULL THEN 1 ELSE 0 END)
        AS EmpleadosSinCorrespondencia,
    SUM(CASE WHEN p.Producto_SK IS NULL THEN 1 ELSE 0 END)
        AS ProductosSinCorrespondencia,
    SUM(CASE WHEN s.Sucursal_SK IS NULL THEN 1 ELSE 0 END)
        AS SucursalesSinCorrespondencia
FROM dbo.Fact_Ventas AS f
LEFT JOIN dbo.Dim_Tiempo AS t
    ON f.Tiempo_SK = t.Tiempo_SK
LEFT JOIN dbo.Dim_Cliente AS c
    ON f.Cliente_SK = c.Cliente_SK
LEFT JOIN dbo.Dim_Empleado AS e
    ON f.Empleado_SK = e.Empleado_SK
LEFT JOIN dbo.Dim_Producto AS p
    ON f.Producto_SK = p.Producto_SK
LEFT JOIN dbo.Dim_Sucursal AS s
    ON f.Sucursal_SK = s.Sucursal_SK;
GO

/* =========================================================
   4. CONCILIACION DE IMPORTES DE VENTA
   ========================================================= */

SELECT
    COUNT(*) AS TotalFilas,
    COUNT(DISTINCT Venta_BK) AS VentasDistintas,
    SUM(MontoBruto) AS TotalBruto,
    SUM(MontoDescuento) AS TotalDescuento,
    SUM(MontoNeto) AS TotalNeto
FROM dbo.Fact_Ventas;
GO

/* =========================================================
   5. VALIDACION DE CLAVES DE NEGOCIO EN DIMENSIONES
   ========================================================= */

SELECT
    'Dim_Cliente' AS Tabla,
    COUNT(*) AS Filas,
    COUNT(DISTINCT Cliente_BK) AS ClavesNegocio
FROM dbo.Dim_Cliente
WHERE Cliente_BK IS NOT NULL

UNION ALL

SELECT
    'Dim_Empleado',
    COUNT(*),
    COUNT(DISTINCT Empleado_BK)
FROM dbo.Dim_Empleado
WHERE Empleado_BK IS NOT NULL

UNION ALL

SELECT
    'Dim_Producto',
    COUNT(*),
    COUNT(DISTINCT Producto_BK)
FROM dbo.Dim_Producto
WHERE Producto_BK IS NOT NULL

UNION ALL

SELECT
    'Dim_Sucursal',
    COUNT(*),
    COUNT(DISTINCT Sucursal_BK)
FROM dbo.Dim_Sucursal
WHERE Sucursal_BK IS NOT NULL;
GO
