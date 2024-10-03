

select isb.PDSDISPOSITIONCODE ,* from INVENTBATCH ib
inner join INVENTSUBBATCH_MPH isb
on isb.DATAAREAID = ib.DATAAREAID
and isb.ITEMID = ib.ITEMID
and isb.INVENTBATCHID = ib.INVENTBATCHID
and isb.PDSDISPOSITIONCODE = 'Rechazado'
where ib.dataareaid = '125'
and substring(ib.ITEMID , 1, 3) != '120'
and (ib.EXPDATE >= '2022/03/21' or ib.EXPDATE = '1900/01/01')
--and ib.EXPDATE between '1900/01/02' and '2022/03/18'
 --'02/01/1900' and '18/03/2022'
