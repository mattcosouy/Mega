SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con mas registros' FROM 
(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_TipoDeCambio group by FechaSync 
UNION
SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].PBI_TipoDeCambio group by FechaSync ) p
pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv
WHERE (ISNULL(LOCAL,0)-ISNULL(AZURE,0))!=0
ORDER BY FechaSync desc