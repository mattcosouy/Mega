
/*
select * into PRICEDISCTABLE_Ticket120406 from PRICEDISCTABLE

select /* ITEMRELATION, count(ITEMRELATION)*/ * from PRICEDISCTABLE p
inner join Ticket120406 t
on t.Artcod = p.ITEMRELATION
where p.DATAAREAID = '120'
and todate = '2022-12-31 00:00:00.000' 
and ACCOUNTRELATION = 'DOM-LETERAGO'
--and p.ITEMRELATION in ('7016952', '7022461')

group by ITEMRELATION
having count(ITEMRELATION) > 1
order by ITEMRELATION
*/

--select * from Ticket120406

--commit
begin tran
update PRICEDISCTABLE
set todate = '2022-07-22 00:00:00.000'
from PRICEDISCTABLE p
inner join Ticket120406 t
on t.Artcod = p.ITEMRELATION
where p.DATAAREAID = '120'
and todate = '2022-12-31 00:00:00.000' 
and ACCOUNTRELATION = 'DOM-LETERAGO'

--drop table Ticket120406