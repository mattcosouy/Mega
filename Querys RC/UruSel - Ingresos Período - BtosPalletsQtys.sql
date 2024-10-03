/* 2020-05-05 - RC - Mediantes esta consulta se resuelven las necesidades de información de Selenín para obtener los ingresos de un período por 
Cliente La necesidad y los criterios fueron comunicados por Nico Castillo.
Se debe mostrar la cantidad de bultos y pallets, así como la cantidad y su unidad de medida.
*/
if exists (select name
		  from sysobjects where name = 'XLS_INV_IngresosPeriodo' AND type = 'P')
  drop procedure dbo.XLS_INV_IngresosPeriodo
go 

-- EXEC dbo.XLS_INV_IngresosPeriodo '125',  '2020', '04'
create procedure dbo.XLS_INV_IngresosPeriodo 
  @AREA			varchar(04),										  -- Empresa de Ejecución				
  @ANIO			varchar(04),										  -- Año de ejecución
  @MES			varchar(02)											  -- Mes de ejecución
----------------------------------------------------------------------------
as
set nocount on
select  wjt.INVENTTRANSREFID as [Operación], it.DESCRIPTION as [Descripción], i.ITEMID as [Artículo], i.ITEMNAME as [NombreArtículo], 
wt.POSTEDDATETIME as [FechaRegistro], id.INVENTCONTAINERID as [Bulto],id.WMSPALLETID as [Pallet], id.INVENTLEGALNUMID as [DUA], 
cast(wjt.QTY as real) as [Cantidad], itm.UNITID as [UnidMedida], i.DIMENSION4_ as [Propietario],
	wjt.INVENTTRANSREFID + ';' + it.DESCRIPTION + ';' +  i.ITEMID + ';' +  i.ITEMNAME + ';' +  
	convert(varchar, wt.POSTEDDATETIME,103 ) + ';' +  id.INVENTCONTAINERID + ';' +  id.WMSPALLETID + ';' + id.INVENTLEGALNUMID + ';' +  
	convert(nvarchar,cast(wjt.QTY as real) ) + ';' +  itm.UNITID + ';' + i.DIMENSION4_ 
as [TXT]

from WMSJOURNALTRANS wjt
left join WMSJOURNALTABLE wt		on wt.DATAAREAID  = wjt.DATAAREAID and wt.JOURNALID = wjt.JOURNALID
left join INVENTJOURNALTABLE it		on it.DATAAREAID  = wjt.DATAAREAID and it.JOURNALID = wjt.INVENTTRANSREFID	and it.JOURNALTYPE = 0 -- Movimiento
left join inventdim id				on id.DATAAREAID = wjt.DATAAREAID  and id.INVENTDIMID = wjt.INVENTDIMID
join INVENTTABLE i					on i.DATAAREAID = wjt.DATAAREAID   and i.ITEMID = wjt.ITEMID
join INVENTTABLEMODULE itm			on itm.DATAAREAID = wjt.DATAAREAID and itm.ITEMID = wjt.ITEMID				and itm.MODULETYPE = 0 -- Inventario
where wjt.DATAAREAID = @AREA	
and month(wt.POSTEDDATETIME) = @MES
and year(wt.POSTEDDATETIME) = @ANIO

