-- Resuelve ticket #104717 - Relación de Pedidos de Compra con Notas de Abono de Lorena Cevallos - Ax2009

select it.TRANSREFID as PedComp, i.itemid as Artículo, iv.ITEMNAME as ArtNombre, i.Transdate as ProcFecha, 
	  sum(i.QTYSETTLED) as CantComp, i.COSTAMOUNTSETTLED as CompValor
from INVENTSETTLEMENT i
join inventtrans it on
i.DATAAREAID = it.DATAAREAID
and i.TRANSRECID = it.RECID
and it.transtype = 3  --Pedido de Compra 
join inventtable iv on
iv.DATAAREAID = i.DATAAREAID
and iv.ITEMID = i.ITEMID
/*join purchline p on 
p.DATAAREAID = it.DATAAREAID
and p.purchid = it.TRANSREFID*/
where i.dataareaid = '050'
and iv.itemgroupid != 'FACON'
and i.settletransid in --'092_00675703'
	(	select i1.SETTLETRANSID /*, count(i.SETTLETRANSID)*/ from INVENTSETTLEMENT i1
		join inventtrans it on
		i1.DATAAREAID = it.DATAAREAID
		and i1.TRANSRECID = it.RECID
		where i1.DATAAREAID = '050'
		--and substring(i.voucher,1,4) = '089_'
		and it.transtype = 3  --Pedido de Compra 
		group by i1.SETTLETRANSID 
		--order by voucher
		having count(i1.SETTLETRANSID) > 1 )
group by it.TRANSREFID, i.itemid, iv.ITEMNAME, i.Transdate, i.SETTLETRANSID, abs(i.QTYSETTLED), abs(i.COSTAMOUNTSETTLED)
order by PedComp, i.SETTLETRANSID