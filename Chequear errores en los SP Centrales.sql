DECLARE @xQuerie nvarchar(2000) 
DECLARE @ObjectId nvarchar(50) 
DECLARE @ObjectDest nvarchar(50) 
DECLARE @Querie nvarchar(2000) 
DECLARE @DbAzure nvarchar(20) 
DECLARE @Order int 
DECLARE @sgValorHs int 

  

set @DbAzure = (select DB_NAME()) -- Utiliza la BD a la que esté conectado 

--'AxPanLetOLAP' -- Desde 15/10/2021 Se graba Tracking en BDLocal... procurando disminuír tiempos de ejecución 

--'AxChiPhiOLAP' 

--'AxDomRowOlap' 

--'AxDomLetOlap' 

--'AxGuaLetOlap' 

 

-- Active esto y declare los parámetros para ejecución manual 

-- DECLARE @Db nvarchar(50) = 'AxPanLetOLAP' 

DECLARE @Db nvarchar(50) = @DbAzure 
DECLARE @LkName nvarchar(50) = 'AZURE OLAP' 
DECLARE @DesdeBD nvarchar(50) = '' 

  

set @DesdeBD = '['+ @LkName +'].['+ @DbAzure +'].' 
If @DbAzure != '' set @DesdeBD = '' -- esto es para utilizar la Tracking LOCALMENTE 
set @sgValorHs = (SELECT ValorHs FROM PBI_Seguridad where isnull(charindex(PaisEmpresa, @DbAzure),0) <> 0) 

  

/*  

-- estos van solo para integración AX4 - Dy365 

update [AZURE OLAP].[AxDomRowOLAP].dbo.PBI_Indice 

set Activo = 'NO' 

  , FrecAlta = 'No' 

where Orden in ('320') 

--*/ 

  

-- Active esta sección para consultar TRACKING de AXFACADECORP 

-- AX7PANLET_CAIC, AX7DOMLET_CAIC, AX7DOMROW_CAIC 

-- AX5URUMPH_CAIC, AX5URUROE_CAIC, AX5ARGRAY_CAIC, AX5PERROE_CAIC, AX5COLSCA_CAIC, AX5MEXITA_CAIC 

-- AX4DOMROW_CAIC, AX4ECUACR_CAIC, AX4VENKLI_CAIC 

/* 

  

-- conectarse a MPAP009MVD1\AXFACADECORP 

-- use AX7DOMLET_CAIC 

  

select * from [dbo].[Dy365_Indice_Tracking] 

order by FecInicio desc 

--*/ 

  

-- Active esta sección para consultar TRACKING 

-- Se consulta por hora de inicio en función del uso horario del Pais: DateAdd(hh, sg.ValorHs, tk.FecInicio) 

--SCA001 

--/* 

SET @Querie = ' SELECT tk.*, str((isnull(Demora, dateDiff(s, tk.FecInicio, getUTCDate()))+0.0)/60, 12, 3) [Demora-min], 

DateAdd(hh, '+ltrim(str(@sgValorHs,3))+', tk.FecInicio) FecInicioEmp, DateAdd(hh, '+ltrim(str(@sgValorHs,3))+', tk.FecFin) FecFinEmp,  

GetDate() HoraActualEmp, DateAdd(hh, -3, getUTCdate()) HoraActualUY 

FROM '+ @DesdeBD +'[dbo].[PBI_Indice_Tracking] tk 

where 1=1 

  and convert(nvarchar(20),DateAdd(hh, '+ltrim(str(@sgValorHs,3))+', tk.FecInicio),120) >= '''+convert(nvarchar(10),getDate()-0,120)+' 00:30:00'' 

--  and convert(nvarchar(20),DateAdd(hh, '+ltrim(str(@sgValorHs,3))+', tk.FecInicio),120) <  '''+convert(nvarchar(10),getDate()-0,120)+' 00:30:00'' 

--  and isnull(FecFin,''1900-01-01'')=''1900-01-01'' 

--  and isnull(tk.FecFin,'''') = '''' 

--  and tk.Detalle like ''%scamara%'' 

--  and tk.Orden between 690 and 690 

--  and tk.ObjetoID like ''%VentaFac%''       

    and tk.Detalle not like ''%A/F:S%'' 

--  and tk.Detalle like ''%A/F:S%'' 

order by tk.FecInicio desc, tk.Orden desc' 

  

print @Querie 
exec (@Querie)   

-- CHECK ERRORES DIA 

select * from XLS_DIM_AuditSpCentral 

where ProFechaIni >= convert(nvarchar(10),getDate()-0,120) 