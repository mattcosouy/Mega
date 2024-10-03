/*

sp_who2

select count(*)
from XLS_DIM_Inventario x

	CREATE TABLE dbo.XLS_INV_CompromisosTodos_ControlPerf 	(Paso varchar(50), Tipo varchar(50), FechaHora Datetime )
	TRUNCATE TABLE dbo.XLS_INV_CompromisosTodos_ControlPerf

	insert into dbo.XLS_INV_CompromisosTodos_ControlPerf
	select 'Paso 1', 'Fin', getutcdate()
	
	insert into dbo.XLS_INV_CompromisosTodos_ControlPerf
	select 'Paso 2', 'Ini', getutcdate()
*/


  declare @FECHA_FIN datetime
  --set @MESATRAS = ABS(isnull((@MESATRAS), 0))* -1							-- Por Omision Mes Corriente. Como usara MMAct es por -1
  set @FECHA_FIN = (select distinct x.MMFin from xls_dim_tiempo x where x.MMAct =	0 )
  -- En el caso de pedir el mes en curso , ajusta la fecha a hoy sin hora para que el proceso lo tome				
  set @FECHA_FIN = (case when @FECHA_FIN > getdate() then convert(varchar(10), getdate(), 112) else @FECHA_FIN end)
select id2.INVENTLOCATIONID  
from XLS_DIM_Inventario x
		inner join INVENTTABLE i on
		i.DATAAREAID = x.DataAreaID 
		and i.ITEMID = x.ItemID
		and i.ITEMGROUPID in ('PT', 'PTTR', 'MMTR')
		inner join inventtrans itr on
		itr.DATAAREAID = x.DataAreaID 
		and itr.ITEMID = x.ItemID
		inner join INVENTDIM id on
		id.DATAAREAID = itr.DATAAREAID 
		and id.INVENTDIMID = itr.INVENTDIMID
		and id.INVENTLOCATIONID = 'TRANSITO'
		inner join SHIPLINE sp on
		sp.DATAAREAID = itr.DATAAREAID
		and sp.SHIPID = itr.SHIPID
		and sp.ITEMID = itr.ITEMID
		left join INVENTDIM id2 on
		id2.DATAAREAID = sp.DATAAREAID 
		and id2.INVENTDIMID = sp.INVENTDIMID
		where x.DATAAREAID = '120'
		--and itr.itemid = 'T0031000012' 
		and (itr.DATEPHYSICAL = '1900-01-01' 
			or (year(itr.DATEPHYSICAL) = year(@FECHA_FIN) and month(itr.DATEPHYSICAL) >= month(@FECHA_FIN) )
			or (year(itr.DATEPHYSICAL) > year(@FECHA_FIN) )		)
		and x.InventLocationId = 'TRANSITO'
		--and x.TransRefID = ''
		and x.PhysicalQty != 0