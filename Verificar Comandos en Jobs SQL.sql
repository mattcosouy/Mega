DROP TABLE IF EXISTS #ComandosBuscados
SELECT *
INTO #ComandosBuscados
FROM (			SELECT '%' + 'sp_Central' + '%' Comando 
		UNION	SELECT '%' + 'sp_GetFromPBI' + '%' Comando 
		UNION	SELECT '%' + 'sp_EDI_NetOrder' + '%' Comando 
		UNION	SELECT '%' + 'sp_CreateFileNetOrder' + '%' Comando 
) c
-- SELECT * FROM #ComandosBuscados
		

SELECT DISTINCT
	S.name JobName
	,sst.step_id
	,sst.step_name
	,sst.subsystem
	,sst.command
	,sst.database_name
FROM msdb.dbo.sysjobs S
INNER JOIN msdb.dbo.sysjobsteps sst		ON S.job_id = sst.job_id  
INNER JOIN #ComandosBuscados cb			ON sst.command COLLATE SQL_Latin1_General_CP1_CI_AS LIKE cb.Comando COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN msdb.dbo.sysjobschedules SJ	ON S.job_id = SJ.job_id  
LEFT JOIN msdb.dbo.sysschedules SS		ON SS.schedule_id = SJ.schedule_id
WHERE s.enabled=1 -- Job habilitado = true
AND sj.job_id is not null -- job con agendamiento
AND ss.enabled=1 -- el agendamiento esta habilitado = true
--AND s.name in ('Ax2Sac','Ax4 DomRowPro Genera Archivos Tracking')
--AND s.name like '%SYSTEM_DATABASES%'
ORDER BY S.name, sst.step_id

