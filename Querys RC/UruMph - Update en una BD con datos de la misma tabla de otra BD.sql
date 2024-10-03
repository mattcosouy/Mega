/*
--rollback
--commit
begin tran
update INVENTTABLE 
set RecordTemplate_MPH = '03.60 Material Productivo',
    ModelGroupId = 'ARTFIFO',
    ItemUnblockUserGroup_MPH = '120BQO0360',
where recid in
	(select recid from [MLAP105CAN2\AX2K9URUMPHPRO].[Ax2k9MPHPRO].[dbo].INVENTTABLE 
	where RecordTemplate_MPH = '03.60 Material Productivo')
*/


--rollback
--commit
begin tran
update INVENTTABLE 
set --RecordTemplate_MPH = '03.60 Material Productivo',
    --ModelGroupId = 'ARTFIFO',
    --ItemUnblockUserGroup_MPH = '120BQO0360',
	PdsShelfLife = ipro.PdsShelfLife
from INVENTTABLE i
inner join [MLAP105CAN2\AX2K9URUMPHPRO].[Ax2k9MPHPRO].[dbo].INVENTTABLE ipro on
ipro.DATAAREAID = i.DATAAREAID
and ipro.RECID = i.RECID
and ipro.RecordTemplate_MPH = '03.60 Material Productivo'
and i.DATAAREAID = '120'


/*
--rollback
--commit
begin tran
update INVENTBATCH
set expdate = ibpro.EXPDATE
from INVENTBATCH ib 
inner join  [MLAP105CAN2\AX2K9URUMPHPRO].[Ax2k9MPHPRO].[dbo].inventbatch ibpro on
ib.DATAAREAID = ibpro.dataareaid
and ib.RECID = ibpro.recid
and ib.DATAAREAID = '120'
*/

