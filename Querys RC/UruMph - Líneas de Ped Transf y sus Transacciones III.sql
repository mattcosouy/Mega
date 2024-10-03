
if exists (select name from sysobjects where name = 'tmpCtrlPTlines_RC')
drop table tmpCtrlPTlines_RC 
--select * from tmpCtrlPTlines_RC 

select z.TRANSFERID, z.itemid, z.INVENTTRANSID, b.INVENTLOCATIONID, b.inventbatchid , round(SUM( a.QTY),0) as qty into tmpCtrlPTlines_RC from INVENTTRANSFERLINE z
inner join INVENTTRANSFERTABLE n
on n.DATAAREAID = z.DATAAREAID and n.transferid = z. TRANSFERID 
inner join INVENTTRANS a
on a.DATAAREAID = z.DATAAREAID and a.INVENTTRANSID = z.INVENTTRANSID
inner join INVENTDIM b
on  a.DATAAREAID = b.dataareaid and a.inventdimid = b.inventdimid
where z.DATAAREAID = 120 and  n.TRANSFERSTATUS < 2 and z.REMAINSTATUS != 0
group by z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid 

union
select z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid , round(SUM(h.QTY),0) as qty from INVENTTRANSFERLINE z
inner join INVENTTRANSFERTABLE n
on n.DATAAREAID = z.DATAAREAID and n.transferid = z. TRANSFERID 
inner join INVENTTRANS h
on h.DATAAREAID = z.DATAAREAID and h.INVENTTRANSID = z.InventTransIdTransitTo
inner join INVENTDIM b
on  h.DATAAREAID = b.dataareaid and h.inventdimid = b.inventdimid
where z.DATAAREAID = 120 and  n.TRANSFERSTATUS < 2 and z.REMAINSTATUS != 0
group by z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid 

union
select z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid , round(SUM(j.QTY),0) as qty from INVENTTRANSFERLINE z
inner join INVENTTRANSFERTABLE n
on n.DATAAREAID = z.DATAAREAID and n.transferid = z. TRANSFERID 
inner join INVENTTRANS j
on j.DATAAREAID = z.DATAAREAID and j.INVENTTRANSID = z.InventTransIdTransitFrom
inner join INVENTDIM b
on  j.DATAAREAID = b.dataareaid and j.inventdimid = b.inventdimid
where z.DATAAREAID = 120 and  n.TRANSFERSTATUS < 2 and z.REMAINSTATUS != 0
group by z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid 

union 
select z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid , round(SUM(k.QTY),0) as qty from INVENTTRANSFERLINE z
inner join INVENTTRANSFERTABLE n
on n.DATAAREAID = z.DATAAREAID and n.transferid = z. TRANSFERID 
inner join INVENTTRANS k
on k.DATAAREAID = z.DATAAREAID and k.INVENTTRANSID = z.InventTransIdReceive
inner join INVENTDIM b
on  k.DATAAREAID = b.dataareaid and k.inventdimid = b.inventdimid
where z.DATAAREAID = 120 and  n.TRANSFERSTATUS < 2 and z.REMAINSTATUS != 0
group by z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid 
order by z.TRANSFERID, z.itemid, z.INVENTTRANSID,  b.INVENTLOCATIONID, b.inventbatchid 

select xx.TRANSFERID, xx.itemid, xx.INVENTTRANSID,  xx.INVENTLOCATIONID, xx.inventbatchid , round(SUM( xx.QTY),0) as qty from tmpCtrlPTlines_RC xx
group by xx.TRANSFERID, xx.itemid, xx.INVENTTRANSID,  xx.INVENTLOCATIONID, xx.inventbatchid 
having round(SUM( xx.QTY),0) != 0
order by xx.TRANSFERID, xx.itemid, xx.INVENTTRANSID,  xx.INVENTLOCATIONID, xx.inventbatchid 
