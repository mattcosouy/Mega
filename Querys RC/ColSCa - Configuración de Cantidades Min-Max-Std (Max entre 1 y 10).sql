
-- Detalle de los días configurados en Compra, Inventario y Ventas por artículo
-- COMPRAS
select	it.itemid, it.itemname, it.itemtype, it.itemgroupid, it.DimGroupId, it.primaryvendorid,
		ip.inventdimid as [DimComp] , ip.lowestQty as [MinComp], ip.highestQty as [MaxComp], ip.multipleQty as [VariasComp], 
		ip.standardQty as [StdComp],  ip.leadtime as [LeadTimeComp], 
		(select UNITID from INVENTTABLEMODULE itm
		 where itm.DATAAREAID = it.DATAAREAID and itm.ITEMID = it.ITEMID and itm.MODULETYPE = 0)  as [UnidComp]
from InventTable it, InventItemPurchSetup ip

where it.dataareaid = '050'
and ip.dataareaid = it.dataareaid
and ip.itemid = it.itemid

--and it.itemgroupid in ('PT', 'MM', 'SEMI', 'GRANEL', 'MP', 'FACON')
and substring(it.itemname, 1, 9 ) != '_DISCONT ' 
and substring(it.itemname, 1, 8 ) != 'DISCONT ' 
and substring(it.itemname, 1, 2 ) != '#_' 
and ( ip.lowestQty + ip.highestQty + ip.multipleQty + ip.standardQty ) > 0
and ip.highestQty between 1 and 10

order by it.itemgroupid, it.itemid

-- INVENTARIO

select	it.itemid, it.itemname, it.itemtype, it.itemgroupid, it.DimGroupId, it.primaryvendorid,
		ii.inventdimid as [DimInvent], ii.lowestQty as [MinInvent], ii.highestQty as [MaxInvent], ii.multipleQty as [VariasInvent], 
		ii.standardQty as [StdInvent], ii.leadtime as [LeadTimeInvent], 
		(select UNITID from INVENTTABLEMODULE itm
		 where itm.DATAAREAID = it.DATAAREAID and itm.ITEMID = it.ITEMID and itm.MODULETYPE = 1)  as [UnidInvent]
from InventTable it, InventItemInventSetup ii

where it.dataareaid = '050'
and ii.dataareaid = it.dataareaid
and ii.itemid = it.itemid

--and it.itemgroupid in ('PT', 'MM', 'SEMI', 'GRANEL', 'MP', 'FACON')
and substring(it.itemname, 1, 9 ) != '_DISCONT ' 
and substring(it.itemname, 1, 8 ) != 'DISCONT ' 
and substring(it.itemname, 1, 2 ) != '#_' 
and ( ii.lowestQty + ii.highestQty + ii.multipleQty + ii.standardQty ) > 0
and ii.highestQty between 1 and 10

order by it.itemgroupid, it.itemid

-- VENTAS

select	it.itemid, it.itemname, it.itemtype, it.itemgroupid, it.DimGroupId, it.primaryvendorid,
		iss.inventdimid as [DimVent], iss.lowestQty as [MinVent], iss.highestQty as [MaxVent], iss.multipleQty as [VariasVent], iss.standardQty as [StdVent], 
		iss.leadtime as [LeadTimeVent], 
		(select UNITID from INVENTTABLEMODULE itm
		 where itm.DATAAREAID = it.DATAAREAID and itm.ITEMID = it.ITEMID and itm.MODULETYPE = 2)  as [UnidVent]
from InventTable it, InventItemSalesSetup iss

where it.dataareaid = '050'
and iss.dataareaid = it.dataareaid
and iss.itemid = it.itemid

--and it.itemgroupid in ('PT', 'MM', 'SEMI', 'GRANEL', 'MP', 'FACON')
and substring(it.itemname, 1, 9 ) != '_DISCONT ' 
and substring(it.itemname, 1, 8 ) != 'DISCONT ' 
and substring(it.itemname, 1, 2 ) != '#_' 
and ( iss.lowestQty + iss.highestQty + iss.multipleQty + iss.standardQty ) > 0
and iss.highestQty between 1 and 10

order by it.itemgroupid, it.itemid