/*

update XLS_DIM_Inventario 
		set Destino = id.INVENTLOCATIONID 
		from XLS_DIM_Inventario x
		inner join purchline pl on 
		pl.DATAAREAID = x.DataAreaID
		and pl.PURCHID = x.TransRefID
		and pl.ITEMID = x.ItemID
		inner join inventdim id on
		id.DATAAREAID = x.DataAreaID
		and id.INVENTDIMID = pl.INVENTDIMID
		where x.dataareaid = '120' -- Solo aplica para Megalabs
		and substring(x.TransRefID, 1, 3) = ('PC_')-- Compras 
		and x.InventLocationId = 'TRANSITO'
		and id.INVENTLOCATIONID = 'MEGAPAN-01'

		update XLS_DIM_Inventario 
		set Destino =  'MEGAPAN-01'
		from XLS_DIM_Inventario x
		inner join INVENTTABLE i on
		i.DATAAREAID = x.DataAreaID 
		and i.ITEMID = x.ItemID
		inner join INVENTTRANS it on 
		it.DATAAREAID = x.DataAreaID
		and it.TRANSREFID = x.TransRefID
		and it.ITEMID = x.ItemID
		inner join inventdim id on
		id.DATAAREAID = x.DataAreaID
		and id.INVENTDIMID = it.INVENTDIMID
		where x.dataareaid = '120' -- Solo aplica para Megalabs
		and x.InventLocationId = 'TRANSITO'
		and substring(x.TransRefID, 1, 3) = ('086') --  Diarios Transf 
		and id.INVENTLOCATIONID = 'MEGAPAN-01'
		--and i.ITEMGROUPID in ('PT', 'PTTR', 'MMTR')

		update XLS_DIM_Inventario 
		set Destino =  'MEGAPAN-01'
		from XLS_DIM_Inventario x
		inner join INVENTTABLE i on
		i.DATAAREAID = x.DataAreaID 
		and i.ITEMID = x.ItemID
/*		inner join INVENTTRANS it on 
		it.DATAAREAID = x.DataAreaID
		and it.TRANSREFID = x.TransRefID
		and it.ITEMID = x.ItemID
		inner join inventdim id on
		id.DATAAREAID = x.DataAreaID
		and id.INVENTDIMID = it.INVENTDIMID*/
		where x.dataareaid = '120' -- Solo aplica para Megalabs
		and x.InventLocationId = 'TRANSITO'
		and x.TransRefID = ''
		--and x.PhysicalQty != 0
		and i.ITEMGROUPID in ('PT', 'PTTR', 'MMTR')
		--and substring(x.TransRefID, 1, 3) = ('086') --  Diarios Transf 
		--and id.INVENTLOCATIONID = 'MEGAPAN-01'

/*