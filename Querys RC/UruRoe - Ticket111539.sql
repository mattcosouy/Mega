

--respaldo de InventTable
select * 
into _InventTableTicket111539
from InventTable

--Se actualiza InventTable con las dimenesiones enviadas.
--rollback
--commit
begin tran
update INVENTTABLE
set DIMENSION7_ = r.column2, DIMENSION9_ = r.column3
--select * 
from INVENTTABLE i 
inner join _RelArtDimTicket111539 r on
r.column1 = i.ITEMID
where i.dataareaid = '010'

--select * from _RelArtDimTicket111539