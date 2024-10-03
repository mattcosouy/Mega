
select SENTTOWAREHOUSE_MPH, READYTOSEND_MPH, WAREHOUSEPROCESSED_MPH, * from WMSSHIPMENT
where SHIPMENTID in  ('ENV_039111')
--('ENV_035197','ENV_035223','ENV_035256','ENV_035257','ENV_035258','ENV_035224','ENV_035225','ENV_035222') --
and dataareaid = '120'

/*
begin tran
update WMSSHIPMENT
set WAREHOUSEPROCESSED_MPH = 2,
 SENTTOWAREHOUSE_MPH = 0, READYTOSEND_MPH = 0
where SHIPMENTID in  ('ENV_039111')
--('ENV_035197','ENV_035223','ENV_035256','ENV_035257','ENV_035258','ENV_035224','ENV_035225','ENV_035222') 
and dataareaid = '120'
--commit
--rollback
*/

select * from XLS_EDI_DiariosDeMovimiento
where DataAreaID = '120'
and RefExtID = 'ENV_039111'
/*
--commit
begin tran
update XLS_EDI_DiariosDeMovimiento
set RefExtID = 'ENV_035372_1'
where DataAreaID = '120'
and RefExtID = 'ENV_035372'
*/