
select convert(date,CREATEDDATETIME, 123) as [CreadoEl] ,'S'+convert(nvarchar,recid) as [RefInterna], * from SALESLINE
where DATAAREAID = '120'
and SALESSTATUS = 1 -- Pedido abierto
and convert(date,CREATEDDATETIME, 123)  >= '2020-03-01'

/*
select * from BULKPROCESSIMPORT_MPH 
where DATAAREAID = '120'

select * from BULKPROCESSSESSION_MPH
where DATAAREAID = '120'
and filename like '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Megalabs\PRO-MPH\EDI\PedidosVta\Pendientes\%'
order by BULKPROCESSSESSIONID desc
*/

