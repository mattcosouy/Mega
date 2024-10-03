-- Correr esto en DOMLET , DOMROW , CHIPHI para buscar diferencias. Siempre debemos verificar que no existan diferencias en fechas que sean anteriores al mes corriente -1. Si estamos parados en
-- marzo, no debemos tener diferencias que sean posteriores al 1 de febrero

declare @FControl datetime = '2023-01-17 03:48:14.837' -- Debemos ingresar la fecha sync que veamos con diferencias 

SELECT COUNT ( distinct(RecIdDiario) ) , FechaConta , FechaSync FROM [Azure OLAP].[AxDomLetOLAP].[dbo].[PBI_TransaccionesContables] where FechaSync >= @FControl 
group by FechaConta , FechaSync 
order by FechaConta 


SELECT COUNT ( distinct(RecIdDiario) ) , FechaConta FROM [dbo].[PBI_TransaccionesContables] where FechaSync >= @FControl 
group by FechaConta 
order by FechaConta 

/***************************************************************************************************************************************************************/  

-- Ejecutar para corregir 1 mes especifico

declare @MES nvarchar(2) = '01'  
declare @FI date = '2023-'+@MES+'-01'  
declare @FF date = EOMONTH(@FI) 
Select @FI , @FF --> Hasta aquí para testear fechas 

SELECT distinct fechasync FROM [Azure OLAP].[AxDomLetOLAP].[dbo].[PBI_TransaccionesContables] where [FechaConta] >= @FI and [FechaConta] <= @FF 

SELECT distinct fechasync FROM [dbo].[PBI_TransaccionesContables] where [FechaConta] >= @FI and [FechaConta] <= @FF 

/***************************************************************************************************************************************************************/
-- Con la siguiente ejecución, veremos en que fechas tenemos diferencias de registros, sea OnPrem o Azure

SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con mas registros' FROM 
(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_TransaccionesContables group by FechaSync 
UNION
SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxDomLetOLAP].[dbo].PBI_TransaccionesContables group by FechaSync ) p
pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv
WHERE (ISNULL(LOCAL,0)-ISNULL(AZURE,0))!=0
ORDER BY FechaSync desc

/***************************************************************************************************************************************************************/
-- Con la siguiente ejecución, compararemos si los registros coinciden tanto en Azure como OnPrem

SELECT COUNT(*)  

    FROM PBI_TransaccionesContables 

SELECT COUNT(*)  

    FROM [AZURE OLAP].[AxDomLetOLAP].dbo.PBI_TransaccionesContables