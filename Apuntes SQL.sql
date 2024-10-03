/*                                                             APUNTES DE SQL - MATÍAS GARCÍA                                                               */


/*    CON ESTA QUERY LOGRO VER SI EXISTEN BLOQUEOS EXISTENTES POR PROCESOS EJECUTANDOSE EN EL MOMENTO, DE FORMA TAL QUE ESTÁN CONSUMIENDO INFORMACIÓN DIRECTAMENTE A LA BASE   */

WITH cteBL (session_id, blocking_these) AS 
(SELECT s.session_id, blocking_these = x.blocking_these FROM sys.dm_exec_sessions s 
CROSS APPLY    (SELECT isnull(convert(varchar(6), er.session_id),'') + ', '  
                FROM sys.dm_exec_requests as er
                WHERE er.blocking_session_id = isnull(s.session_id ,0)
                AND er.blocking_session_id <> 0
                FOR XML PATH('') ) AS x (blocking_these)
)
SELECT s.session_id, blocked_by = r.blocking_session_id, bl.blocking_these
, batch_text = t.text, input_buffer = ib.event_info, * 
FROM sys.dm_exec_sessions s 
LEFT OUTER JOIN sys.dm_exec_requests r on r.session_id = s.session_id
INNER JOIN cteBL as bl on s.session_id = bl.session_id
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) t
OUTER APPLY sys.dm_exec_input_buffer(s.session_id, NULL) AS ib
WHERE blocking_these is not null or r.blocking_session_id > 0
ORDER BY len(bl.blocking_these) desc, r.blocking_session_id desc, r.session_id;

 

SELECT 
    req.session_id
    , req.total_elapsed_time/1000 AS duration_s
    , req.cpu_time AS cpu_time_ms
    , req.total_elapsed_time - req.cpu_time AS wait_time
    , req.logical_reads
    , SUBSTRING (REPLACE (REPLACE (SUBSTRING (ST.text, (req.statement_start_offset/2) + 1, 
       ((CASE statement_end_offset
           WHEN -1
           THEN DATALENGTH(ST.text)  
           ELSE req.statement_end_offset
         END - req.statement_start_offset)/2) + 1) , CHAR(10), ' '), CHAR(13), ' '), 
      1, 512)  AS statement_text  ,
      *
FROM sys.dm_exec_requests AS req
    CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST
ORDER BY total_elapsed_time DESC;

/*   CON ESTE QUERY VERIFICO EL NOMBRE DE UNA COLUMNA, EL TIPO DE DATO Y EL LARGO DEL MISMO. DE ESTA MANERA PUEDO COMPARAR LOS RESULTADOS OBTENIDOS AQUÍ CON LA OTRA TABLA IMPLICADA Y VERIFICAR SI
TENGO COLUMNAS MAS O MENOS O SI EL LARGO DE UN TIPO DE DATO FUE MODIFICADO.   */

select column_name, data_type, character_maximum_length    
from information_schema.columns  
where table_name = 'Venta'

/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/


/*                                                                   PROCEDIMIENTO PARA REGENERAR PBI                                                              */

 --EN ESTE PASO, PASAREMOS A VERIFICAR SI LOS REGISTROS COINCIDEN EN AZURE Y ONPREM
SELECT COUNT(*)  

    FROM PBI_Contenedores --SUSTITUIR POR PBI A REGENERAR 

SELECT COUNT(*)  

    FROM [AZURE OLAP].[AxChiPhiOLAP].dbo.PBI_Contenedores --SUSTITUIR POR BD Y PBI A REGENERAR

--------------------------------------------------------------------------------------------------------------------
 --EN ESTE PASO, VAMOS A VERIFICAR CUAL ES EL NÚMERO DE ORDEN QUE TIENE LA PBI QUE NECESITAMOS REGENERAR
SELECT *  

  FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_Indice] --SUSTITUIR POR BD

  where objetoid = 'PBI_Contenedores' --875 "ORDEN" --SUSTITUIR POR PBI A REGENERAR Y POR EL NRO DE ORDEN QUE OBTENEMOS EN LA EJECUCIÓN ANTERIOR

 
SELECT *  

  FROM [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_IndiceRecrea] 

  where objetoid = 'PBI_Contenedores' --875 "ORDEN" 

 --QUERY PARA INSERTAR PBI QUE NO EXISTA EN EL INDICERECREA (EJECUTAR DESDE LA BD DE AZURE QUE CORRESPONDA)

INSERT INTO [AxGuaLetOLAP].[dbo].[PBI_IndiceRecrea] (Orden, ObjetoID, Descripcion, Activo, FrecAlta, AxCorp, AxCorpFrecAlta)
VALUES (420, 'PBI_CostoReposicion', '', 'SI', 'NO', 'NO', 'NO')

-----------------------------------------------------------------------------------------------------------------------
--SUSTITUIMOS POR BD Y EL NUMERO DE ORDEN DE LA PBI, TENER SUMA ATENCIÓN A ESTE PASO, YA QUE AQUÍ PASAREMOS A REGENERAR LA INFORMACIÓN POR ÚLTIMO, VOLVEMOS A EJECUTAR EL PASO 1 PARA VERIFICAR QUE LA INFORMACIÓN TANTO EN AZURE COMO ONPREM COINCIDAN LOS REGISTROS

 --EXEC dbo.sp_GetFROMPBIRecrear 'AxChiPhiOLAP', 'AZURE OLAP', 'AxChiPhiOLAP', 'PBI_IndiceRecrea', 'Si', 830

-- Con el siguiente Query, podemos ver en detalle una PBI puntual y ver en que fechas se genero el desfasaje de datos

SELECT FechaSync,
       ISNULL(AZURE, 0) AS AZURE,
       ISNULL(LOCAL, 0) AS LOCAL,
       ISNULL(LOCAL, 0) - ISNULL(AZURE, 0) AS '+ = local con mas registros'
FROM (
    SELECT 'LOCAL' AS Origen, COUNT(FechaSync) AS con, FechaSync
    FROM [dbo].PBI_ComprasFacturas
    GROUP BY FechaSync

    UNION

    SELECT 'AZURE' AS Origen, COUNT(FechaSync) AS con, FechaSync
    FROM [AZURE OLAP].[AxPanLetOLAP].[dbo].PBI_ComprasFacturas
    GROUP BY FechaSync
) p
PIVOT (SUM(con) FOR [Origen] IN ([AZURE], [LOCAL])) AS tblpiv
WHERE (ISNULL(LOCAL, 0) - ISNULL(AZURE, 0)) != 0
ORDER BY FechaSync DESC;

 -- SI POR ALGUNA RAZÓN EL PROCESO DE RECREAR SE CANCELA Y NO CREA LA TABLA ONPREM, DEBEMOS CREARLA DE 0, SIN DATOS, AL MOMENTO DE REGENERAR, LA MISMA YA TRAERA LOS DATOS DESDE AZURE:

CREATE TABLE PBI_TransaccionesContables
(
    columna_dummy INT
);

/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/


-----------------------------------------------------------------------------------------------------------------------
/****** CON ESTE COUNT VEO LOS REGISTROS ACTUALES EN UNA PBI. LA CLAUSULA WITH NOLOCK ME VA A MOSTRAR DATOS QUE AUN ESTAN EN PROCESO DE SER MODIFICADOS POR TRANSACCIONES  ******/


SELECT COUNT(*)  
FROM [dbo].[PBI_InventFisicoeLog] WITH (NOLOCK);


/****** TRACKING CHECK GET AZ  EJECUTAR EN FACADE1 ******/
SELECT TOP (1000) [RefId]
      ,[Orden]
      ,[ObjetoID]
      ,[DataBase]
      ,[FecInicio]
      ,[FecFin]
      ,[Demora] as DemoraSeg
      ,[Detalle]
  FROM [dbo].[Dy365_Indice_Tracking]
  order by FecInicio desc


/****** TRACKING CHECK GET PBI  ******/
  SELECT TOP (1000) [RefId]
      ,[Orden]
      ,[ObjetoID]
      ,[DataBase]
      ,[FecInicio]
      ,[FecFin]
      ,[Demora] as DemoraSeg
      ,[Detalle]
  FROM [dbo].[PBI_IndiceCAIC_Tracking]
  order by FecInicio desc
  
  
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/


/* CON EL SIGUIENTE QUERY PUEDO VER EN DONDE SE ESTA USANDO UNA DETERMINADA TABLA EN UNA BD*/

SELECT OBJECT_NAME(referencing_id) AS ReferencingObject
FROM sys.sql_expression_dependencies
WHERE referenced_entity_name = 'XLS_DIM_AuditSpCentral';