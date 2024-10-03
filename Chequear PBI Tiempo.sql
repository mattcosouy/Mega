SELECT FechaVig, * from PBI_Tiempo where DdVig = 0 

SELECT FechaVig, *  FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].[PBI_Tiempo] where DdVig = 0 


--PROCEDIMIENTO PARA REGENERAR PBI

--PASO 1)

SELECT COUNT(*)  

    FROM PBI_Tiempo --SUSTITUIR POR PBI A REGENERAR 

SELECT COUNT(*)  

    FROM [AZURE OLAP].[AxPanLetOLAP].dbo.PBI_Tiempo --SUSTITUIR POR BD Y PBI A REGENERAR

--EN ESTE PASO, PASAREMOS A VERIFICAR SI LOS REGISTROS COINCIDEN EN AZURE Y ONPREM

--------------------------------------------------------------------------------------------------------------------

--PASO 2)

SELECT *  

  FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].[PBI_Indice] --SUSTITUIR POR BD

  where objetoid = 'PBI_Tiempo' --230 "ORDEN" --SUSTITUIR POR PBI A REGENERAR Y POR EL NRO DE ORDEN QUE OBTENEMOS EN LA EJECUCIÓN ANTERIOR

 

SELECT *  

  FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].[PBI_IndiceRecrea] 

  where objetoid = 'PBI_Tiempo' --230 "ORDEN" 


--EN ESTE PASO, VAMOS A VERIFICAR CUAL ES EL NÚMERO DE ORDEN QUE TIENE LA PBI QUE NECESITAMOS REGENERAR


-----------------------------------------------------------------------------------------------------------------------


  /*--EXEC dbo.sp_GetFROMPBIRecrear 'AxPanLetOLAP', 'AZURE OLAP', 'AxPanLetOLAP', 'PBI_IndiceRecrea', 'Si', 230*/ 

--SUSTITUIMOS POR BD Y EL NUMERO DE ORDEN DE LA PBI, TENER SUMA ATENCIÓN A ESTE PASO, YA QUE AQUÍ PASAREMOS A REGENERAR LA INFORMACIÓN
--POR ÚLTIMO, VOLVEMOS A EJECUTAR EL PASO 1 PARA VERIFICAR QUE LA INFORMACIÓN TANTO EN AZURE COMO ONPREM COINCIDAN LOS REGISTROS


  -- NO PRESIONAR F5  
