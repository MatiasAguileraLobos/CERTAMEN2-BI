# Certamen 2 - Inteligencia de Negocios

## Caso seleccionado
**Mueblería Albarrán**

## Integrantes y sección
- Luis Sarzuri
- Matías Fernández Vargas
- Matías Aguilera

**Sección:** 300
**Profesor:** Hernán Saavedra Gonzalez

---

## Descripción del problema

Mueblería Albarrán dispone de información transaccional sobre ventas, clientes, empleados, productos y sucursales. El proyecto organiza estos datos para facilitar el análisis comercial mediante un Data Warehouse dimensional, un proceso ETL, un cubo OLAP y dashboards en Power BI.

## Objetivo del proyecto

Implementar una solución de Inteligencia de Negocios que permita analizar las ventas desde las perspectivas de tiempo, cliente, empleado, producto y sucursal, apoyando la toma de decisiones comerciales.

## KPI definidos

| Indicador | Definición | Utilidad |
|---|---|---|
| Monto bruto de ventas | Suma de `MontoBruto`. | Comparar el valor de las ventas antes de descuentos. |
| Monto de descuentos | Suma de `MontoDescuento`. | Cuantificar el efecto de los descuentos registrados. |
| Monto neto de ventas | Suma de `MontoNeto`. | Analizar los ingresos después de descuentos. |
| Cantidad vendida | Suma de `Cantidad`. | Identificar volumen de ventas por producto y segmento. |
| Número de ventas | Conteo distinto de `Venta_BK`. | Comparar el número de transacciones entre períodos y segmentos. |

La granularidad de `Fact_Ventas` corresponde a una línea de detalle de producto por venta. Por lo tanto, las filas de la tabla de hechos no necesariamente equivalen a ventas distintas.

**Nota sobre descuentos:** los registros de origen revisados contienen valores `0.00`. Se conserva la interpretación implementada (`MontoDescuento = descuento` y `MontoNeto = MontoBruto - MontoDescuento`); no fue posible confirmar si el campo representa porcentaje o importe.

---

## Modelo dimensional

### Proceso de negocio y granularidad

El proceso analizado corresponde a las ventas de muebles. Cada fila de `Fact_Ventas` representa una línea de detalle de un producto dentro de una venta.

### Dimensiones

- **`Dim_Tiempo`:** fecha, año, semestre, trimestre, mes, día y atributos de calendario. Contiene las fechas de 2017; `Tiempo_SK` utiliza formato `YYYYMMDD`.
- **`Dim_Cliente`:** clave de negocio, nombre, sexo, fecha de nacimiento, estado civil y rango etario.
- **`Dim_Empleado`:** clave de negocio, nombre, cargo, fecha de contrato y sueldo base.
- **`Dim_Producto`:** clave de negocio, nombre, descripción, categoría y precio de lista.
- **`Dim_Sucursal`:** clave de negocio, nombre y comuna.

Las dimensiones descriptivas incluyen un miembro desconocido con clave sustituta `-1`.

### Tabla de hechos y medidas

`Fact_Ventas` contiene las claves de las dimensiones, `Venta_BK`, los datos del documento y las medidas `Cantidad`, `PrecioUnitario`, `MontoBruto`, `MontoDescuento` y `MontoNeto`.

---

## Proceso ETL - Fase 1

El paquete `Carga_Dimensiones.dtsx`, del proyecto SSIS `Carga_Dimensiones`, realiza una recarga completa: limpia los datos de destino y carga las dimensiones de cliente, empleado, producto y sucursal antes de cargar `Fact_Ventas`.

Utiliza componentes OLE DB Source y Destination, transformaciones Derived Column y tareas SQL.

Antes de ejecutar el paquete, revisar que las conexiones apunten a las bases `Albarran` y `Albarran_DW` correctas, ya que la limpieza elimina los datos cargados previamente.

---

## Cubo OLAP - Fase 2

### Proyecto y origen de datos

El proyecto multidimensional SSAS `Albarran_OLAP` contiene el cubo de ventas `Cubo_Ventas_Albarran`, construido a partir de `Fact_Ventas` y las cinco dimensiones del modelo dimensional.

El proyecto utiliza:

- **Origen de datos:** `Albarran DW.ds`
- **Vista del origen de datos:** `Vista_Albarran_DW.dsv`
- **Data Warehouse:** `Albarran_DW`
- **Servidor de Analysis Services:** instancia local

La vista del origen de datos incorpora la tabla de hechos `Fact_Ventas` y las cinco dimensiones, estableciendo las relaciones mediante sus claves sustitutas.

### Dimensiones del cubo

El cubo incorpora las siguientes dimensiones:

- Dim Tiempo
- Dim Cliente
- Dim Empleado
- Dim Producto
- Dim Sucursal

Las dimensiones fueron generadas desde las tablas del Data Warehouse y procesadas correctamente.

### Medidas del cubo

El grupo de medidas `Fact Ventas` contiene las siguientes medidas base:

| Medida | Agregación | Formato | Descripción |
|---|---|---|---|
| Cantidad | Sum | `#,##0` | Suma de unidades vendidas. |
| Precio Unitario | AverageOfChildren | `$#,##0;($#,##0);$0` | Promedio del precio unitario según la agregación configurada. |
| Monto Bruto | Sum | `$#,##0;($#,##0);$0` | Suma de los importes brutos de venta. |
| Monto Descuento | Sum | `$#,##0;($#,##0);$0` | Suma de los descuentos registrados. |
| Monto Neto | Sum | `$#,##0;($#,##0);$0` | Suma de los importes netos de venta. |
| Recuento Fact Ventas | DistinctCount de `Venta_BK` | `#,##0` | Conteo de ventas distintas por clave de negocio. |

Además, el cubo incorpora:

- **Medida calculada MDX (`Venta_Promedio_por_Cliente`):** asociada a `Fact Ventas`, con formato `$#,##0;($#,##0);$0`. Divide `Monto Neto` por `Recuento distinto Cliente SK` protegiendo contra división por cero mediante `IIF`.
- **Grupos de medidas complementarios (`DistinctCount`, formato `#,##0`):** `Clientes` (`Recuento distinto Cliente SK` sobre `Fact_Ventas`), `Dim Producto` (`Productos distintos`), `Dim Empleado` (`Recuento distinto Empleado SK`) y `Dim Sucursal` (`Recuento distinto Sucursal SK`). Los conteos calculados directamente sobre las tablas de dimensión consideran el miembro desconocido (`-1`).

`Venta_BK` se conserva como clave de negocio y se usa para calcular el recuento distinto de ventas, evitando agregarla como suma.

### Asociación de dimensiones

Las cinco dimensiones se relacionaron con el grupo de medidas `Fact Ventas` mediante relaciones regulares, utilizando las claves sustitutas que conectan la tabla de hechos con cada dimensión.

Esto permite analizar las medidas del cubo desde las distintas perspectivas descriptivas y temporales del modelo.

### Configuración de la dimensión Tiempo

La dimensión `Dim_Tiempo` permite realizar análisis por año, semestre, trimestre, mes, nombre de mes, fecha, día, día de semana y fin de semana.

No se definieron jerarquías personalizadas. Se conservaron los atributos temporales independientes y sus relaciones directas desde `Tiempo SK`, porque valores como Mes y Trimestre se repiten entre años y los intentos de jerarquía generaron problemas de configuración.

Para permitir la ordenación cronológica de los meses en las visualizaciones, el atributo `Mes` se configuró utilizando:

- **KeyColumns:** `Mes`
- **NameColumn:** `NombreMes`

De esta manera, el valor numérico del mes determina su orden, mientras que el nombre del mes es el valor mostrado al usuario. Esto permite visualizar los meses desde enero hasta diciembre en el orden esperado.

### Implementación y procesamiento

El proyecto SSAS se implementó en la instancia local de Analysis Services, creando la base de datos multidimensional `Albarran_OLAP`.

Posteriormente, se realizó el procesamiento completo (`Process Full`) de las cinco dimensiones y del cubo, cargando los datos desde el Data Warehouse y construyendo las estructuras necesarias para las consultas multidimensionales.

El procesamiento finalizó correctamente y sin errores.

### Validación del cubo

Se utilizó el Explorador del cubo de Visual Studio para validar las medidas y dimensiones mediante consultas multidimensionales.

Se realizaron consultas de análisis, entre ellas:

- Monto Neto por sucursal.
- Monto Neto por mes.
- Análisis temporal de ventas.
- Consultas combinando medidas y atributos de dimensiones.
- Validación de la disponibilidad de las medidas Cantidad y Recuento Fact Ventas.

Los resultados obtenidos permitieron comprobar el funcionamiento del cubo, la disponibilidad de las medidas y la aplicación de las dimensiones como filtros y agrupaciones.

---

## Dashboard Power BI - Fase 2

El repositorio contiene dos versiones equivalentes del dashboard:

- **`dashboard.pbix`:** utiliza una conexión dinámica (`Live Connection`) al cubo `Cubo_Ventas_Albarran` de la base `Albarran_OLAP` en la instancia local de Analysis Services; aprovecha directamente las medidas, formatos y cálculo MDX del cubo.
- **`dashboard_portable.pbix`:** versión autocontenida con datos importados, creada para garantizar portabilidad y revisión en equipos sin SSAS local disponible.

### Estructura y diseño visual

Ambos dashboards incorporan un tema personalizado acorde a la identidad de **Mueblería Albarrán** (paleta cálida en tonos nogal, crema y terracota), encabezado unificado por página, etiquetas de datos visibles, filtros desplegables en la barra superior (`Sucursal`, `Categoría` y `Trimestre` según vista) y cuatro páginas de análisis:

| Página | Tarjetas KPI | Visualizaciones principales |
|---|---|---|
| **Resumen General** | Monto Bruto, Descuentos, Monto Neto, N° de Ventas, Unidades Vendidas | Evolución mensual de ventas netas (orden cronológico enero–diciembre), ranking de productos por monto neto, ventas por día de la semana y ventas por trimestre (orden cronológico T1–T4). |
| **Clientes** | Clientes Únicos, Monto Neto, Venta Prom. / Cliente (Live) / Unidades (Portable), N° de Ventas | Ranking de clientes por monto neto, monto neto por rango etario y gráficos de anillo por estado civil y sexo. |
| **Productos** | Monto Neto, Unidades Vendidas, Precio Unit. Prom. (Live), Productos Distintos | Ranking de productos por monto neto y por unidades vendidas, ventas netas por categoría y tabla de detalle del catálogo. |
| **Empleados y Sucursales** | Monto Neto, Sucursales, Empleados, Unidades Vendidas | Comparación de monto neto y número de ventas por sucursal y por empleado. |

Para mayor detalle técnico sobre el cubo OLAP y los dashboards, revisar [docs/guia_olap_powerbi.md](docs/guia_olap_powerbi.md).

---

## Tecnologías utilizadas

- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- SQL Server Integration Services (SSIS).
- SQL Server Analysis Services (SSAS) Multidimensional.
- Visual Studio.
- Power BI Desktop.
- Git y GitHub.

---

## Estructura del repositorio

```text
CERTAMEN2-BI/
├── README.md
├── database/
│   ├── scripts/
│   └── backup/
├── docs/
│   ├── guia_olap_powerbi.md
│   ├── informe/
│   └── presentacion/
├── etl/
│   └── Carga_Dimensiones/
├── olap/
│   └── Albarran_OLAP/
│       └── Albarran_OLAP/
└── powerbi/
    ├── dashboard.pbix
    └── dashboard_portable.pbix
```

---

## Instrucciones de ejecución y revisión

1. Ejecutar `database/scripts/01_creacion_dw.sql` y `02_dim_tiempo.sql` en SQL Server para crear y preparar el Data Warehouse.
2. Configurar las conexiones del proyecto SSIS y ejecutar `Carga_Dimensiones.dtsx` desde Visual Studio.
3. Abrir el proyecto SSAS `Albarran_OLAP` en Visual Studio.
4. Revisar el origen de datos y verificar que las conexiones apunten a la instancia y base de datos correctas.
5. Implementar (`Deploy`) el proyecto multidimensional en Analysis Services.
6. Procesar las dimensiones y el cubo para cargar los datos.
7. Utilizar el Explorador del cubo para realizar consultas y validar las medidas.
8. Abrir el PBIX elegido en Power BI Desktop. Para `dashboard.pbix`, verificar la conexión a Analysis Services; actualizar los datos de `dashboard_portable.pbix` cuando corresponda.
9. Utilizar `database/scripts/03_validaciones.sql` para revisar la carga dimensional.

Las conexiones y propiedades del servidor pueden requerir ajustes al ejecutar el proyecto en otro equipo. Los respaldos disponibles se encuentran en `database/backup/`.

---

## Distribución de responsabilidades y aportes

- **Luis Sarzuri:** perfilamiento y revisión de los datos de origen, además de aportes a las cargas de dimensiones.
- **Matías Fernández Vargas:** estructura inicial del repositorio, documentación, enfoque Kimball, aportes al modelo dimensional y a `Dim_Tiempo`, además de refinamiento de formatos del cubo OLAP y rediseño visual de los dashboards en Power BI.
- **Matías Aguilera:** desarrollo y pruebas de cargas ETL, validaciones y conciliación, además del desarrollo del cubo OLAP y construcción base del dashboard en Power BI.

---

## Presentación

[Presentación del proyecto en Canva](https://canva.link/s5xqy9642af6sjh)
