SELECT
    job.name                             AS Nombre_del_JOB,         --Nombre del job
    job.job_id                             AS ID_del_JOB,             --ID del job
    job.originating_server                 AS Servidor,             --Servidor de origen
    activity.run_requested_date         AS Inicio_De_Ejecucion,    --Inicio de ejecucion del job
    activity.stop_execution_date         AS Fin_De_Ejecucion,    --Fin de la ejecucion del job

 

    
    DATEDIFF(/*datepart*/n, 
             /*startdate*/activity.run_requested_date, 
             /*enddate*//*stop_execution_date*/ GETDATE() ) as Tiempo_Transcurrido,
    CASE
        WHEN activity.start_execution_date IS NULL THEN 'Not running'
        WHEN activity.start_execution_date IS NOT NULL AND activity.stop_execution_date IS NULL THEN 'Running'
        WHEN activity.start_execution_date IS NOT NULL AND activity.stop_execution_date IS NOT NULL THEN 'Not running'
    END AS 'RunStatus'



FROM 
--vista de la tabla dbo.sysjobs almacenada en MSDB.
    msdb.dbo.sysjobs_view job 
    JOIN msdb.dbo.sysjobactivity activity ON job.job_id = activity.job_id

    JOIN msdb.dbo.syssessions sess           ON sess.session_id = activity.session_id
    JOIN
    (
        SELECT
            MAX( agent_start_date ) AS max_agent_start_date
        FROM
            msdb.dbo.syssessions
    )     sess_max
    ON sess.agent_start_date = sess_max.max_agent_start_date

 

WHERE     run_requested_date      IS NOT NULL 
      AND stop_execution_date IS NULL  --IS NULL PARA VER LOS JOBS CORRIENDO EN EL MOMENTO.
    --AND job.name like 'Backup diario'