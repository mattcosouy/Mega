param(
    [string]$EnvironmentName  # Nombre simple del ambiente, por ejemplo: NicLetDev
)

# --- Lista de ambientes y sus URLs de LCS ---
$Environments = @{
    "ArgAmeVal" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780841?EnvironmentId=04787109-9e8e-4932-8640-7146dba7121d&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "ArgAmeDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780841?EnvironmentId=dd7f2829-5129-49b3-be56-395eac16c16d&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "ArgAmeGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780841?EnvironmentId=ab83a415-7072-4e94-a428-58728b31a905&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "ChiPhiDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1278177?EnvironmentId=b6062d56-e961-4eff-b0eb-96bc9448ad27&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "ChiPhiGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1278177?EnvironmentId=46159305-086e-4989-a518-117bb9c8a7e4&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "CriLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1770252?EnvironmentId=2b3bf4dd-e6d8-49e0-848f-6d438a371657&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "CriLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1770252?EnvironmentId=69b5ae58-9de9-4221-a43f-9fdf9ffba535&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "DomLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1362372?EnvironmentId=15dd2e84-e82c-49cd-a9f3-1d6218827e18&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "DomLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1362372?EnvironmentId=2eb074cc-a874-463a-975e-18bfd00f1173&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "DomRowVal" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1281056?EnvironmentId=c8f1b14d-c092-413e-8f46-0e7068ce625a&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "DomRowDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1281056?EnvironmentId=de079770-0805-45a4-9d99-b2521cd90ccb&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "DomRowGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1281056?EnvironmentId=0f675bce-6bff-4e27-a72a-9e9d36b9cba2&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "GuaLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1362373?EnvironmentId=7b348590-20b7-44ff-a5c2-fcb2a92e6a7c&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "GuaLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1362373?EnvironmentId=79a6c09c-ebbf-4e25-8a85-01050a1217d2&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "HndLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780737?EnvironmentId=9d00d1f5-0d56-4f58-a38b-3f16a483018a&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "HndLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780737?EnvironmentId=b908beef-08f8-40a3-9598-c0b5030e6684&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "NicLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780736?EnvironmentId=4a8a90dd-ed28-4ecb-a982-e5ff68a5030a&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "NicLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1780736?EnvironmentId=a0f58c77-7ef9-4327-9a03-bbc5ce25bfca&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "SlvLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1769297?EnvironmentId=0e4b0622-8432-4cc5-811b-f076a5fa4968&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "SlvLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1769297?EnvironmentId=c6ff083d-4b18-42ef-8b06-9371166069c1&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "PanLetDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1269886?EnvironmentId=88b3c36c-d334-4fbc-a368-178b35d971ee&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "PanLetGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1269886?EnvironmentId=45d4ef83-e561-49c2-949a-7a32139847ba&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "UsaMlbDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1839747?EnvironmentId=202af2c8-2e46-41fa-a584-00dca62f7cd5&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "UsaMlbGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1839747?EnvironmentId=60c82181-ebdd-4f02-863b-5060bc3c7540&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "EcuMlbDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1839746?EnvironmentId=2b861bcc-d06d-42f5-b3db-e08beddfffc3&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "EcuMlbGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1839746?EnvironmentId=30a413f9-dc0f-400e-bc6e-6879498ddc2d&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"
    "Dev2" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=043a3570-6d5c-437a-b93a-2b45ac282fd3&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "Dev3" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=763b48da-9b5c-4ec3-9bf1-955500621b05&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "Dev4" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=1ccccf39-16d9-496c-88c6-81a0dafa461d&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "Dev5" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=ed69d9e8-d4a8-4a99-a064-ac2189775dcd&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "Dev6" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=1091242e-323c-4d88-bfe4-19ad402bc269&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "Dev7" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=c7cdf28a-a859-4850-ae68-390ca72cd840&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "UruIclDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1874451?EnvironmentId=c017b177-b1f8-4c7f-b01b-bd60774cd9c9&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "UruIclGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1874451?EnvironmentId=f6b7fe58-f83d-42b0-a419-73c965e5d18d&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "MexMlbDev" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1884768?EnvironmentId=94c67d07-ed5a-4aaa-8d6f-c6aa9a24344e&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "MexMlbGld" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1884768?EnvironmentId=4e6dbdf1-8c32-46f5-b52b-c4426bb33bf5&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=false"
    "Ax-Migration" = "https://lcs.dynamics.com/V2/EnvironmentDetailsV3New/1193048?EnvironmentId=7474989e-1683-409b-8fc2-e17c09d7cc4e&IsCloudEnvironment=true&IsDiagnosticsEnabledEnvironment=true"    

    # Agregar más ambientes aquí con el formato: "Nombre" = "URL"
}

# --- Diccionario de hosts para ping ---
$Hosts = @{
    "ArgAmeDev" = "ax-argamedev-3dev.eastus.cloudapp.azure.com"
    "ArgAmeVal" = "ax-argamevaldev.eastus.cloudapp.azure.com"
    "ArgAmeGld" = "ax-argamegld-3dev.eastus.cloudapp.azure.com"
    "ChiPhiDev" = "ax-chiphidev-3dev.eastus.cloudapp.azure.com"
    "ChiPhiGld" = "ax-chiphigld-3dev.eastus.cloudapp.azure.com"
    "CriLetDev" = "ax-criletdev-3dev.eastus.cloudapp.azure.com"
    "CriLetGld" = "ax-criletgld-3dev.eastus.cloudapp.azure.com"
    "DomLetDev" = "ax-domletdev-3dev.eastus.cloudapp.azure.com"
    "DomLetGld" = "ax-domletgld-3dev.eastus.cloudapp.azure.com"
    "DomRowDev" = "ax-domrowdev-3dev.eastus.cloudapp.azure.com"
    "DomRowVal" = "ax-domrowval-3dev.eastus.cloudapp.azure.com"
    "DomRowGld" = "ax-domrowgld-3dev.eastus.cloudapp.azure.com"
    "GuaLetDev" = "ax-gualetdev-3dev.eastus.cloudapp.azure.com"
    "GuaLetGld" = "ax-gualetgld-3dev.eastus.cloudapp.azure.com"
    "HndLetDev" = "ax-hndletdev-3dev.eastus.cloudapp.azure.com"
    "HndLetGld" = "ax-hndletgld-3dev.eastus.cloudapp.azure.com"
    "NicLetDev" = "ax-nicletdev-3dev.eastus.cloudapp.azure.com"
    "NicLetGld" = "ax-nicletgld-3dev.eastus.cloudapp.azure.com"
    "SlvLetDev" = "ax-slvletdev-3dev.eastus.cloudapp.azure.com"
    "SlvLetGld" = "ax-slvletgld-3dev.eastus.cloudapp.azure.com"
    "PanLetDev" = "ax-panletdev-3dev.eastus.cloudapp.azure.com"
    "PanLetGld" = "ax-panletgld-3dev.eastus.cloudapp.azure.com"
    "UsaMlbDev" = "ax-usamlbdev-2dev.eastus.cloudapp.azure.com"
    "UsaMlbGld" = "ax-usamlbgld-2dev.eastus.cloudapp.azure.com"
    "EcuMlbDev" = "ax-ecumlbdev-2dev.eastus.cloudapp.azure.com"
    "EcuMlbGld" = "ax-ecumlbgld-2dev.eastus.cloudapp.azure.com"
    "Dev2" = "ax-dev2-3dev.eastus.cloudapp.azure.com"
    "Dev3" = "ax-dev3-3dev.eastus.cloudapp.azure.com"
    "Dev4" = "ax-dev4-3dev.eastus.cloudapp.azure.com"
    "Dev5" = "ax-dev5-3dev.eastus.cloudapp.azure.com"
    "Dev6" = "ax-dev6-3dev.eastus.cloudapp.azure.com"
    "Dev7" = "ax-dev7-3dev.eastus.cloudapp.azure.com"
    "UruIclDev" = "ax-uruicldev-3dev.eastus.cloudapp.azure.com"
    "UruIclGld" = "ax-uruiclgld-3dev.eastus.cloudapp.azure.com"
    "MexMlbDev" = "ax-mexmlbdev-3dev.eastus.cloudapp.azure.com"
    "MexMlbGld" = "ax-mexmlbgld-3dev.eastus.cloudapp.azure.com"
    "Ax-Migration" = "ax-migrationdev.eastus.cloudapp.azure.com"
}


function Test-EnvironmentConnection {
    param([string]$TargetHost)
    try { return (Test-NetConnection -ComputerName $TargetHost -Port 443 -InformationLevel Quiet) }
    catch { return $false }
}

# --- 1) Comprobar si ya está activo ---
if ($Hosts.ContainsKey($EnvironmentName) -and (Test-EnvironmentConnection $Hosts[$EnvironmentName])) {
    Write-Output "Ya levantado"
    exit
}

# --- 2) Selenium para Stop / Start ---
Import-Module Selenium
$DriverPath = "C:\Users\ldiaz1\Documents\Drivers"
$chromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$chromeService = [OpenQA.Selenium.Chrome.ChromeDriverService]::CreateDefaultService($DriverPath)
$Driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($chromeService, $chromeOptions)

$UserEmail = "uy-mp-ax365-trade@megapharma.com"
$UserPassword = "Ax!Azure2017"

try {
    $Driver.Navigate().GoToUrl($Environments[$EnvironmentName])
    Start-Sleep 15

    # Login secuencial
    try { $Driver.FindElementById("i0116").SendKeys($UserEmail); $Driver.FindElementById("idSIButton9").Click(); Start-Sleep 5 } catch {}
    try { $Driver.FindElementById("i0118").SendKeys($UserPassword); $Driver.FindElementById("idSIButton9").Click(); Start-Sleep 8 } catch {}
    try { $Driver.FindElementById("idBtn_Back").Click(); Start-Sleep 5 } catch {}

    Start-Sleep -Seconds 50
    try {
        $StopButton = $Driver.FindElementByXPath("//button[@id='EnvironmentDetailsV3_1_StopDeployment' or @name='StopDeployment' or @data-dyn-controlname='StopDeployment']")
        if ($StopButton) {
            Write-Host "Botón Stop encontrado. Haciendo clic..."
            try { 
                $StopButton.Click()
                Write-Host "Click en Stop ejecutado."
            } catch {
                Write-Host "Error al hacer click en Stop: $_"
            }

            $YesButtonConfirm = $null
            for ($t = 1; $t -le 30; $t++) {
                try {
                    $YesButtonConfirm = $Driver.FindElementByXPath("//button[contains(text(),'Yes') or @aria-label='Yes' or @data-dyn-controlname='YesButton' or @name='Yes']")
                    if ($YesButtonConfirm) { break }
                } catch { Start-Sleep -Seconds 1 }
            }
            if ($YesButtonConfirm) {
                try { 
                    $YesButtonConfirm.Click(); 
                    Write-Host "Confirmacion de Stop realizada." 
                } catch { 
                    Write-Host "Se encontro Yes pero no se pudo hacer clic: $_"
                }
            }
            Start-Sleep -Seconds 120
            $Driver.Navigate().Refresh()
            Start-Sleep -Seconds 40
        } else {
            Write-Host "No se encontró botón Stop (puede estar listo para iniciar)."
        }
    } catch { Write-Host "Error buscando botón Stop: $_" }

    # --- START ---
    $StartFound = $false
    for ($i=1; $i -le 2; $i++) {
        try {
            $StartButton = $Driver.FindElementByXPath("//button[@id='EnvironmentDetailsV3_1_StartDeployment' or @name='StartDeployment' or @data-dyn-controlname='StartDeployment']")
            if ($StartButton) {
                Write-Host "Clic en Start (Intento $i)..."
                try { 
                    $StartButton.Click()
                    $StartFound = $true
                    Write-Host "Click en Start ejecutado."
                    Start-Sleep -Seconds 10
                    break
                } catch {
                    Write-Host "Error haciendo click en Start: $_"
                }
            } else {
                Write-Host "Start no disponible (Intento $i). Esperando 60s..."
                Start-Sleep -Seconds 60
                $Driver.Navigate().Refresh()
                Start-Sleep -Seconds 15
            }
        } catch {
            Write-Host "Error buscando botón Start: $_"
        }
    }

    $Driver.Quit()

    if ($StartFound) { Write-Output "Levantado" } else { Write-Output "Error" }

} catch {
    try { $Driver.Quit() } catch {}
    Write-Output "Error"
}
