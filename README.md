# Certamen 2 - Inteligencia de Negocios

## Caso seleccionado
Mueblería Albarrán

## Integrantes y sección
- Luis Sarzuri
- Matías Fernández Vargas
- Matías Aguilera

- Sección: 300
- Profesor: Hernan Saavedra Gonzalez

## Descripción del problema
Mueblería Albarrán dispone de información transaccional sobre ventas, clientes, empleados, productos, sucursales y detalles de venta. Para facilitar el análisis comercial integrado, se organiza la información en un almacén dimensional que permite analizar las ventas por fecha, cliente, empleado, producto y sucursal. El trabajo considera el perfilamiento de los datos de origen, la construcción del modelo dimensional y la implementación de un proceso ETL.

## Objetivo del proyecto
Diseñar e implementar una primera versión de un Data Warehouse para Mueblería Albarrán mediante un modelo dimensional y un proceso ETL en SQL Server Integration Services (SSIS). La solución carga dimensiones y hechos, conserva miembros desconocidos para las dimensiones correspondientes y permite validar la integridad y consistencia de los datos.

## KPI definidos
Las siguientes medidas están disponibles para el análisis. Las metas o umbrales de negocio deben confirmarse con la definición del caso; este README no establece metas numéricas.

| Indicador | Definición |
|---|---|
| Monto bruto de ventas | Suma de `MontoBruto`. |
| Monto de descuentos | Suma de `MontoDescuento`. |
| Monto neto de ventas | Suma de `MontoNeto`. |
| Cantidad vendida | Suma de `Cantidad`. |
| Número de ventas | Conteo de `Venta_BK` distintos; la granularidad de hechos es una línea de producto por venta. |

**Nota sobre el descuento:** la columna de origen `detalle_ventas.descuento` es numérica y los registros revisados contienen `0.00`. No se pudo confirmar si representa un porcentaje o un importe monetario. Se conserva la interpretación: `MontoDescuento = descuento` y `MontoNeto = MontoBruto - MontoDescuento`. Como los valores son cero, esto no altera los totales observados.

## Modelo dimensional

### Proceso de negocio
Análisis de ventas de muebles comercializados por Mueblería Albarrán, por fecha, cliente, empleado, producto y sucursal.

### Granularidad
**Una fila de `Fact_Ventas` representa una línea de detalle de un producto vendido dentro de una venta.** Una venta con varios productos puede aparecer en varias filas.

### Dimensiones
- **`Dim_Tiempo`:** fecha, año, semestre, trimestre, mes, nombre del mes, día, día de la semana e indicador de fin de semana.
- **`Dim_Cliente`:** clave de negocio, nombre completo, sexo, fecha de nacimiento, estado civil y rango etario.
- **`Dim_Empleado`:** clave de negocio, nombre completo, cargo, fecha de contrato y sueldo base.
- **`Dim_Producto`:** clave de negocio, nombre, descripción, categoría y precio de lista.
- **`Dim_Sucursal`:** clave de negocio, nombre de sucursal y comuna.

Las dimensiones de cliente, empleado, producto y sucursal contienen un miembro desconocido con clave sustituta `-1` y `EsDesconocido = 1`. `Dim_Tiempo` utiliza `Tiempo_SK` con formato `YYYYMMDD`.

### Tabla de hechos y medidas
`Fact_Ventas` contiene las claves hacia las cinco dimensiones:
- **Claves dimensionales:** `Tiempo_SK`, `Cliente_SK`, `Empleado_SK`, `Producto_SK` y `Sucursal_SK`.
- **Identificación de venta:** `Venta_BK`, `TipoDocumento` y `NumeroDocumento`.
- **Medidas:** `Cantidad`, `PrecioUnitario`, `MontoBruto`, `MontoDescuento` y `MontoNeto`.
- **Auditoría:** `FechaCarga`, `OrigenSistema` y `UsuarioCarga`.

## Tecnologías utilizadas
- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- Visual Studio con SQL Server Integration Services (SSIS).
- Git y GitHub.

## Proceso ETL - Fase 1
Pendiente.

## Cubo OLAP - Fase 2
Pendiente.

## Dashboard Power BI - Fase 2
Pendiente.

## Tecnologías utilizadas
- SQL Server 2019+
- SQL Server Data Tools (SSDT) / Visual Studio con Integration Services
- Git + GitHub

## Estructura del repositorio
```text
CERTAMEN2-BI/
├── README.md
├── .gitignore
├── docs/
│   ├── modelo-dimensional/
│   ├── presentacion/
│   ├── informe/
│   └── evidencias/
├── database/
│   └── scripts/
│       ├── 00_profiling.sql
│       ├── 01_creacion_dw.sql
│       └── 02_dim_tiempo.sql
└── etl/
    └── proyecto-ssis/

## Instrucciones de ejecución/revisión
Pendiente.

## Distribución de responsabilidades y aportes
Pendiente.