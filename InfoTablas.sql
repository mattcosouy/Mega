SELECT
	--xinfo.[Server]
	--,xinfo.[Instance]
	--,xinfo.[Database]
	SCHEMA_NAME(t.schema_id)	AS [Schema]
	,t.name						AS [Table]
	,xRowCount.RowsCount
--	,c.column_id
	,c.name						AS [Column]
	,ty.name					AS [DataType]
	,CONVERT(VARCHAR,
		CASE
			WHEN (ty.name like '%char%' OR ty.name = 'sysname')
				THEN CONVERT(VARCHAR,c.max_length)
			WHEN c.system_type_id IN ('108','106')
				THEN CONVERT(VARCHAR,c.precision) +','+ CONVERT(VARCHAR,c.scale) -- numeric, decimal
			WHEN ty.name like '%date%'
				THEN ''
			WHEN ty.name IN ('int','bit','uniqueidentifier','image','float')
				THEN ''
		ELSE '' END
	) AS [Width]
	--,c.max_length
	--,c.precision
	--,c.scale
	--,c.system_type_id
FROM sys.tables AS t
INNER JOIN sys.columns c	ON t.OBJECT_ID = c.OBJECT_ID
LEFT JOIN sys.types ty		ON c.system_type_id = ty.user_type_id
LEFT JOIN (
	SELECT
		@@servername	AS [Server]
		,@@servicename	AS [Instance]
		,DB_NAME()		AS [Database]
) xinfo 
	ON 1=1
LEFT JOIN (
	SELECT 
		SCHEMA_NAME(sOBJ.schema_id) AS SchemaName
		,sOBJ.name					AS TableName
		,SUM(sPTN.Rows)				AS RowsCount
	FROM sys.objects AS sOBJ
	INNER JOIN sys.partitions AS sPTN
		ON sOBJ.object_id = sPTN.object_id
	WHERE	sOBJ.type = 'U'
	AND sOBJ.is_ms_shipped = 0x0
	AND index_id < 2 -- 0:Heap, 1:Clustered
	GROUP BY sOBJ.schema_id , sOBJ.name
) xRowCount
	ON  SCHEMA_NAME(t.schema_id) = SchemaName
	AND t.name = TableName
WHERE t.type = 'U' -- USER_TABLE
--* AND t.name = 'INVENTDIM'
and c.name like '%userid%'
AND xRowCount.RowsCount > 0
ORDER BY [Schema], [Table], c.column_id


/*
SELECT scui.EMPLID, scui.UserId, ui.NAME, *
FROM SYSCOMPANYUSERINFO scui
INNER JOIN UserInfo ui
ON scui.USERID = ui.ID
WHERE scui.EmplId = '1693'

SELECT ID, networkAlias, *
FROM UserInfo 
*/
