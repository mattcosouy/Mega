/*This query uses sysjobs view to get the list of all 
     RUNNING JOBS
NOTE: CAN BE MODIFIED AS NEEDED.
*/
 
 
SELECT
    job.name as Nombre_del_JOB, --Nombre del job
    job.job_id as ID_del_JOB, --ID del job
    job.originating_server as Servidor, --Servidor de origen
    activity.run_requested_date as Inicio_De_Ejecucion,--Inicio de ejecucion del job
activity.stop_execution_date as Fin_De_Ejecucion,--Fein de la ejecucion del job
 
/*
EL DATEDIFF NECCESITA 3 ARGUMENTOS:
--> datepart: Es la unidad en la que el DATEDIFF va a devolver la diferencia entre la STARTDATE Y LA ENDDATE.
--> startdate:Fecha inical.
--> enddate:fecha final.
*/
    DATEDIFF(/*datepart*/n, 
/*startdate*/activity.run_requested_date, 
/*enddate*//*stop_execution_date*/ GETDATE() ) as Tiempo_Transcurrido,
CASE
WHEN activity.start_execution_date IS NULL THEN 'Not running'
WHEN activity.start_execution_date IS NOT NULL AND activity.stop_execution_date IS NULL THEN 'Running'
WHEN activity.start_execution_date IS NOT NULL AND activity.stop_execution_date IS NOT NULL THEN 'Not running'
END AS 'RunStatus'
 
/*
NOTA: 
Para sacar los segundos que pasaron desde que se 
empezo a ejecutar el JOB y la fecha y hora actual
solo hay que cambiar el ENDDATE a GETDATE() 
y el IS NOT NULL a IS NULL en el stop_execution_date del WHERE.
*/
 
 
FROM 
--vista de la tabla dbo.sysjobs almacenada en MSDB.
    msdb.dbo.sysjobs_view job
JOIN
    msdb.dbo.sysjobactivity activity
ON 
    job.job_id = activity.job_id
JOIN
    msdb.dbo.syssessions sess
ON
    sess.session_id = activity.session_id
JOIN
(
    SELECT
        MAX( agent_start_date ) AS max_agent_start_date
    FROM
        msdb.dbo.syssessions
) sess_max
ON
    sess.agent_start_date = sess_max.max_agent_start_date
 
WHERE run_requested_date IS NOT NULL 
AND stop_execution_date IS NOT NULL 
--AND job.name like 'Nombre del job'
/*
run_requested_date: "Date and time that the job was requested to run".
stop_execution_date: "Date and time that the job finished running".
 
SI LA FECHA EN LA QUE EL JOB FUE SOLICITADO NO ES NULA Y LA 
FECHA DE FINALIZACION DE EJECUCION ES NULA, SIGNIFICA QUE ESTA SIENDO EJECUTADO.
NOTA: SE PUEDE AÑADIR NOMBRES ESPECIFICOS AL WHERE PARA BUSCAR UN JOB EN PARTICULAR.
*/
