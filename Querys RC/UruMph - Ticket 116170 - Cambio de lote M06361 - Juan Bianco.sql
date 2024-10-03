

select * from INVENTDIM
where DATAAREAID = '120'
and inventdimid in ('085_17118110','085_17118109')
/*
select * from INVENTQUALITYORDERTABLE
where DATAAREAID = '120'
and QUALITYORDERID = 'PQ_00071468'
*/
select * from INVENTSUBBATCH_MPH
where DATAAREAID = '120'
and INVENTSUBBATCHID = 'LQ_A072767'

/*
--commit
begin tran
update INVENTDIM
set inventbatchid = 'M06360'
where DATAAREAID = '120'
and inventdimid in ('085_17118110','085_17118109')
*/
/*
--commit
Begin tran
update INVENTSUBBATCH_MPH
set inventbatchid = 'M06360'
where DATAAREAID = '120'
and INVENTSUBBATCHID = 'LQ_A072767'
*/
