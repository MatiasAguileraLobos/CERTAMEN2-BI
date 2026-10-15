USE master;
GO

-- 1. Crear la base de datos si no existe.
IF DB_ID(N'Albarran_DW') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE Albarran_DW;');
END;
GO

USE Albarran_DW;
GO

-- 2. Evitar conflictos con un modelo ya creado.
IF OBJECT_ID(N'dbo.Dim_Tiempo', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.Dim_Cliente', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.Dim_Empleado', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.Dim_Producto', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.Dim_Sucursal', N'U') IS NOT NULL
   OR OBJECT_ID(N'dbo.Fact_Ventas', N'U') IS NOT NULL
BEGIN
    THROW 50002,
        'Ya existen tablas del modelo. Revise la base antes de ejecutar este script.',
        1;
END;
GO

/* ============ DIMENSIONES ============ */

CREATE TABLE dbo.Dim_Tiempo (
    Tiempo_SK       INT PRIMARY KEY, -- YYYYMMDD
    Fecha           DATE NOT NULL,
    Anio            INT NOT NULL,
    Semestre        TINYINT NOT NULL,
    Trimestre       TINYINT NOT NULL,
    Mes             TINYINT NOT NULL,
    NombreMes       VARCHAR(20) NOT NULL,
    Dia             TINYINT NOT NULL,
    DiaSemana       VARCHAR(20) NOT NULL,
    EsFinDeSemana   BIT NOT NULL
);
GO

CREATE TABLE dbo.Dim_Cliente (
    Cliente_SK      INT IDENTITY(1,1) PRIMARY KEY,
    Cliente_BK      INT NULL,
    NombreCompleto  VARCHAR(150) NULL,
    Sexo            CHAR(1) NULL,
    FechaNacimiento DATE NULL,
    EstadoCivil     VARCHAR(20) NULL,
    RangoEtario     VARCHAR(20) NULL,
    EsDesconocido   BIT NOT NULL
        CONSTRAINT DF_Dim_Cliente_Desconocido DEFAULT 0,
    FechaCarga      DATETIME NOT NULL
        CONSTRAINT DF_Dim_Cliente_FechaCarga DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL
        CONSTRAINT DF_Dim_Cliente_Origen DEFAULT 'OLTP_Albarran',
    UsuarioCarga    VARCHAR(128) NOT NULL
        CONSTRAINT DF_Dim_Cliente_Usuario DEFAULT SUSER_SNAME()
);
GO

CREATE TABLE dbo.Dim_Empleado (
    Empleado_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Empleado_BK     INT NULL,
    NombreCompleto  VARCHAR(150) NULL,
    Cargo           VARCHAR(100) NULL,
    FechaContrato   DATE NULL,
    SueldoBase      DECIMAL(12,2) NULL,
    EsDesconocido   BIT NOT NULL
        CONSTRAINT DF_Dim_Empleado_Desconocido DEFAULT 0,
    FechaCarga      DATETIME NOT NULL
        CONSTRAINT DF_Dim_Empleado_FechaCarga DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL
        CONSTRAINT DF_Dim_Empleado_Origen DEFAULT 'OLTP_Albarran',
    UsuarioCarga    VARCHAR(128) NOT NULL
        CONSTRAINT DF_Dim_Empleado_Usuario DEFAULT SUSER_SNAME()
);
GO

CREATE TABLE dbo.Dim_Producto (
    Producto_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Producto_BK     INT NULL,
    NombreProducto  VARCHAR(100) NULL,
    Descripcion     VARCHAR(255) NULL,
    Categoria       VARCHAR(100) NULL,
    PrecioLista     DECIMAL(12,2) NULL,
    EsDesconocido   BIT NOT NULL
        CONSTRAINT DF_Dim_Producto_Desconocido DEFAULT 0,
    FechaCarga      DATETIME NOT NULL
        CONSTRAINT DF_Dim_Producto_FechaCarga DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL
        CONSTRAINT DF_Dim_Producto_Origen DEFAULT 'OLTP_Albarran',
    UsuarioCarga    VARCHAR(128) NOT NULL
        CONSTRAINT DF_Dim_Producto_Usuario DEFAULT SUSER_SNAME()
);
GO

CREATE TABLE dbo.Dim_Sucursal (
    Sucursal_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Sucursal_BK     INT NULL,
    NombreSucursal  VARCHAR(100) NULL,
    Comuna          VARCHAR(100) NULL,
    EsDesconocido   BIT NOT NULL
        CONSTRAINT DF_Dim_Sucursal_Desconocido DEFAULT 0,
    FechaCarga      DATETIME NOT NULL
        CONSTRAINT DF_Dim_Sucursal_FechaCarga DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL
        CONSTRAINT DF_Dim_Sucursal_Origen DEFAULT 'OLTP_Albarran',
    UsuarioCarga    VARCHAR(128) NOT NULL
        CONSTRAINT DF_Dim_Sucursal_Usuario DEFAULT SUSER_SNAME()
);
GO

/* ============ TABLA DE HECHOS ============ */

CREATE TABLE dbo.Fact_Ventas (
    Venta_SK         BIGINT IDENTITY(1,1) PRIMARY KEY,
    Tiempo_SK        INT NOT NULL,
    Cliente_SK       INT NOT NULL,
    Empleado_SK      INT NOT NULL,
    Producto_SK      INT NOT NULL,
    Sucursal_SK      INT NOT NULL,
    Venta_BK         INT NOT NULL,
    TipoDocumento    VARCHAR(50) NULL,
    NumeroDocumento  VARCHAR(50) NULL,
    Cantidad         INT NOT NULL,
    PrecioUnitario   DECIMAL(12,2) NOT NULL,
    MontoBruto       DECIMAL(12,2) NOT NULL,
    MontoDescuento   DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Fact_Ventas_Descuento DEFAULT 0,
    MontoNeto        DECIMAL(12,2) NOT NULL,
    FechaCarga       DATETIME NOT NULL
        CONSTRAINT DF_Fact_Ventas_FechaCarga DEFAULT GETDATE(),
    OrigenSistema    VARCHAR(50) NOT NULL
        CONSTRAINT DF_Fact_Ventas_Origen DEFAULT 'OLTP_Albarran',
    UsuarioCarga     VARCHAR(128) NOT NULL
        CONSTRAINT DF_Fact_Ventas_Usuario DEFAULT SUSER_SNAME(),

    CONSTRAINT FK_Fact_Ventas_Tiempo
        FOREIGN KEY (Tiempo_SK) REFERENCES dbo.Dim_Tiempo(Tiempo_SK),
    CONSTRAINT FK_Fact_Ventas_Cliente
        FOREIGN KEY (Cliente_SK) REFERENCES dbo.Dim_Cliente(Cliente_SK),
    CONSTRAINT FK_Fact_Ventas_Empleado
        FOREIGN KEY (Empleado_SK) REFERENCES dbo.Dim_Empleado(Empleado_SK),
    CONSTRAINT FK_Fact_Ventas_Producto
        FOREIGN KEY (Producto_SK) REFERENCES dbo.Dim_Producto(Producto_SK),
    CONSTRAINT FK_Fact_Ventas_Sucursal
        FOREIGN KEY (Sucursal_SK) REFERENCES dbo.Dim_Sucursal(Sucursal_SK)
);
GO

/* ============ MIEMBROS DESCONOCIDOS ============ */

SET IDENTITY_INSERT dbo.Dim_Cliente ON;
INSERT INTO dbo.Dim_Cliente
    (Cliente_SK, Cliente_BK, NombreCompleto, EsDesconocido)
VALUES
    (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT dbo.Dim_Cliente OFF;
GO

SET IDENTITY_INSERT dbo.Dim_Empleado ON;
INSERT INTO dbo.Dim_Empleado
    (Empleado_SK, Empleado_BK, NombreCompleto, EsDesconocido)
VALUES
    (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT dbo.Dim_Empleado OFF;
GO

SET IDENTITY_INSERT dbo.Dim_Producto ON;
INSERT INTO dbo.Dim_Producto
    (Producto_SK, Producto_BK, NombreProducto, EsDesconocido)
VALUES
    (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT dbo.Dim_Producto OFF;
GO

SET IDENTITY_INSERT dbo.Dim_Sucursal ON;
INSERT INTO dbo.Dim_Sucursal
    (Sucursal_SK, Sucursal_BK, NombreSucursal, EsDesconocido)
VALUES
    (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT dbo.Dim_Sucursal OFF;
GO
