
select * from  REARRANGEPALLETINPUTTABLE_MPH
where DATAAREAID = '120'
and REARRANGESTAGE = 3 -- En espera de respuesta de MLX
--and TOPALLETID in ('MLXPA00002141') --,'MLXPA00007788','MLXPA00007789')
order by MODIFIEDDATETIME

--Para evaluar SOR's - Órdenes debaja de pallets en proceso
select * from  INVENTPALLETREQUEST_MPH 
where DATAAREAID = '120'
and REQUESTCOMPLETED != 2
order by MODIFIEDDATETIME

/*
begin tran
update INVENTPALLETREQUEST_MPH
set REQUESTCOMPLETED = 2
--select * from INVENTPALLETREQUEST_MPH
where DATAAREAID = '120'
and REQUESTCOMPLETED != 2
and WMSPALLETID = 'MLXPA00004444'
--commit
--rollback
*/
/*
begin tran
update REARRANGEPALLETINPUTTABLE_MPH
set rearrangestage = 4
where DATAAREAID = '120'
and REARRANGESTAGE = 3 -- En espera de respuesta de MLX
and TOPALLETID in ('MLXPA00002141') --,'MLXPA00007788','MLXPA00007789')
*/

