$folderPaths = @(
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\ArgRay",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Bolivia",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Centro America",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Chile",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\ColSca",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Dominicana Megalabs",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Dominicana Rowe",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Ecuador Acromax",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Ecuador Megalabs",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Mexico Megalabs",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\MexIta",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\PanLet",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Paraguay",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Peru",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Uruguay Megalabs",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\UruMph", 
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\UruSel",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\USA Megalabs",
    "\\mpap003mvd3\sites\gcti\Ax_Reportes\Venezuela"
)

$today = (Get-Date).Date
$oneMonthAgo = $today.AddMonths(-1)

# Configuración del correo electrónico
$From = "noreply@megalabs.global"
$To = "OperacionesAX@megalabs.global"
$Subject = "AGORA: Archivos no actualizados hoy"
$Body = "<html><body>Los siguientes archivos no fueron actualizados en el dia de hoy"

$SMTPServer = "mail.megapharma.com"
$SMTPPort = "25"

# Procesar cada ruta de carpeta
foreach ($folderPath in $folderPaths) {
    $folderName = Split-Path -Path $folderPath -Leaf  # Obtener el nombre de la carpeta
    
    # Obtén todos los archivos en la carpeta actual, excluyendo archivos .tmp
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -ne ".tmp" }
    
    # Inicializa listas para archivos actualizados y no actualizados
    $updatedFiles = @()
    $notUpdatedFiles = @()

    # Clasifica los archivos según la fecha de modificación, excluyendo los que no se han actualizado en más de un año
    foreach ($file in $files) {
        if ($file.LastWriteTime.Date -ge $oneMonthAgo) {
            if ($file.LastWriteTime.Date -eq $today) {
                $updatedFiles += $file.Name
            } else {
                $notUpdatedFiles += [PSCustomObject]@{
                    Name     = $file.Name
                    LastDate = $file.LastWriteTime.Date.ToString("dd-MM-yyyy")
                }
            }
        }
    }

    # Agregar resultados de la ruta actual al cuerpo del correo en formato HTML
    if ($notUpdatedFiles.Count -gt 0) {
        $Body += "<h3>$folderName</h3><table border='1' cellpadding='5' cellspacing='0'><tr><th>Fecha</th><th>Archivo</th></tr>"
        foreach ($file in $notUpdatedFiles) {
            $Body += "<tr><td>$($file.LastDate)</td><td>$($file.Name)</td></tr>"
        }
        $Body += "</table><br>"
    } 
}

$Body += "</body></html>"

# Enviar el correo electrónico con la lista completa en formato HTML
if ($Body -ne "<html><body>Los siguientes archivos no fueron actualizados en el dia de hoy</body></html>") {
    Send-MailMessage -From $From -To $To -Subject $Subject -BodyAsHtml $Body -SmtpServer $SMTPServer -Port $SMTPPort
}
