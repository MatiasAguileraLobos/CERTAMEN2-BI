USE Albarran_DW;
GO

CREATE OR ALTER PROCEDURE sp_PoblarDimTiempo
    @FechaInicio DATE = '2020-01-01',
    @FechaFin    DATE = '2030-12-31'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = @FechaInicio;

    WHILE @f <= @FechaFin
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Dim_Tiempo WHERE Tiempo_SK = YEAR(@f)*10000 + MONTH(@f)*100 + DAY(@f))
        INSERT INTO Dim_Tiempo
        SELECT
            YEAR(@f)*10000 + MONTH(@f)*100 + DAY(@f),
            @f,
            YEAR(@f),
            CASE WHEN MONTH(@f) <= 6 THEN 1 ELSE 2 END,
            DATEPART(QUARTER, @f),
            MONTH(@f),
            DATENAME(MONTH, @f),
            DAY(@f),
            DATENAME(WEEKDAY, @f),
            CASE WHEN DATEPART(WEEKDAY, @f) IN (1,7) THEN 1 ELSE 0 END;

        SET @f = DATEADD(DAY, 1, @f);
    END
END
GO

EXEC sp_PoblarDimTiempo;