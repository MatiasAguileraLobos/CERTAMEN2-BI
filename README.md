# Certamen 2 - Inteligencia de Negocios

## Caso seleccionado
**Mueblería Albarrán**

## Integrantes y sección
- Luis Sarzuri
- Matías Fernández Vargas
- Matías Aguilera

<<<<<<< HEAD
- **Sección:** 300
- **Profesor:** Hernan Saavedra Gonzalez
=======
**Sección:** 300  
**Profesor:** Hernan Saavedra Gonzalez
>>>>>>> 5fc4b62aecd2db9fe06a9c1c6506020764b0ace4

## Descripción del problema
Mueblería Albarrán dispone de información transaccional sobre ventas, clientes, empleados, productos, sucursales y detalles de venta. Para facilitar el análisis comercial integrado, se organiza la información en un almacén dimensional que permite analizar las ventas por fecha, cliente, empleado, producto y sucursal.

El proyecto considera el perfilamiento de los datos de origen, la construcción del modelo dimensional y la implementación de un proceso ETL mediante SQL Server Integration Services (SSIS).

## Objetivo del proyecto
Diseñar e implementar una primera versión de un Data Warehouse para Mueblería Albarrán mediante un modelo dimensional y un proceso ETL en SQL Server. La solución permite cargar las dimensiones y la tabla de hechos, conservar miembros desconocidos en las dimensiones correspondientes y preparar los datos para su posterior análisis.

## KPI definidos

| Indicador | Definición |
|---|---|
| Monto bruto de ventas | Suma de `MontoBruto`. |
| Monto de descuentos | Suma de `MontoDescuento`. |
| Monto neto de ventas | Suma de `MontoNeto`. |
| Cantidad vendida | Suma de `Cantidad`. |
| Número de ventas | Conteo de valores distintos de `Venta_BK`. |

La granularidad de la tabla de hechos es una línea de detalle de producto por venta. Por ello, el número de filas de `Fact_Ventas` no equivale necesariamente al número de ventas distintas. Las metas y los umbrales comerciales deberán definirse según los requerimientos del negocio.

**Nota sobre el descuento:** la columna de origen `detalle_ventas.descuento` contiene valores `0.00` en los registros revisados. No fue posible confirmar si representa un porcentaje o un importe monetario. Se conserva la interpretación implementada: `MontoDescuento = descuento` y `MontoNeto = MontoBruto - MontoDescuento`. Como los valores observados son cero, esto no altera los totales actuales.

## Modelo dimensional

### Proceso de negocio
Análisis de las ventas de muebles comercializados por Mueblería Albarrán, considerando las perspectivas de tiempo, cliente, empleado, producto y sucursal.

### Granularidad
**Una fila de `Fact_Ventas` representa una línea de detalle de un producto vendido dentro de una venta.** Una venta que incluye varios productos puede aparecer en varias filas.

### Dimensiones
- **`Dim_Tiempo`:** fecha, año, semestre, trimestre, mes, nombre del mes, día, día de la semana e indicador de fin de semana.
- **`Dim_Cliente`:** clave de negocio, nombre completo, sexo, fecha de nacimiento, estado civil y rango etario.
- **`Dim_Empleado`:** clave de negocio, nombre completo, cargo, fecha de contrato y sueldo base.
- **`Dim_Producto`:** clave de negocio, nombre, descripción, categoría y precio de lista.
- **`Dim_Sucursal`:** clave de negocio, nombre de sucursal y comuna.

Las dimensiones de cliente, empleado, producto y sucursal contienen un miembro desconocido con clave sustituta `-1` y `EsDesconocido = 1`. La dimensión tiempo utiliza `Tiempo_SK` con formato `YYYYMMDD` y contiene las fechas del año 2017.

### Tabla de hechos y medidas
`Fact_Ventas` contiene:

- **Claves dimensionales:** `Tiempo_SK`, `Cliente_SK`, `Empleado_SK`, `Producto_SK` y `Sucursal_SK`.
- **Identificación de venta:** `Venta_BK`, `TipoDocumento` y `NumeroDocumento`.
- **Medidas:** `Cantidad`, `PrecioUnitario`, `MontoBruto`, `MontoDescuento` y `MontoNeto`.
- **Auditoría:** `FechaCarga`, `OrigenSistema` y `UsuarioCarga`, según la definición de la tabla.

## Cubo OLAP - Fase 2
Pendiente de implementación en esta fase. La Fase 2 contempla construir el cubo OLAP de acuerdo con las instrucciones del certamen.

## Dashboard Power BI - Fase 2
Pendiente de implementación en esta fase. La Fase 2 contempla desarrollar un dashboard en Power BI según los requisitos del certamen.

## Tecnologías utilizadas
- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- Visual Studio con SQL Server Integration Services (SSIS).
- Git y GitHub.

<<<<<<< HEAD
=======
## Proceso ETL - Fase 1

El paquete principal de Integration Services se denomina `Carga_Dimensiones.dtsx` y pertenece al proyecto `Carga_Dimensiones`.

El flujo de control ejecuta una recarga completa mediante la tarea `SQL_Borrar_Datos_Destino` y después carga las dimensiones y la tabla de hechos en el siguiente orden:

1. `DFT_Cargar_Dim_Cliente`
2. `DFT_Cargar_Dim_Empleado`
3. `DFT_Cargar_Dim_Producto`
4. `DFT_Cargar_Dim_Sucursal`
5. `DFT_Cargar_Fact_Ventas`

Las dimensiones se cargan antes de los hechos para que las claves sustitutas estén disponibles al insertar las ventas. La tarea de borrado elimina los datos cargados previamente de la tabla de hechos y de los miembros reales de las dimensiones correspondientes, conservando los miembros desconocidos.

Se utilizan componentes OLE DB Source y OLE DB Destination, además de transformaciones de columna derivada cuando es necesario adaptar tipos de texto o preparar atributos.

**Precaución:** el paquete utiliza una estrategia de recarga completa. Antes de ejecutarlo, se debe comprobar que las conexiones apunten a la base de datos `Albarran_DW` correcta, ya que la tarea de borrado elimina datos de destino. Las conexiones pueden requerir ajustes al abrir el proyecto en otro equipo.

## Cubo OLAP - Fase 2
Pendiente de implementación.

## Dashboard Power BI - Fase 2
Pendiente de implementación.

>>>>>>> 5fc4b62aecd2db9fe06a9c1c6506020764b0ace4
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
│   ├── scripts/
│   │   ├── 00_profiling.sql
│   │   ├── 01_creacion_dw.sql
│   │   ├── 02_dim_tiempo.sql
│   │   └── 03_validaciones.sql
│   └── backup/
│       └── Albarran_DW.bak
└── etl/
    └── Carga_Dimensiones/
        ├── Carga_Dimensiones.sln
        └── Carga_Dimensiones/
            ├── Carga_Dimensiones.dtproj
            ├── Carga_Dimensiones.dtsx
            ├── Project.params
            └── Carga_Dimensiones.database
```

La estructura representa los archivos considerados para esta etapa. No se deben incluir carpetas temporales de Visual Studio como `.vs`, `bin` u `obj`, ni archivos locales `*.dtproj.user`.

## Instrucciones de ejecución y revisión

1. Ejecutar `01_creacion_dw.sql` en un entorno controlado para crear el almacén dimensional.
2. Ejecutar `02_dim_tiempo.sql` para generar los registros de la dimensión tiempo.
3. Abrir `Carga_Dimensiones.sln` en Visual Studio.
4. Revisar y ajustar los administradores de conexión OLE DB para las bases `Albarran` y `Albarran_DW`.
5. Confirmar que el destino corresponda al almacén dimensional correcto.
6. Ejecutar el paquete `Carga_Dimensiones.dtsx` y comprobar el estado de las tareas.

Las consultas de validación y el respaldo del almacén dimensional se incorporarán al repositorio en una actualización posterior.

## Distribución de responsabilidades y aportes
Pendiente.

## Presentación
https://canva.link/s5xqy9642af6sjh

- **Luis Sarzuri:** perfilamiento y revisión de los datos de origen, además de aportes a las cargas de dimensiones.
- **Matías Fernández Vargas:** estructura inicial del repositorio, documentación, enfoque Kimball y aportes al modelo dimensional y a `Dim_Tiempo`.
- **Matías Aguilera:** desarrollo y pruebas de la carga de hechos, validaciones y conciliación; también participó en el desarrollo y las pruebas de las cargas de dimensiones.

La distribución debe reflejar los aportes efectivamente realizados por cada integrante y los commits definitivos del equipo.
