@echo off
echo %1

set Usr[1]=AxCriLetServicios
set db[1]=AxCriLetOLAP
set pw[1]=AxLocal01

set Usr[2]=AxHndLetServicios
set db[2]=AxHndLetOLAP
set pw[2]=AxLocal01

set Usr[3]=AxArgAmeServicios
set db[3]=AxArgAmeOLAP
set pw[3]=AxLocal01

set Usr[4]=AxGuaLetServicios
set db[4]=AxGuaLetOLAP
set pw[4]=AxLocal01

set Usr[5]=AxNicLetServicios
set db[5]=AxNicLetOLAP
set pw[5]=AxServicios01






set "x=1"


::Solucion del pagulito

:SymLoop
@echo off
if not defined Usr[%x%] goto :endLoop

	call set US=%%Usr[%x%]%%
	call set data=%%db[%x%]%%
	call set psw=%%pw[%x%]%%
	
	Echo Usuario: %US%
	Echo Base de Datos: %data%
	call sqlcmd -S mpdb005usa5.database.windows.net -d %data% -U %US% -P %psw% -i%1
REM do your stuff US
	echo .....................................................................................
	SET /a "x+=1"
	GOTO :SymLoop

:endLoop
echo "Done"

pause