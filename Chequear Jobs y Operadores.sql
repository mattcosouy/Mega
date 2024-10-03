SELECT 
    sysjobs.[name] AS [Job_Name] 
    ,CASE sysjobs.[notify_level_email] 
        WHEN 0 THEN 'Never' 
        WHEN 1 THEN 'Succeeds' 
        WHEN 2 THEN 'Fails' 
        WHEN 3 THEN 'Completes' 
        ELSE CONVERT(VARCHAR,sysjobs.[Notify_Level_email]) 
    END AS [Notify_Level_Email] 
    ,ISNULL(operator.name,'') AS [Operator_Name] 
    ,CASE sysjobs.[notify_level_eventlog] 
        WHEN 0 THEN 'Never' 
        WHEN 1 THEN 'Succeeds' 
        WHEN 2 THEN 'Fails' 
        WHEN 3 THEN 'Completes' 
        ELSE CONVERT(VARCHAR,sysjobs.[notify_level_eventlog]) 
    END AS [Notify_Level_EventLog] 
    ,CASE 
        WHEN sysjobschedules.next_run_date IS NOT NULL THEN 'SI' 
        ELSE '' 
    END AS [Existe_Agendamiento] 
 

 
 

FROM [msdb].[dbo].[sysjobs] sysjobs 
LEFT JOIN [msdb].[dbo].[sysoperators] operator 
    ON sysjobs.[notify_email_operator_id] = operator.[id] 
LEFT JOIN msdb.dbo.sysjobschedules sysjobschedules 
    ON sysjobs.job_id = sysjobschedules.job_id 
    AND ISNULL(sysjobschedules.next_run_date,0) >= convert(int,convert(char(8),getdate(),112)) 

 
 

WHERE sysjobs.[enabled] = 1 
ORDER BY Job_Name 