
select convert(date,getdate()), convert(date,'1900-01-01')

select i.CITAREINSPECTIONDATE, i.* from INVENTBATCH i
inner join  Ax4365LotesTanda6 t on
t.itemid = i.itemid and
t.inventbatchid = i.inventbatchid
where dataareaid = '080'

select * from Ax4365LotesTanda1
-- EXEC sp_rename 'Ax4365LotesTanda6', 'Ax4365LotesTanda6Listo'

/*
--rollback
--commit
begin tran
update INVENTBATCH 
set citareinspectiondate = convert(date,'1900-01-01')   -- convert(date,getdate())   --  
from inventbatch i
inner join  Ax4365LotesTanda6 t on
t.itemid = i.itemid and
t.inventbatchid = i.inventbatchid
where i.dataareaid = '080'


