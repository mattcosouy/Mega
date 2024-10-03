--CON EL SIGUIENTE QUERY VAMOS A CHEQUEAR SI UNA PBI SE ENCUENTRA EN EL INDICE O NO. DEBEMOS MODIFICAR LA BD EN LA CUAL ESTAMOS Y MENCIONAR EN EL WHERE A QUE PBI QUEREMOS LLEGAR

SELECT * from [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_Indice] 
where objetoid = 'PBI_TipoDeCambio'

------------------------------------------------------------------------------------------------------------------------------------------------

--CON EL SIGUIENTE QUERY, NOS FIJAMOS LA FECHA DE SINCRONIZACION MAXIMA DE UNA PBI

SELECT max(fechasync) from [AZURE OLAP].[AxChiPhiOLAP].[dbo].[PBI_TipoDeCambio]