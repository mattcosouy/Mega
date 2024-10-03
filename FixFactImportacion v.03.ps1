
cls

 <#
 OperacionesAX - Version 0.04

 1_ Checkear si la carpeta Inprocess esta vacia
 
 2_ Detener servicios de recurring

 3_ Mover archivos de input a FactImportacion

 4_ Iniciar proceso nuevamente

 5_Mover archivos nuevamente a input folder

 Este Script debe ser ejecutado como administrador, de otro
 modo,no se podra reinicar el servicio.
 #>


 
 

#Currenttly Loged User 
$LogedUser          = $env:USERNAME #((Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username))


$ImportPath         = "E:\Recurring PRO\Import"

#$LogPath           = "$ImportPath\Log.txt"

$eLogistic_Sales    = "$ImportPath\eLogistic Sales"
$FactImportacion    = "$ImportPath\FactImportacion" 
$NetOrderSales      = "$ImportPath\NetOrderSales"
$Return_order_sales = "$ImportPath\Import\Return order sales"

$xdate              = Get-Date –format 'yyyyMMdd_HHmmss' #This format is required in case we need to use the date in the file's name



#TODO: LOG FILE...
#Version 0.04 will be able to fix all Import folders, and only the stuck ones.


$archivo            = "$ImportPath\FixRec\Log\Rec_log.txt"
Add-Content -Path $archivo -Value "<# -------------- Executed by $LogedUser at $xdate -------------- #>"

#-------------------------------------------
function movefiles($from,$to){
	Get-ChildItem -Path $from -File | Move-Item -Destination $to 
}
#-------------------------------------------

#-------------------------------------------
function stopProcess($pname){
	echo "Deteniendo servicio $pname..." 
	Get-Process -Name $pname | Stop-Process -Force
	sleep 20
}
#stopProcess("RecurringIntegrationService")
#-------------------------------------------


#-------------------------------------------
function startProcess($pname){
	echo "Iniciando servicio $pname..."
	Get-Service -DisplayName $pname | Start-Service
	sleep 30
}
#startProcess("RecurringIntegrationService")
#-------------------------------------------


#If the inprocess folder is not empty, does nothing.



function fix($DirControl,$Rec_Father,$Rec_Son){

if((Get-ChildItem $Rec_Son | Measure-Object).Count -eq 0){

##"****----Executed by $LogedUser at $StartedAt----****"  | Out-File -FilePath $LogPath

    echo "Nothing to move, $Rec_Son is empty!, no need to restart te service."
    Add-Content -Path $archivo -Value "Nothing to move, $Rec_Son is empty!, no need to restart the service."

   ##"Nothing to move, $FactImportacion is empty!, no need to restart te service." | Out-File -FilePath $LogPath -Append 

}else{


if( (Get-ChildItem $DirControl | Measure-Object).Count -eq 0){

	echo "inprocess folder is empty, Stoping service and moving files..."
    Add-Content -Path $archivo -Value "inprocess folder is empty at $xdate"
    

	stopProcess("RecurringIntegrationService")
    Add-Content -Path $archivo -Value "Process Stopped"

	echo "Creando ubicacion Temp.."
	New-Item -Path "$Rec_Father\Temp" -ItemType Directory
	$TempFolderDir = "$Rec_Father\Temp"
    Add-Content -Path $archivo -Value "Temp folder created - $TempFolderDir"
	sleep 5
    

	echo "Moviendo archivos hacia ubicacion Temp.."
	movefiles $Rec_Son $TempFolderDir
	sleep 5
    Add-Content -Path $archivo -Value "Files Moved to temp folder."
    
	
	startProcess("RecurringIntegrationService")
    $ControlDate = Get-Date
    Add-Content -Path $archivo -Value "Recurring process restarted."
	
	echo "Devolviendo archivos desde ubicacion Temp.."
	movefiles $TempFolderDir $Rec_Son
	sleep 10
    Add-Content -Path $archivo -Value "Files moved back to $Rec_Son"
	
	echo "Eliminando ubicacion Temp.."
	Remove-Item $TempFolderDir
    Add-Content -Path $archivo -Value "Temp folder deleted."
	sleep 10
 
	
	echo " 	"
	echo "Files moved, temp folder deleted."
    
} else { 
	echo "Folder ""inprocess"" is not empty,please check"

    }
  }
}

#Fix FactImportacion
fix "$FactImportacion\inprocess" $FactImportacion "$FactImportacion\input"


