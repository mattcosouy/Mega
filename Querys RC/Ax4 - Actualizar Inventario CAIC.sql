
-- AX4ECUACR_CAIC - [ACAP014GYE\AX4ECUACRPRO].[AX4ECUACRPRO] - 090
-- AX4DOMROW_CAIC - [ROAP048STD\AX4DOMROWPRO].[AX4DOMROWPRO] - 080
-- AX4CHIPHI_CAIC - [PIAP019SCL\AX4CHIPHIPRO].[AX4CHIPHIPRO] - 060

-- AX4VENKLI_CAIC - [MLAP020CCS\AX4VENKLIPRO].[Ax4VenKliPRO] - 045

--select count(*) from Inventario ic where ic.tipoexistencia = 'S/D'
--select * from InventBatch
--select * from InventLocation
/*
	select *  into InventBatch from 
	 [ACAP014GYE\AX4ECUACRPRO].[AX4ECUACRPRO].dbo.inventbatch 
	create unique index inventbatch_01 on inventbatch (dataareaid, itemid, inventbatchid)
	drop table InventLocation
	select * into InventLocation from 
	 [ACAP014GYE\AX4ECUACRPRO].[AX4ECUACRPRO].dbo.inventlocation 
	create unique index inventlocation_01 on inventlocation (dataareaid, inventlocationid)
	--Índice sugerido x el proceso estimated Execution plan
	CREATE NONCLUSTERED INDEX Inventario_01 ON [dbo].[Inventario] ([Empresa],[ArtCod],[Lote]) INCLUDE ([AlmCod])
	alter table Inventario alter column marcaempaque varchar(10)
 */
 --rollback
 --commit
begin tran
update Inventario
--select 
set /*marcaempaque = 	
	(case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
-- ADD+ 2021-04-12 - RC - Ampliación valores Marca de empaque- Ticket 103257 
			when 3 then 'VERDE'
			when 4 then 'NRZ'
			when 5 then 'NRZ1'
-- ADD- 2021-04-12 - RC - Ampliación valores Marca de empaque- Ticket 103257 
	else '' end),*/
tipoexistencia = 
    (case il.MPHLOCATIONLOGISTIC 
	when 1 then 'DIS'
	when 2 then 'REC'
	when 3 then 'TRA'
	when 4 then 'VEN'
	when 5 then 'PRO'
	--else (case il.MPHLOCATIONTYPE when 1 then (case inb.EXPDATE - getdate() when > 0 then  ))
	else 'S/D' end)
from Inventario ic
/*join [MPAP009MVD1\AXFACADECORP].[AX4ECUACR_CAIC].dbo.inventbatch ib on
ic.empresa = ib.dataareaid COLLATE SQL_Latin1_General_CP1_CS_AS and
ic.artcod = ib.itemid COLLATE SQL_Latin1_General_CP1_CS_AS and
ic.lote = ib.inventbatchid COLLATE SQL_Latin1_General_CP1_CS_AS */
join  [ACAP014GYE\AX4ECUACRPRO].[AX4ECUACRPRO].dbo.inventlocation il on
ic.empresa = il.dataareaid COLLATE SQL_Latin1_General_CP1_CS_AS and
ic.almcod = il.inventlocationid COLLATE SQL_Latin1_General_CP1_CS_AS
where ic.empresa = '090' COLLATE SQL_Latin1_General_CP1_CS_AS
--where ic.tipoexistencia = 'S/D'
