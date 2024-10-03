DECLARE
	@sp_name VARCHAR(200) = NULL,
	@sp_code VARCHAR(200) = 'sp_send_dbmail' -- NULL

SELECT TOP 1000
	@@SERVERNAME	AS Instancia,
	DB_NAME()		AS DB,
	o.name			AS sp_name,
	m.definition	AS sp_code
FROM sys.objects o
INNER JOIN sys.sql_modules m
	ON m.object_id = o.object_id
WHERE o.type = 'P'
AND (ISNULL(@sp_name,'') = '' OR  o.name		LIKE '%'+@sp_name+'%')
AND (ISNULL(@sp_code,'') = '' OR  m.definition LIKE '%'+@sp_code+'%')
ORDER BY sp_name