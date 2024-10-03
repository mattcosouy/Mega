
--select * from RegistrosSanitarios 
--where RegistrosSanitarios_ID in ('2188','2185','2731')

--select * from healthregistration_mph where dataareaid = '120'

select sl.itemid as Artículo, i.ITEMNAME as Nombre, sl.DELIVERYCOUNTRYREGIONID as PaísDestino 
from SALESLINE sl
join INVENTTABLE i on
i.DATAAREAID = sl.DATAAREAID
and i.ITEMID = sl.ITEMID
	-- RC +  Muestra el Registro Sanitario si lo tiene
	left join HEALTHREGISTRATION_MPH h on
		sl.DataAreaID = h.DATAAREAID 	and sl.ITEMID = h.ITEMID and h.HEALTHREGISTRATIONSTATUS = 1 --Activo
		and h.REGISTRATIONDUEDATE > GETDATE() and h.REGISTRATIONCOUNTRYREGIONID = sl.DELIVERYCOUNTRYREGIONID
where sl.DATAAREAID = '120'
and sl.SALESSTATUS < 2
and h.HEALTHREGISTRATIONID is null
and sl.DELIVERYCOUNTRYREGIONID in ('CR','HN','SV','NI','GT','PA')
and i.ITEMGROUPID IN ('PT', 'PTTR', 'MM', 'MMTR')
group by sl.itemid,  i.ITEMNAME, sl.DELIVERYCOUNTRYREGIONID
order by  sl.DELIVERYCOUNTRYREGIONID, sl.itemid




