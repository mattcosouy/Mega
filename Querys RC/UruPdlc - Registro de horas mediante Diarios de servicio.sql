
-------------- Por separado
-- Calendario (Planificaci�n)
select * from APMOBJECTCALENDAR
where DATAAREAID = '120'
and APMJOBID in ('PedTra-055870', 'PedTra-055616')
-- 'PedTra-055870'  --> Sin calendario 
-- 'PedTra-055616'  --> Con calendario 

-- Pedidos de trabajo
select * from APMJOBTABLE -- Aqu� est�n las fechas 
where DATAAREAID = '120'
and APMJOBID in ('PedTra-055870', 'PedTra-055616') 

-- L�neas de diario de Servicio y Cabecera
select * from APMJOBREGISTRATIONJOURNALTRANS ajtr
inner join  APMJOBREGISTRATIONJOURNALTABLE ajt
on ajt.DATAAREAID = ajtr.DATAAREAID
and ajt.JOURNALID = ajtr.JOBREGISTRATIONJOURNALID
where ajtr.DATAAREAID = '120'
and ajt.APMJOBID in ('PedTra-055870', 'PedTra-055616')

--
select * from APMJOBTABLEJOBSTAGELOG -- Aqu� est�n las fechas de los cambios de estado
where DATAAREAID = '120'
and JOBID in ('PedTra-055870', 'PedTra-055616') --PedTra-056384 con este PT hay m�s registros de cambios de estado

----------- Integrando todo
--L�neas, Cabecera, Pedidos de trabajo, Calendario
select * from APMJOBREGISTRATIONJOURNALTRANS ajtr
inner join  APMJOBREGISTRATIONJOURNALTABLE ajt
on ajt.DATAAREAID = ajtr.DATAAREAID
and ajt.JOURNALID = ajtr.JOBREGISTRATIONJOURNALID
inner join APMJOBTABLE apmj
on apmj.DATAAREAID = ajt.DATAAREAID
and apmj.APMJOBID = ajt.APMJOBID
left join APMOBJECTCALENDAR aoj
on aoj.DATAAREAID = apmj.DATAAREAID
and aoj.APMJOBID = apmj.APMJOBID 
where ajtr.DATAAREAID = '120'
and ajt.APMJOBID in ('PedTra-055870', 'PedTra-055616')

