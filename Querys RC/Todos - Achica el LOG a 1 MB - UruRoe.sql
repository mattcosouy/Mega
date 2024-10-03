-- Baja el tamaño del Log de la BD a 1 MB.
-- Gracias MR
--
USE Ax2k9UruRoePro;
GO
ALTER DATABASE Ax2k9UruRoePro
SET RECOVERY SIMPLE;
GO
-- Deja el log en 1 MB.
DBCC SHRINKFILE(AX2k9MPHMPStd_log, 1); --AX2k9MPHMPStd_log
GO
-- Regresar el modelo de recuperacion a FULL.
ALTER DATABASE Ax2k9UruRoePro
SET RECOVERY FULL;
GO
 
 --SELECT name FROM sys.master_files WHERE type_desc = 'LOG'

