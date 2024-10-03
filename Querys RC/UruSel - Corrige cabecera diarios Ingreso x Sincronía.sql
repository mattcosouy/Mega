

select SENTTOWAREHOUSE_MPH , READYTOSEND_MPH ,* from WMSJOURNALTABLE
where DATAAREAID = '120'
and JOURNALID in ('137_039047', '137_039052', '137_038907')

/*
begin tran 
update WMSJOURNALTABLE
set SENTTOWAREHOUSE_MPH = 0, READYTOSEND_MPH = 0
--set WAREHOUSEPROCESSED_MPH = 0, WAREHOUSERESSTATUS_MPH = 0
where DATAAREAID = '120'
and JOURNALID in ('137_039047', '137_039052', '137_038907')
--commit
*/

select * from XLS_EDI_DiariosDeMovimiento
where DataAreaID = '120'
and refextid in ('137_039047', '137_039052', '137_038907')

/*
--commit
begin tran
update XLS_EDI_DiariosDeMovimiento
set refextid = refextid  + '_'
where DataAreaID = '120'
and refextid in ('137_039047', '137_039052', '137_038907')
*/