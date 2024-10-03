IF EXISTS (SELECT NAME
           FROM sysobjects 
           WHERE NAME = 'MPHsp_ExportHealthRegistration' AND type = 'P')
  DROP PROCEDURE MPHsp_ExportHealthRegistration
GO 

--EXEC dbo.sp_CreateFileNetOrder '' + @pEmpresa + '', 'EDI_NetOrder_TxtArchivos'
CREATE PROCEDURE [dbo].[MPHsp_ExportHealthRegistration]
  @Db			nvarchar(50),		                            -- Base de datos OLAP local al pais                
  @TableIndex   nvarchar(50)	                                -- Tabla indice para recorrer
-------------------------------------------------------------------------------------------
AS
  SET NOCOUNT ON

DECLARE @Nombre		nvarchar(256)
DECLARE @Querie		nvarchar(1000)
declare @pEmpresa   nvarchar(30)
 
set @pEmpresa	= 'Ax2k9UruMphPro'
SET @Querie		= ' DECLARE CursorHealthRegistration CURSOR FOR 
					SELECT [Nombre]
					FROM   ['+ @Db +'].[dbo].['+ @TableIndex + ']'
EXECUTE (@Querie)

OPEN CursorHealthRegistration
FETCH NEXT FROM CursorHealthRegistration INTO @Nombre

WHILE @@FETCH_STATUS = 0
    BEGIN    
         DECLARE @bcpCommand varchar(5000)
         SET @bcpCommand = 'bcp "USE ' + @pEmpresa + '; SELECT TXT FROM ' + @pEmpresa + '.dbo.EDI_NetOrder_TxtFormatos '
         SET @bcpCommand = @bcpCommand + 'WHERE Archivo like '''+ @Nombre +'''"' 
         SET @bcpCommand = @bcpCommand + ' queryout \\172.18.1.4\ImportAX$\'+ @Nombre +' -U linked -P linked -c'
         --print @bcpCommand
         EXEC master..xp_cmdshell @bcpCommand 
       FETCH NEXT FROM CursorHealthRegistration INTO @Nombre
    END
CLOSE CursorHealthRegistration
DEALLOCATE CursorHealthRegistration
GO