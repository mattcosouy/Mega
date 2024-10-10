@echo off
setlocal enabledelayedexpansion

:: Lista de enlaces a verificar
set "link_list=ax-argamedev-3dev.eastus.cloudapp.azure.com ax-chiphidev-3dev.eastus.cloudapp.azure.com ax-criletdev-3dev.eastus.cloudapp.azure.com ax-domletdev-3dev.eastus.cloudapp.azure.com ax-domrowdev-3dev.eastus.cloudapp.azure.com  ax-gualetdev-3dev.eastus.cloudapp.azure.com ax-hndletdev-3dev.eastus.cloudapp.azure.com ax-nicletdev-3dev.eastus.cloudapp.azure.com ax-slvletdev-3dev.eastus.cloudapp.azure.com ax-panletdev-3dev.eastus.cloudapp.azure.com ax-dev2-3dev.eastus.cloudapp.azure.com ax-dev3-3dev.eastus.cloudapp.azure.com ax-dev4-3dev.eastus.cloudapp.azure.com ax-dev5-3dev.eastus.cloudapp.azure.com ax-dev6-3dev.eastus.cloudapp.azure.com ax-dev7-3dev.eastus.cloudapp.azure.com ax-prestogld2dev.eastus.cloudapp.azure.com ax-usamlbdev-2dev.eastus.cloudapp.azure.com ax-usamlbgld-2dev.eastus.cloudapp.azure.com ax-ecumlbdev-2dev.eastus.cloudapp.azure.com ax-ecumlbgld-2dev.eastus.cloudapp.azure.com"

:: Variable para rastrear si al menos un enlace no responde al ping
set "no_responde=false"

:: Iterar sobre cada enlace en la lista
for %%i in (%link_list%) do (
    set "link=%%i"
    echo Verificando el ping de !link!...
    ping !link! -n 4 > nul 2>&1

    if errorlevel 1 (
        echo !link! NO RESPONDE AL PING, VERIFICAR AMBIENTE.
        set "no_responde=true"
    ) else (
        echo !link! responde al ping.
    )
	echo "_____________________________________________________________________________________________________________"
)

if "%no_responde%"=="true" (
    echo Al menos un enlace no respondio al ping.
) else (
    echo Todos los enlaces respondieron al ping.
)

pause