/* 20200602 - RC - Actualiza masivamente el check Consumo finalizado.
Los criterios de filtro fueron tomados de un mail enviado por Federica Cura el 02/06/2020

Estimados, buenas tardes.
Estuvimos analizando información que arrojan los indicadores automatizados y encontramos lotes que cumplen el criterio mencionado anteriormente que están sin el check encendido. 
El criterio definido es el siguiente: los códigos tipo fórmula, plantilla 03.30, para cuyos correspondientes lotes haya disponible 0 en el almacén Pta-INT.P.
Podrán encender el check de forma masiva? Necesitan un listado detallado de los mismos?
Muchas gracias. Saludos, Federica 


select ib.ITEMID, ib.INVENTBATCHID from INVENTTABLE i , INVENTDIM id, inventsum ism,  INVENTBATCH ib
where i.DATAAREAID = '120' and i.ITEMTYPE = 3 and i.RecordTemplate_MPH = '03.30 Material Productivo'
and ism.DATAAREAID = i.DATAAREAID and ism.itemid = i.ITEMID and ism.PHYSICALINVENT = 0 
and id.DATAAREAID = i.DATAAREAID and ism.inventdimid = id.INVENTDIMID  and id.INVENTLOCATIONID = 'PTA-INT.P' 
and ib.DATAAREAID = i.DATAAREAID and i.ITEMID = ib.ITEMID and id.INVENTBATCHID = ib.INVENTBATCHID and ib.FINISHEDCONSUMPTION_MPH = 0
group by ib.ITEMID, ib.INVENTBATCHID
*/

select ib.ITEMID, ib.INVENTBATCHID  --ib.recid  --
--into z_borrame
from INVENTBATCH ib
join INVENTTABLE i on ib.DATAAREAID = i.DATAAREAID and i.ITEMID = ib.ITEMID and i.ITEMTYPE = 3 
				  and i.RecordTemplate_MPH in  ('03.30 Material Productivo', 'x03.30 - Semielaborado')
join INVENTDIM id on id.DATAAREAID = i.DATAAREAID  and id.INVENTLOCATIONID = 'PTA-INT.P' 
				  and id.INVENTBATCHID = ib.INVENTBATCHID 
join inventsum ism on ism.DATAAREAID = i.DATAAREAID and ism.inventdimid = id.INVENTDIMID  
				  and ism.itemid = i.ITEMID and ism.PHYSICALINVENT = 0 and CLOSED = 0
where i.DATAAREAID = '120' and ib.FINISHEDCONSUMPTION_MPH = 0 --and i.itemid = 'CRE387008' --and ib.INVENTBATCHID = 'M02534'
group by ib.ITEMID, ib.INVENTBATCHID  --ib.recid  
/*
select * from inventsum ism 
join INVENTDIM id on id.DATAAREAID = ism.DATAAREAID and ism.inventdimid = id.INVENTDIMID  and id.INVENTLOCATIONID = 'PTA-INT.P' 
where ism.DATAAREAID = '120' /*and ib.FINISHEDCONSUMPTION_MPH = 0 */ and ism.itemid = 'PVO990004' and id.INVENTBATCHID = 'M02534'
and ism.PHYSICALINVENT = 0 
select i.RecordTemplate_MPH,* from INVENTTABLE i 
where i.DATAAREAID = '120' and i.ITEMTYPE = 3 and i.RecordTemplate_MPH like '%3.30 Material Productivo%'
*/

/*
begin tran 
update inventbatch 
set FINISHEDCONSUMPTION_MPH = 1
from z_borrame
where inventbatch.RECID = z_borrame.RECID
--commit
--rollback
