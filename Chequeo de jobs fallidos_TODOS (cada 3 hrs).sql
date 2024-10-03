DECLARE @profilename NVARCHAR(100) = (SELECT TOP 1 name FROM msdb.dbo.sysmail_profile)
DECLARE @jobCount INT;
DECLARE @jobErrors TABLE (
    step_id INT,
    job_name NVARCHAR(100),
    run_date INT,
    run_time INT,
    run_duration INT,
    run_status INT,
    message NVARCHAR(MAX)
)

SET @jobCount = (
    SELECT COUNT(*) 
    FROM msdb.dbo.sysjobhistory 
    WHERE run_date = CONVERT(VARCHAR(8), GETDATE(), 112) 
        AND run_status = 0
);

IF (@jobCount > 0)
BEGIN
    DECLARE @body NVARCHAR(MAX);
    SET @body = '<p>Verificar el historial de jobs con errores: '+@@SERVERNAME+' </p>';
    SET @body = @body + '<table border="1"><tr><th>Step ID</th><th>Nombre del job</th><th>Fecha y hora local</th><th>Duración</th><th>Status</th><th>Mensaje de error</th></tr>';

    INSERT INTO @jobErrors
    SELECT h.step_id, j.name, h.run_date, h.run_time, h.run_duration, h.run_status, h.message
    FROM msdb.dbo.sysjobs j
    INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
    WHERE h.run_date = CONVERT(VARCHAR(8), GETDATE(), 112) AND h.run_status = 0
        AND step_id != 0
        AND msdb.dbo.agent_datetime(run_date, run_time) >= DATEADD(HOUR, -3, GETDATE())
    ORDER BY h.run_date DESC, h.run_time DESC;

    IF EXISTS (SELECT * FROM @jobErrors)
    BEGIN
        DECLARE @jobErrorsBody NVARCHAR(MAX);
        SET @jobErrorsBody = '';
        SELECT @jobErrorsBody = @jobErrorsBody + '<tr><td>' + CAST(step_id AS NVARCHAR(10)) + '</td><td>' + job_name + '</td><td>' + CONVERT(VARCHAR(100), msdb.dbo.agent_datetime(run_date, run_time))  + '</td><td>' + CONVERT(VARCHAR(50), DATEADD(ms, run_duration, 0), 108) + '</td><td>' +
            CASE run_status
                WHEN 0 THEN '<font color="red">Error</font>'
                WHEN 1 THEN '<font color="green">Finalizado</font>'
                WHEN 2 THEN '<font color="orange">Reintento</font>'
                WHEN 3 THEN '<font color="blue">Cancelado</font>'
                ELSE 'Unknown'
            END + '</td><td>' + message + '</td></tr>'
        FROM @jobErrors;

        SET @body = @body + @jobErrorsBody + '</table>';

        DECLARE @nombreservidor NVARCHAR(100) = 'Jobs con errores en server: ' +@@SERVERNAME;

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = @profilename,
            @recipients = 'operacionesax@megalabs.global;pgomez@megalabs.global',
            @subject = @nombreservidor,
			@body = @body,
			@body_format = 'HTML';
			END
			END
