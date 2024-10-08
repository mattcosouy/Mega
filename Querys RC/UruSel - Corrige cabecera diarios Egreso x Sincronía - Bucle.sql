
select SENTTOOWNER_MPH, * from INVENTJOURNALTABLE 
where DATAAREAID = 125
and  EXTWMSJOURNALID_MPH in ('ENV_036987','ENV_037304','ENV_038377','ENV_038403','ENV_038450','ENV_038516','ENV_038586')
and SENTTOOWNER_MPH = 0 and WAREHOUSECANCELLED_MPH = 0

/*
--rollback
--commit
begin tran
update 
INVENTJOURNALTABLE 
set SENTTOOWNER_MPH = 1
where DATAAREAID = 125
and EXTWMSJOURNALID_MPH in ('ENV_036987','ENV_037304','ENV_038377','ENV_038403','ENV_038450','ENV_038516','ENV_038586')
and SENTTOOWNER_MPH = 0 and WAREHOUSECANCELLED_MPH = 0

*/