/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/

/*
	-- Archivos importantos con Status = Pendiente (0)
	-- Verificaciones:
	--    Situaci�n 1, si el archivo no tiene l�neas, lo elimino sin m�s.
	--    Situaci�n 2, si el archivo tiene pocas l�neas, menos de 20, le doy procesar ahora as� como est�.
	--    Situaci�n 3, si el archivo tiene muchas l�neas, m�s de 20, le doy procesar as� como est� pero despu�s de las 15 hrs.
	--    Situaci�n 4, si lo piden por necesidad de Negocio, que tenga 1 ticket, hay que coordinar con Depo Meca (Ana) y Depo SEL (Nico x2) que nos den una ventana de tiempo para evitar bloqueos, y le doy procesar.
*/

SELECT 'Archivos importantos con Status = Pendiente (0) .............................................................................................' Control_Actual


DECLARE @MaxCantLineas INT = 20

DROP TABLE IF EXISTS #ArchivosImportados
SELECT 
	bps.DATAAREAID, 
	bps.BULKPROCESSSESSIONID, 
	'Pendiente' AS Status,
	bps.CREATEDDATETIME, 
	bps.CREATEDBY, 
	bps.FILENAME, 
	CASE WHEN bpi.CantLineas IS NULL THEN 0 ELSE bpi.CantLineas END AS CantLineas

INTO #ArchivosImportados

FROM BulkProcessSession_MPH bps
LEFT JOIN (
	SELECT DATAAREAID, BULKPROCESSSESSIONID, COUNT(*) CantLineas
	FROM BulkProcessImport_MPH
	GROUP BY DATAAREAID, BULKPROCESSSESSIONID
) bpi
	ON bps.DATAAREAID = bpi.DATAAREAID AND bps.BULKPROCESSSESSIONID = bpi.BULKPROCESSSESSIONID
WHERE bps.Status = 0  -- 0 Pendiente , 1 Erroneo, 2 Ignorado, 3 Validado, 4 Terminado
AND bps.CREATEDDATETIME 
		>= -- '2021-01-01' -- ejemplo de funcionamiento
			CASE DATEPART(WEEKDAY, GETDATE())
				WHEN 3 THEN CONVERT(DATE, GETDATE())					-- 3 = Tuesday
				WHEN 4 THEN CONVERT(DATE, GETDATE())					-- 4 = Wednesday
				WHEN 5 THEN CONVERT(DATE, GETDATE())					-- 5 = Thursday
				WHEN 6 THEN CONVERT(DATE, GETDATE())					-- 6 = Friday
				WHEN 2 THEN DATEADD(day, -3, CONVERT(DATE, GETDATE()))	-- 2 = Monday
				WHEN 1 THEN DATEADD(day, -2, CONVERT(DATE, GETDATE()))	-- 1 = Sunday
				WHEN 7 THEN DATEADD(day, -1, CONVERT(DATE, GETDATE()))	-- 7 = Saturday
			END 
ORDER BY DATAAREAID, BULKPROCESSSESSIONID 

IF (@@ROWCOUNT > 0)
BEGIN

	-- Situaci�n 1. Elimino aquellos cuya CantLineas sea = 0
	--
	SELECT 'Situaci�n 1 (DELETE)' x, ai.*, '--->' xx, bps.*
	-- DELETE bps
	FROM BulkProcessSession_MPH bps
	INNER JOIN #ArchivosImportados ai
		ON bps.DATAAREAID = ai.DATAAREAID AND bps.BULKPROCESSSESSIONID = ai.BULKPROCESSSESSIONID 
	WHERE ai.CantLineas = 0

	-- Situaci�n 2. si el archivo tiene pocas l�neas, menos de 20, le doy procesar ahora as� como est�.
	--
	SELECT 'Situaci�n 2 (Procesar)' x, *
	FROM #ArchivosImportados
	WHERE CantLineas > 0 AND CantLineas <= @MaxCantLineas 

	-- Situaci�n 3, si el archivo tiene muchas l�neas, m�s de 20, le doy procesar as� como est� pero despu�s de las 15 hrs.Situaci�n 2. si el archivo tiene pocas l�neas, menos de 20, le doy procesar ahora as� como est�.
	--
	SELECT 'Situaci�n 3 (Procesar despu�s 15:00)' x, *
	FROM #ArchivosImportados
	WHERE CantLineas > @MaxCantLineas 

END

/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/

/*
	-- Archivos importantos con Status = Validado (3)
	-- Verificacion de existencias, �nicamente hay que confirmar a los usuarios 120/125 de ello.
*/

SELECT 'Archivos importantos con Status = Validado (3)...............................................................................................' Control_Actual

SELECT 
	DATAAREAID												AS Empresa, 
	BulkProcessSessionId									AS Sesion_de_importacion, 
	'Validado'												AS Status,
	[FileName]												AS Nombre_de_archivo, 
	createdBy												AS Creado_por, 
	createdDateTime											AS Fecha_y_hora_creacion, 
	dbo.fc_ENUM_BulkProcessFormat(BulkProcessFormat)		AS Formato,
	CASE Groupping WHEN 1 THEN 'Check' ELSE '' END			AS Agrupar,
	CASE GroupByExtOrderId WHEN 1 THEN 'Check' ELSE '' END	AS Agrupar_por_referencia_cliente

FROM BulkProcessSession_MPH
WHERE Status = 3
AND createdDateTime 
		>= -- '2023-05-01' -- ejemplo de funcionamiento
			CASE DATEPART(WEEKDAY, GETDATE())
				WHEN 3 THEN CONVERT(DATE, GETDATE())					-- 3 = Tuesday
				WHEN 4 THEN CONVERT(DATE, GETDATE())					-- 4 = Wednesday
				WHEN 5 THEN CONVERT(DATE, GETDATE())					-- 5 = Thursday
				WHEN 6 THEN CONVERT(DATE, GETDATE())					-- 6 = Friday
				WHEN 2 THEN DATEADD(day, -3, CONVERT(DATE, GETDATE()))	-- 2 = Monday
				WHEN 1 THEN DATEADD(day, -2, CONVERT(DATE, GETDATE()))	-- 1 = Sunday
				WHEN 7 THEN DATEADD(day, -1, CONVERT(DATE, GETDATE()))	-- 7 = Saturday
			END 
ORDER BY DataAreaID, BulkProcessSessionId 


IF (@@ROWCOUNT > 0)
	SELECT 'Debe notificar a los Usuarios (*) por email de los archivos previamente detallados.' Resultado
ELSE
	SELECT 'OK .. ' + CONVERT(VARCHAR, @@ROWCOUNT) Resultado



-- emails de los usuarios anteriores
--
--SELECT Creado_por, Email
--FROM #ArchivosImportantosValidado aiv
--LEFT JOIN SysUserInfo sui ON aiv.Creado_por = sui.id


/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/

/*
	-- Trabajos por lotes con Estado = En ejecuci�n (2)
	-- Verificacion de trabajos corriendo actualmente, hay que confirmar que el nro no est� constantemente en 8 (l�mite 
	--   m�ximo de trabajos por lotes corriendo en paralelo).
*/

SELECT 'Trabajos por lotes con Estado = En ejecuci�n (2).............................................................................................' Control_Actual

SELECT TOP 100 
	COMPANY, 
	CAPTION, 
	'En ejecuci�n' AS STATUS,
	ORIGSTARTDATETIME, 
	CREATEDBY

FROM BatchJob
WHERE Status = 2 -- 0 Retendio, 1 En espera, 2 En ejecuci�n, 3 Error, 4 Terminado
AND ORIGSTARTDATETIME >= CONVERT(DATE, GETDATE())
ORDER BY COMPANY, CAPTION

IF (@@ROWCOUNT > 8)
	SELECT 'MAXIMO ALCANZADO !!!'
ELSE
	IF (@@ROWCOUNT > 5)
		SELECT 'WARNING .. pr�ximo a alcanzar el m�ximo !!' Resultado
	ELSE
		SELECT 'OK .. ' + CONVERT(VARCHAR, @@ROWCOUNT) Resultado


/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/