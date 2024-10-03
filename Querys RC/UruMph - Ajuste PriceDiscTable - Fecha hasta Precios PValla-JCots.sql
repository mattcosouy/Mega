
select * from PRICEDISCTABLE p
where p.DATAAREAID = 120
--and FROMDATE = '2022-06-'
and TODATE in ('2022-06-30')

/*
begin tran
update PRICEDISCTABLE
set TODATE = '2022-12-31'
where DATAAREAID = 120
and TODATE in ('2022-06-30') 
--commit
--rollback
*/