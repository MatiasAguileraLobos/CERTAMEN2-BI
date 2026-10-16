USE Albarran_DW;
GO

CREATE OR ALTER PROCEDURE dbo.sp_PoblarDimTiempo
    @FechaInicio DATE = '20170101',
    @FechaFin    DATE = '20171231'
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaInicio IS NULL
       OR @FechaFin IS NULL
       OR @FechaInicio > @FechaFin
    BEGIN
        THROW 50001, 'El rango de fechas no es valido.', 1;
    END;

    DECLARE @f DATE = @FechaInicio;
    DECLARE @DiaSemana INT;

    WHILE @f <= @FechaFin
    BEGIN
        SET @DiaSemana =
            (DATEDIFF(DAY, '19000101', @f) % 7) + 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Dim_Tiempo
            WHERE Tiempo_SK =
                YEAR(@f) * 10000
                + MONTH(@f) * 100
                + DAY(@f)
        )
        BEGIN
            INSERT INTO dbo.Dim_Tiempo (
                Tiempo_SK,
                Fecha,
                Anio,
                Semestre,
                Trimestre,
                Mes,
                NombreMes,
                Dia,
                DiaSemana,
                EsFinDeSemana
            )
            VALUES (
                YEAR(@f) * 10000
                    + MONTH(@f) * 100
                    + DAY(@f),
                @f,
                YEAR(@f),
                CASE WHEN MONTH(@f) <= 6 THEN 1 ELSE 2 END,
                DATEPART(QUARTER, @f),
                MONTH(@f),
                CASE MONTH(@f)
                    WHEN 1 THEN 'Enero'
                    WHEN 2 THEN 'Febrero'
                    WHEN 3 THEN 'Marzo'
                    WHEN 4 THEN 'Abril'
                    WHEN 5 THEN 'Mayo'
                    WHEN 6 THEN 'Junio'
                    WHEN 7 THEN 'Julio'
                    WHEN 8 THEN 'Agosto'
                    WHEN 9 THEN 'Septiembre'
                    WHEN 10 THEN 'Octubre'
                    WHEN 11 THEN 'Noviembre'
                    WHEN 12 THEN 'Diciembre'
                END,
                DAY(@f),
                CASE @DiaSemana
                    WHEN 1 THEN 'Lunes'
                    WHEN 2 THEN 'Martes'
                    WHEN 3 THEN 'Miercoles'
                    WHEN 4 THEN 'Jueves'
                    WHEN 5 THEN 'Viernes'
                    WHEN 6 THEN 'Sabado'
                    WHEN 7 THEN 'Domingo'
                END,
                CASE WHEN @DiaSemana IN (6, 7)
                     THEN 1 ELSE 0 END
            );
        END;

        SET @f = DATEADD(DAY, 1, @f);
    END;
END;
GO

EXEC dbo.sp_PoblarDimTiempo;
GO