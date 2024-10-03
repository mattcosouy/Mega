-- Baja el tamaño del Log de la BD a 1 MB.
-- Gracias MR
--
USE Ax2k9MPHPRO;
GO
ALTER DATABASE Ax2k9MPHPRO
SET RECOVERY SIMPLE;
GO
-- Deja el log en 1 MB.
DBCC SHRINKFILE(AX2k9MPHMPStd_log, 1);
GO
-- Regresar el modelo de recuperacion a FULL.
ALTER DATABASE Ax2k9MPHPRO
SET RECOVERY FULL;
GO
 