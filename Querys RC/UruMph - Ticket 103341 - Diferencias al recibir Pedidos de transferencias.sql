
select i.VOUCHER, l.transrefid, i.transdate, l.itemid, SUM(qty) from inventtransposting i
join INVENTTRANS l on
i.DATAAREAID = l.DATAAREAID
and i.INVENTTRANSID = l.INVENTTRANSID
and i.VOUCHER = l.VOUCHER
and i.TRANSDATE = l.DATEFINANCIAL
and i.INVENTTRANSPOSTINGTYPE = 1
where i.DATAAREAID = '120'
and substring(l.VOUCHER,1,3) = '099'
--and ISPOSTED = 1
--and l.VOUCHER = '099_000017015'
group by i.VOUCHER,  l.transrefid, i.transdate, l.itemid
having SUM(qty) != 0
order by TRANSREFID desc