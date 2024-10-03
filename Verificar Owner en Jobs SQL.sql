DECLARE @UsuBuscado1 NVARCHAR(50) = 'FL'
DECLARE @UsuBuscado2 NVARCHAR(50) = 'SANT'

-- Logins SQL
--
SELECT [name]
FROM master.sys.syslogins 
WHERE (name like '%' + @UsuBuscado1 + '%' or 
		name like '%' + @UsuBuscado2 + '%' )
ORDER BY [name]


-- Jobs SQL asociados al Login encontrados
--
SELECT DISTINCT
	S.name AS JobName
	, l.name AS JobOwner
	,case when (l.name like '%' + @UsuBuscado1 + '%' or 
				l.name like '%' + @UsuBuscado2 + '%' ) then 'SI' else '' end as Es_UsuBuscado
	,case when s.enabled = 1 then 'SI' else '' end as Job_habilitado
	,case when sj.job_id is not null then 'SI' else '' end as Job_con_Agendamiento
	,case when ss.enabled = 1 then 'SI' else '' end as Job_Agendamiento_Habilitado 

FROM msdb.dbo.sysjobs S
INNER JOIN master.sys.syslogins l ON s.owner_sid = l.sid
LEFT JOIN msdb.dbo.sysjobschedules SJ	ON S.job_id = SJ.job_id  
LEFT JOIN msdb.dbo.sysschedules SS		ON SS.schedule_id = SJ.schedule_id

WHERE (l.name like '%' + @UsuBuscado1 + '%' or 
		l.name like '%' + @UsuBuscado2 + '%' )

ORDER BY Es_UsuBuscado DESC, JobName


