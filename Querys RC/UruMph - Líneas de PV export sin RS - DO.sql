

select sl.itemid as Artículo, i.ITEMNAME as Nombre, 'DO' as PaísDestino 
from SALESLINE sl
join INVENTTABLE i on
i.DATAAREAID = sl.DATAAREAID
and i.ITEMID = sl.ITEMID
left join  extCodeValueTable e on
e.ExtCodeRelationRecId		 = i.RECID 
and e.ExtCodeId              = 'RS-DO' 
and e.ExtCodeRelationTableId = 175
where sl.DATAAREAID = '120'
and sl.SALESSTATUS < 2
and sl.DELIVERYCOUNTRYREGIONID = ('DO')
and i.ITEMGROUPID IN ('PT', 'PTTR', 'MM', 'MMTR')
and e.EXTCODEID is null
group by sl.itemid,  i.ITEMNAME
order by sl.itemid    