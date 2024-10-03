/*
    Comparte Azre view vs the table onprem to check
id there is any different columns
*/
--______________________________________________________________________________________
    SELECT * into #AzureTable
FROM [AZURE OLAP].[AxDomLetOLAP].[information_schema].[columns] --Vista de azure
WHERE table_Schema ='dbo' and table_name = 'PBI_Cobranza';

 

    SELECT * into #OnpremTable
FROM information_schema.columns                                    --Tabla onprem        
WHERE table_Schema ='dbo' and table_name = 'PBI_Cobranza';
--______________________________________________________________________________________
SELECT
COALESCE(A.Column_Name, B.Column_Name) AS [Column]
,CASE 
    WHEN (A.Column_Name IS NULL and B.Column_Name IS NOT NULL) THEN 'Column - [' + B.Column_Name + ']  exists ONPREM Only' 
    WHEN (B.Column_Name IS NULL and A.Column_Name IS NOT NULL) THEN 'Column - [' + A.Column_Name + ']  exist in AZURE Only' 
    WHEN  A.Column_Name = B.Column_Name                           THEN 'Column - [' + A.Column_Name + ']  exists in both Table'
END AS Remarks,
CASE WHEN (B.Column_Name IS NULL and A.Column_Name IS NOT NULL) THEN 'REGENERAR'
END AS diferencias
FROM #AzureTable A
FULL JOIN #OnpremTable B ON A.Column_Name = B.Column_Name

 


--______________________________________________________________________________________
drop table #AzureTable;
drop table #OnpremTable;