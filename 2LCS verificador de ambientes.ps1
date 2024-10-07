# Lista de enlaces a verificar
$link_list = @(
    "ax-argamedev-3dev.eastus.cloudapp.azure.com",
    "ax-chiphidev-3dev.eastus.cloudapp.azure.com",
    "ax-criletdev-3dev.eastus.cloudapp.azure.com",
    "ax-domletdev-3dev.eastus.cloudapp.azure.com",
    "ax-domrowdev-3dev.eastus.cloudapp.azure.com",
    "ax-gualetdev-3dev.eastus.cloudapp.azure.com",
    "ax-hndletdev-3dev.eastus.cloudapp.azure.com",
    "ax-nicletdev-3dev.eastus.cloudapp.azure.com",
    "ax-slvletdev-3dev.eastus.cloudapp.azure.com",
    "ax-panletdev-3dev.eastus.cloudapp.azure.com",
    "ax-dev2-3dev.eastus.cloudapp.azure.com",
    "ax-dev3-3dev.eastus.cloudapp.azure.com",
    "ax-dev4-3dev.eastus.cloudapp.azure.com",
    "ax-dev5-3dev.eastus.cloudapp.azure.com",
    "ax-dev6-3dev.eastus.cloudapp.azure.com",
    "ax-dev7-3dev.eastus.cloudapp.azure.com",
    "ax-prestogld2dev.eastus.cloudapp.azure.com",
    "ax-usamlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-usamlbgld-2dev.eastus.cloudapp.azure.com",
    "ax-ecumlbdev-2dev.eastus.cloudapp.azure.com",
    "ax-ecumlbgld-2dev.eastus.cloudapp.azure.com"
)

# Variable para rastrear si al menos un enlace no responde
$no_responde = $false

# Puerto al que intentamos conectarnos (80 para HTTP, 443 para HTTPS)
$port = 80

# Función para probar la conexión TCP
function Test-TcpConnection {
    param (
        [string]$hostname,
        [int]$port
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($hostname, $port)
        $tcpClient.Close()
        return $true
    } catch {
        return $false
    }
}

# Iterar sobre cada enlace en la lista
foreach ($link in $link_list) {
    Write-Host "Verificando la conexion TCP a $link en el puerto $port..."

    $result = Test-TcpConnection -hostname $link -port $port

    if ($result) {
        Write-Host "$link responde correctamente en el puerto $port." -ForegroundColor Green
    } else {
        Write-Host "$link NO RESPONDE en el puerto $port, VERIFICAR AMBIENTE." -ForegroundColor Red
        $no_responde = $true
    }

    Write-Host "_____________________________________________________________________________________________________________"
}

# Mensaje final
if ($no_responde) {
    Write-Host "Al menos un enlace no respondió."
} else {
    Write-Host "Todos los enlaces respondieron correctamente."
}

# Pausa para mantener la ventana abierta
Read-Host "Presione Enter para salir..."