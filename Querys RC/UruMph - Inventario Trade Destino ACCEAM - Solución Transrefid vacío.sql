
select  *
		from XLS_DIM_Inventario x
		inner join INVENTTABLE i on
		i.DATAAREAID = x.DataAreaID 
		and i.ITEMID = x.ItemID
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
		and id2.INVENTLOCATIONID = 'MEGAPAN-01'
		where x.DATAAREAID = '120'
		--and itr.itemid = 'T0031000012' 
		and itr.DATEPHYSICAL = '1900-01-01'
		and x.InventLocationId = 'TRANSITO'
		--and x.TransRefID = ''
		and i.ITEMGROUPID in ('PT', 'PTTR', 'MMTR')
		and x.PhysicalQty != 0
	--	group by x.ItemID

 