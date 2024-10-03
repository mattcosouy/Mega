

--respaldo de InventTable
select * 
into _DimensionsTicket111539
from DIMENSIONS
--where dataareaid = '010'
--and DIMENSIONCODE = 106 



--Se actualiza InventTable con las dimenesiones enviadas.
--rollback
--commit
begin tran
update DIMENSIONS
set CONSOLIDATION_MPH = r.cons
--select * 
from DIMENSIONS i 
inner join [UruRoe - Thales - DimEstadística] r on
r.NUM = i.NUM
where i.dataareaid = '010'
and DIMENSIONCODE = 106 

--select * from  [UruRoe - Thales - DimEstadística]