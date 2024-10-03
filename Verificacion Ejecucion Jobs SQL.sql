--DROP TABLE IF EXISTS #ComandosBuscados
--SELECT *
--INTO #ComandosBuscados
--FROM (			SELECT '%' + 'sp_Central' + '%' Comando 
--		UNION	SELECT '%' + 'sp_GetFromPBI' + '%' Comando 
--		UNION	SELECT '%' + 'sp_EDI_NetOrder' + '%' Comando 
--		UNION	SELECT '%' + 'sp_CreateFileNetOrder' + '%' Comando 
--) c
---- SELECT * FROM #ComandosBuscados
		
DECLARE
	@JobName		VARCHAR(100),
	@FechaDesde		DATETIME,
	@FechaHasta		DATETIME,
	@SoloConError	CHAR(1)

SET @JobName	  = NULL -- 'sp_Central A/F (AxDomRowOLAP)' -- NULL 
SET @FechaDesde   = '2022-08-17' -- NULL 
SET @FechaHasta   = NULL
SET @SoloConError = 'N'

IF (@FechaDesde IS NULL)
	SET @FechaDesde = (SELECT CONVERT(VARCHAR,GETDATE()-1,23)) -- formato: yyyy-mm-dd
IF (@SoloConError IS NULL)
	SET @SoloConError = 'S' -- S con error

SELECT @JobName JobName, @FechaDesde FechaDesde, @FechaHasta FechaHasta, @SoloConError SoloConError

SELECT 
	h.server		AS Server_Name
	,j.job_id 		AS 'Job_Id'
	,j.name			AS 'Job_Name'
	,s.step_id		AS 'Step_Id'
	,s.step_name	AS 'Step_Name'
	,run_date		AS 'Run_Date'
	,run_time		AS 'Run_Time'
	--,msdb.dbo.agent_datetime(run_date, run_time)											AS 'Run_DateTime'
	,((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60)	AS 'Run_Duration_Minutes'
	,CASE WHEN h.run_status = 0 THEN 'ER' ELSE 'OK' END										AS 'Run_Result'
	,SUBSTRING(h.message,1,4000)															AS 'Run_Txt_Message'
FROM msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobsteps s 
	ON j.job_id = s.job_id
INNER JOIN msdb.dbo.sysjobhistory h 
	ON s.job_id = h.job_id 
	AND s.step_id = h.step_id 
	AND h.step_id <> 0
WHERE j.enabled = 1   -- Enabled Jobs
AND (@JobName IS NULL OR @JobName = j.name)
AND msdb.dbo.agent_datetime(run_date, run_time) >= @FechaDesde
AND (@FechaHasta IS NULL OR msdb.dbo.agent_datetime(run_date, run_time) <= @FechaHasta)
AND ((@SoloConError <> 'S') OR (@SoloConError = 'S' AND h.run_status = 0)) -- 0 con error, 1 sin error
ORDER BY Job_Name, Run_Date DESC, Run_Time DESC, Step_Id



