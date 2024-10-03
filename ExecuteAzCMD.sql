USE [AxOperaciones]
GO

/****** Object:  StoredProcedure [dbo].[ExecuteScriptAZ]    Script Date: 29/6/2023 9:35:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ================================================================
--Comentarios:
	/*
	Este script de utiliza para ejecutar archivos .SQL desde un
		.BAT script.

	Es IMPORTANTE tener en cuenta:
		--Tener claro el contenido del archivo .SQL que se va a ejecutar

		--Dentro el .BAT, se definde las BASES DE DATOS en las que tendra efecto
			el .SQL, ademas de los usuarios de las bases mencionadas
	*/
	

-- ================================================================
/*
_____________________________________________________________________________________________
@echo off																					 |
echo %1																						 |
																							 |
set Usr[1]=AxCriLetServicios																 |
set Usr[2]=AxHndLetServicios																 |
set Usr[3]=AxArgAmeServicios																 |
set Usr[4]=AxGuaLetServicios																 |
set Usr[5]=AxNicLetServicios																 |
set Usr[6]=AxDomRowServicios																 |
set Usr[7]=AxDomLetServicios																 |
set Usr[8]=AxPanLetServicios																 |
set Usr[9]=AxChiPhiServicios																 |
																							 |
set db[1]=AxCriLetOLAP																		 |
set db[2]=AxHndLetOLAP																		 |
set db[3]=AxArgAmeOLAP																		 |
set db[4]=AxGuaLetOLAP																		 |
set db[5]=AxNicLetOLAP																		 |
set db[6]=AxDomRowOLAP																		 |
set db[7]=AxDomLetOLAP																		 |
set db[8]=AxPanLetOLAP																		 |
set db[9]=AxChiPhiOLAP																		 |
																							 |
set pw[1]=AxLocal01 																		 |
set pw[2]=AxLocal01 																		 |
set pw[3]=AxLocal01 																		 |
set pw[4]=AxLocal01 																		 |
set pw[5]=AxLocal01 																		 |
set pw[6]=Servicios01																		 |
set pw[7]=Servicios01																		 |
set pw[8]=Servicios01																		 |
set pw[9]=Servicios01																		 |
																							 |
																							 |
set "x=1"																					 |
																							 |
:SymLoop																					 |
@echo off																					 |
if not defined Usr[%x%] goto :endLoop														 |
call set US=%%Usr[%x%]%%																	 |
call set data=%%db[%x%]%%																	 |
call set psw=%%pw[%x%]%%																	 |
Echo Usuario: %US%																			 |
Echo Base de Datos: %data%																	 |
call sqlcmd -S mpdb005usa5.database.windows.net -d %data% -U %US% -P %psw% -i%1				 |
REM do your stuff US																		 |
echo """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""		 |
SET /a "x+=1"																				 |
GOTO :SymLoop																				 |
																							 |
:endLoop																					 |
echo "Done"																					 |
																							 |
pause																						 |
_____________________________________________________________________________________________|
*/


-- ================================================================
-- Author:		<Nahuel Sierra>
-- Create date: <16/8/2023>
-- ================================================================
ALTER PROCEDURE [dbo].[ExecuteScriptAZ] 
	
-- ================================================================
					/*___ARGUMENTOS___*/
	
	/*
	Archivo .SQL con las inctrucciones a ejecutar.
	*/
	@_file varchar(80) 
-- ================================================================
AS
BEGIN
	
-- ================================================================
				/*____FORMAR DE EJECUCION____*/
	
	--Localmente
		--EXEC ExecuteSctiptAZ 'E:\Bats\query.sql'  | 'C:\Bats\query.sql' | 'etc etc tec'
	--Desde unidad de red
		--EXEC ExecuteSctiptAZ '\\mpap004mvd5\PGOMEZ-DEV\AX365\PBI_TipoDeCambio - D365.sql'
		--EXEC ExecuteScriptAZ '\\mpap004mvd5\PGOMEZ-DEV\AX365\PBI_DimensionesFinancieras.sql'
-- ================================================================

	SET NOCOUNT ON;


	--exec(' xp_cmdshell ''E:\Bats\SQLCmdAZ.bat '+@_file+''''); --your bat file location(path)
	exec(' xp_cmdshell ''E:\Bats\SQLCmdAZ.bat "'+@_file+'"'''); --your bat file location(path) Se cambio para que el file name quede entre comillas dobles PG Y NS 18/05/2023
END

GO




