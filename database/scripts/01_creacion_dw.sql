CREATE DATABASE Albarran_DW;
GO
USE Albarran_DW;
GO

/* ============ DIMENSIONES ============ */

CREATE TABLE Dim_Tiempo (
    Tiempo_SK       INT PRIMARY KEY,          -- YYYYMMDD
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

CREATE TABLE Dim_Cliente (
    Cliente_SK      INT IDENTITY(1,1) PRIMARY KEY,
    Cliente_BK      INT NULL,
    NombreCompleto  VARCHAR(150) NULL,
    Sexo            CHAR(1) NULL,
    FechaNacimiento DATE NULL,
    EstadoCivil     VARCHAR(20) NULL,
    RangoEtario     VARCHAR(20) NULL,
    EsDesconocido   BIT NOT NULL DEFAULT 0,
    FechaCarga      DATETIME NOT NULL DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL DEFAULT 'OLTP_Albarran'
);

CREATE TABLE Dim_Empleado (
    Empleado_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Empleado_BK     INT NULL,
    NombreCompleto  VARCHAR(150) NULL,
    Cargo           VARCHAR(100) NULL,
    FechaContrato   DATE NULL,
    SueldoBase      DECIMAL(12,2) NULL,
    EsDesconocido   BIT NOT NULL DEFAULT 0,
    FechaCarga      DATETIME NOT NULL DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL DEFAULT 'OLTP_Albarran'
);

CREATE TABLE Dim_Producto (
    Producto_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Producto_BK     INT NULL,
    NombreProducto  VARCHAR(100) NULL,
    Descripcion     VARCHAR(255) NULL,
    Categoria       VARCHAR(100) NULL,
    PrecioLista     DECIMAL(12,2) NULL,
    EsDesconocido   BIT NOT NULL DEFAULT 0,
    FechaCarga      DATETIME NOT NULL DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL DEFAULT 'OLTP_Albarran'
);

CREATE TABLE Dim_Sucursal (
    Sucursal_SK     INT IDENTITY(1,1) PRIMARY KEY,
    Sucursal_BK     INT NULL,
    NombreSucursal  VARCHAR(100) NULL,
    Comuna          VARCHAR(100) NULL,
    EsDesconocido   BIT NOT NULL DEFAULT 0,
    FechaCarga      DATETIME NOT NULL DEFAULT GETDATE(),
    FechaUltimaAct  DATETIME NULL,
    OrigenSistema   VARCHAR(50) NOT NULL DEFAULT 'OLTP_Albarran'
);

/* ============ TABLA DE HECHOS ============ */

CREATE TABLE Fact_Ventas (
    Venta_SK         BIGINT IDENTITY(1,1) PRIMARY KEY,
    Tiempo_SK        INT NOT NULL FOREIGN KEY REFERENCES Dim_Tiempo(Tiempo_SK),
    Cliente_SK       INT NOT NULL FOREIGN KEY REFERENCES Dim_Cliente(Cliente_SK),
    Empleado_SK      INT NOT NULL FOREIGN KEY REFERENCES Dim_Empleado(Empleado_SK),
    Producto_SK      INT NOT NULL FOREIGN KEY REFERENCES Dim_Producto(Producto_SK),
    Sucursal_SK      INT NOT NULL FOREIGN KEY REFERENCES Dim_Sucursal(Sucursal_SK),
    Venta_BK         INT NOT NULL,
    TipoDocumento    VARCHAR(50) NULL,
    NumeroDocumento  VARCHAR(50) NULL,
    Cantidad         INT NOT NULL,
    PrecioUnitario   DECIMAL(12,2) NOT NULL,
    MontoBruto       DECIMAL(12,2) NOT NULL,
    MontoDescuento   DECIMAL(12,2) NOT NULL DEFAULT 0,
    MontoNeto        DECIMAL(12,2) NOT NULL,
    FechaCarga       DATETIME NOT NULL DEFAULT GETDATE(),
    OrigenSistema    VARCHAR(50) NOT NULL DEFAULT 'OLTP_Albarran'
);
GO

/* ============ UNKNOWN MEMBERS (fila -1) ============ */

SET IDENTITY_INSERT Dim_Cliente ON;
INSERT INTO Dim_Cliente (Cliente_SK, Cliente_BK, NombreCompleto, EsDesconocido)
VALUES (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT Dim_Cliente OFF;

SET IDENTITY_INSERT Dim_Empleado ON;
INSERT INTO Dim_Empleado (Empleado_SK, Empleado_BK, NombreCompleto, EsDesconocido)
VALUES (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT Dim_Empleado OFF;

SET IDENTITY_INSERT Dim_Producto ON;
INSERT INTO Dim_Producto (Producto_SK, Producto_BK, NombreProducto, EsDesconocido)
VALUES (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT Dim_Producto OFF;

SET IDENTITY_INSERT Dim_Sucursal ON;
INSERT INTO Dim_Sucursal (Sucursal_SK, Sucursal_BK, NombreSucursal, EsDesconocido)
VALUES (-1, NULL, 'DESCONOCIDO', 1);
SET IDENTITY_INSERT Dim_Sucursal OFF;
GO