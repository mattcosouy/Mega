
select id.INVENTLOCATIONID, * from XLS_DIM_Inventario x
inner join purchline pl on 
pl.DATAAREAID = x.DataAreaID
and pl.PURCHID = x.TransRefID
and pl.ITEMID = x.ItemID
inner join inventdim id on
id.DATAAREAID = x.DataAreaID
and id.INVENTDIMID = pl.INVENTDIMID
where x.dataareaid = '120'
and substring(x.TransRefID, 1, 3) = ('PC_')-- Compras 
and x.InventLocationId = 'TRANSITO'
and id.INVENTLOCATIONID = 'MEGAPAN-01'

select  x.TransRefID, id.INVENTLOCATIONID, * from XLS_DIM_Inventario x
inner join INVENTTRANS it on 
it.DATAAREAID = x.DataAreaID
and it.TRANSREFID = x.TransRefID
and it.ITEMID = x.ItemID
inner join inventdim id on
id.DATAAREAID = x.DataAreaID
and id.INVENTDIMID = it.INVENTDIMID
where x.dataareaid = '120'
and substring(x.TransRefID, 1, 3) = ('086') --  Diarios Transf 
and x.InventLocationId = 'TRANSITO'
and id.INVENTLOCATIONID = 'MEGAPAN-01'


/*
select * from INVENTTRANS
where dataareaid = '120'
and TransRefID = '086_459375'
*/

 select destino, * from XLS_DIM_Inventario x
 where x.dataareaid = '120'
 --and  x.InventLocationId = 'TRANSITO'
and x.Destino  = ''