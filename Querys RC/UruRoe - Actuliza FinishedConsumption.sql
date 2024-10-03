
select * from 
begin tran
update INVENTBATCH
set FINISHEDCONSUMPTION_MPH = 1
from INVENTBATCH i
join lista_fin_de_consumo_25_03_202 l
on l.column1 = i.ITEMID
and l.column2 = i.INVENTBATCHID
where i.DATAAREAID = '010'
--commit



