

--select * from Ticket109252ALH_Activos

/*
--rollback
--commit
begin tran
update INVENTTABLE 
set MODELGROUPID = 'FORMSEMI' 
from INVENTTABLE i 
where i.recid in
	(select recid  from Ticket109252ALH_Activos t
	inner join inventtable i 
	on i.itemid = t.Codigo)
¨*/
 
