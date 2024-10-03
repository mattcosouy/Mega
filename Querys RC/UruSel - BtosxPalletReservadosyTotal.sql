/* SLN - Bultos reservados por diario y bultos totales en el Pallet.
*/
select 
it.transrefid,  it.itemid, id.inventbatchid, id.wmspalletid ,count(id.inventcontainerid) as [Bultos Reservados],
(select  count(id1.inventcontainerid) 
	from inventsum im
	join INVENTDIM id1
	on id1.dataareaid = im.dataareaid
	and id1.inventdimid = im.inventdimid
	and id1.wmspalletid = id.wmspalletid
	and id1.inventbatchid = id.inventbatchid
	and id1.inventcontainerid != ''
	and im.itemid = it.itemid
	where im.dataareaid = '125'
	group by id1.wmspalletid , im.itemid
) as [Total Bultos]
from inventtrans it
join INVENTDIM id
on id.dataareaid = it.dataareaid
and id.inventdimid = it.inventdimid
and id.wmspalletid != ''
and id.inventcontainerid != ''
and id.inventbatchid != ''
where it.dataareaid = '125'
and statusissue = 4 --Fís.reservada
and it.transtype = 4 -- Diarios Egreso
group by it.transrefid, it.itemid, id.inventbatchid, id.wmspalletid 
order by it.transrefid, it.itemid, id.inventbatchid, id.wmspalletid 