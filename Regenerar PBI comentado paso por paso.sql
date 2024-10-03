--PROCEDIMIENTO PARA REGENERAR PBI

--PASO 1)

SELECT COUNT(*)  

    FROM PBI_Contenedores --SUSTITUIR POR PBI A REGENERAR 

SELECT COUNT(*)  

    FROM [AZURE OLAP].[AxChiPhiOLAP].dbo.PBI_Contenedores --SUSTITUIR POR BD Y PBI A REGENERAR

--EN ESTE PASO, PASAREMOS A VERIFICAR SI LOS REGISTROS COINCIDEN EN AZURE Y ONPREM

--------------------------------------------------------------------------------------------------------------------

--PASO 2)

SELECT *  

  FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_Indice] --SUSTITUIR POR BD

  where objetoid = 'PBI_Contenedores' --875 "ORDEN" --SUSTITUIR POR PBI A REGENERAR Y POR EL NRO DE ORDEN QUE OBTENEMOS EN LA EJECUCIÓN ANTERIOR

 

SELECT *  

  FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_IndiceRecrea] 

  where objetoid = 'PBI_Contenedores' --875 "ORDEN" 




--EN ESTE PASO, VAMOS A VERIFICAR CUAL ES EL NÚMERO DE ORDEN QUE TIENE LA PBI QUE NECESITAMOS REGENERAR

/*
--Query para insertar PBI que no exista en el IndiceRecrea (ejecutar desde la BD de Azure que corresponda)

INSERT INTO [AxGuaLetOLAP].[dbo].[PBI_IndiceRecrea] (Orden, ObjetoID, Descripcion, Activo, FrecAlta, AxCorp, AxCorpFrecAlta)
VALUES (420, 'PBI_CostoReposicion', '', 'SI', 'NO', 'NO', 'NO')
*/
-----------------------------------------------------------------------------------------------------------------------


  /*--EXEC dbo.sp_GetFROMPBIRecrear 'AxChiPhiOLAP', 'AZURE OLAP', 'AxChiPhiOLAP', 'PBI_IndiceRecrea', 'Si', 830*/ 

--SUSTITUIMOS POR BD Y EL NUMERO DE ORDEN DE LA PBI, TENER SUMA ATENCIÓN A ESTE PASO, YA QUE AQUÍ PASAREMOS A REGENERAR LA INFORMACIÓN
--POR ÚLTIMO, VOLVEMOS A EJECUTAR EL PASO 1 PARA VERIFICAR QUE LA INFORMACIÓN TANTO EN AZURE COMO ONPREM COINCIDAN LOS REGISTROS


  -- NO PRESIONAR F5  


/*Chequear los registros tanto en Azure como OnPrem de una PBI. Sustituir dependiendo de la instancia y la BD
  SELECT COUNT(*)  

    FROM PBI_ComprasFacturas --SUSTITUIR POR PBI A REGENERAR 

SELECT COUNT(*)  

    FROM [AZURE OLAP].[AxChiPhiOLAP].dbo.PBI_ComprasFacturas --SUSTITUIR POR BD Y PBI A REGENERAR

SELECT  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con mas registros' FROM 
(SELECT 'LOCAL' as Origen , count(FechaSync) as con, FechaSync FROM [dbo].PBI_ComprasFacturas group by FechaSync 
UNION
SELECT 'AZURE' as Origen , count(FechaSync) as con, FechaSync FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].PBI_ComprasFacturas group by FechaSync ) p
pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv
WHERE (ISNULL(LOCAL,0)-ISNULL(AZURE,0))!=0
ORDER BY FechaSync desc

/*
Si por alguna razón el proceso de recrear se cancela y no crea la tabla OnPrem, debemos crearla de 0, sin datos, al momento de regenerar, la misma ya traera los datos desde Azure:

CREATE TABLE PBI_TransaccionesContables
(
    columna_dummy INT
);

*/