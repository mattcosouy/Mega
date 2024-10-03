--REGENERAR PBI EN CHIPHI
SELECT COUNT(*) FROM PBI_ComprasFacturas 

SELECT COUNT(*) FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT distinct fechasync FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con más registros' FROM  

(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_ComprasFacturas group by FechaSync  

UNION 

SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].PBI_ComprasFacturas group by FechaSync ) p 

pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv 

ORDER BY FechaSync desc 

-----------------------------------------------------------------------------------------------------------------------------------------------------
--REGENERAR PBI EN DOMROW
SELECT COUNT(*) FROM PBI_ComprasFacturas 

SELECT COUNT(*) FROM [AZURE OLAP].[AxDomRowOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT distinct fechasync FROM [AZURE OLAP].[AxDomRowOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con más registros' FROM  

(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_ComprasFacturas group by FechaSync  

UNION 

SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxDomRowOLAP].[dbo].PBI_ComprasFacturas group by FechaSync ) p 

pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv 

ORDER BY FechaSync desc 

-----------------------------------------------------------------------------------------------------------------------------------------------------
--REGENERAR PBI DOMLET
SELECT COUNT(*)  
FROM PBI_ComprasFacturas 

SELECT COUNT(*) FROM [AZURE OLAP].[AxDomLetOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT distinct fechasync  
FROM [AZURE OLAP].[AxDomLetOLAP].[dbo].[PBI_ComprasFacturas]  

SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con más registros'  FROM  

(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_ComprasFacturas group by FechaSync  

UNION 

SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxDomLetOLAP].[dbo].PBI_ComprasFacturas group by FechaSync ) p 

pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv 

ORDER BY FechaSync desc 
-----------------------------------------------------------------------------------------------------------------------------------------------------

--REGENERAR PBI PANLET
SELECT COUNT(*) FROM PBI_ComprasFacturas 

SELECT COUNT(*) FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT distinct fechasync FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].[PBI_ComprasFacturas] 

SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con más registros' FROM  

(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_ComprasFacturas group by FechaSync  

UNION 

SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].PBI_ComprasFacturas group by FechaSync ) p 

pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv 

ORDER BY FechaSync DESC 