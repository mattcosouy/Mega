
DROP TABLE IF EXISTS #Datos
--
CREATE TABLE #Datos(
	_Server			VARCHAR(100),
	_DataBase		VARCHAR(100),
	_Table			VARCHAR(100),
	_Orden			VARCHAR(10),
	Cant_Rows		INT,
	Cant_FechaSync	INT,
	minFechaSync	DATETIME,
	maxFechaSync	DATETIME
)

DECLARE 
	@Table	VARCHAR(100),
	@Orden	VARCHAR(10),
	@Query	NVARCHAR(1000)


-- 0. universo de tablas para los que se recolectaran los datos de control
--
DECLARE Table_cursor CURSOR FOR 
SELECT [ObjetoId] _Table, CONVERT(VARCHAR(10), [Orden]) _Orden
--FROM [dbo].[PBI_Indice] -- si corre desde Azure
FROM [AZURE OLAP].[AxDomRowOLAP].[dbo].[PBI_Indice] -- si corre desde OnPrem, dado que esta tabla no existe
WHERE UPPER(Activo) = 'SI' --and [ObjetoId] = 'SalesPriceAgreementStaging'
ORDER BY Orden


OPEN Table_cursor  
FETCH NEXT FROM Table_cursor INTO @Table, @Orden
--
WHILE @@FETCH_STATUS = 0  
BEGIN  

	-- 1. cargo la cantidad de rows q tiene la tabla
	--
	SET @Query = 
		'INSERT INTO #Datos
		SELECT @@SERVERNAME _Server, DB_NAME() _DataBase, ''' + @Table + '''_Table, ''' + @Orden + ''' _Orden, MAX(Cant_Rows) Cant_Rows, MAX(Cant_FechaSync) Cant_FechaSync, MAX(minFechaSync) minFechaSync, MAX(maxFechaSync) maxFechaSync
		FROM (
			SELECT COUNT(*) Cant_Rows, 0 Cant_FechaSync, ''1900-01-01'' minFechaSync, ''1900-01-01'' maxFechaSync
			FROM ' + @Table + '
		) x'    
	-- PRINT @Table + ' Q1 >> ' + @Query
	EXECUTE sp_executesql @Query

	-- 2. si llegase a existir el campo FechaSync en la tabla, se cargaran estos datos; en caso de q no exista ver <3.>
	--
	SET @Query = 
		'BEGIN TRY
			UPDATE d
			SET
				Cant_FechaSync = xx.Cant_FechaSync, 
				minFechaSync = xx.minFechaSync, 
				maxFechaSync = xx.maxFechaSync
			FROM #Datos d
			INNER JOIN (
				SELECT ''' + @Table + ''' _Table, COUNT(*) Cant_FechaSync, MIN(FechaSync) minFechaSync, MAX(FechaSync) maxFechaSync
				FROM ( 
					SELECT DISTINCT FechaSync
					FROM ' + @Table + '
				) x
			) xx
			ON d._Table = xx._Table
		END TRY
		BEGIN CATCH
		END CATCH'
	-- PRINT @Table + ' Q2 >> ' + @Query
	EXECUTE sp_executesql @Query

	FETCH NEXT FROM Table_cursor INTO @Table, @Orden 
END 

CLOSE Table_cursor  
DEALLOCATE Table_cursor 

-- 3. en los casos que no exista el campo FechaSync en la tabla, se actualizan estos datos con NULL
--
UPDATE d
SET
	Cant_FechaSync = NULL, 
	minFechaSync = NULL, 
	maxFechaSync = NULL
FROM #Datos d
WHERE Cant_FechaSync = 0 
AND ( (ISNULL(minFechaSync, '1900-01-01 00:00:00.000') = '1900-01-01 00:00:00.000') OR
	  (ISNULL(maxFechaSync, '1900-01-01 00:00:00.000') = '1900-01-01 00:00:00.000') 
	)

/*
	Interpretacion de los datos resultantes segun Cant_Rows y Cant_FechaSync:
		- #1: Cant_Rows >= 0 y Cant_FechaSync >= 0 .... situacion normal
		- #2: Cant_Rows >= 0 y Cant_FechaSync = NULL .. tabla posee de 0 a n rows pero no existe el campo FechaSync
*/

SELECT *
FROM #Datos
--where Cant_Rows > 0
--and isnull(Cant_FechaSync,0) = 0
ORDER BY CONVERT(INT,_Orden)
