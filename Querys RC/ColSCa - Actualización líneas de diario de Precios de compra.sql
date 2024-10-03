/*	Script para resolver los casos de las líneas de precios de proveedores de Colombia.
    Primer Ticket con el caso : 123494. 
*/ -------------------------------------------------------------------------------------

-- Primer paso: Respaldar la tabla a actualizar ----------------------------------------
--select * into bk_pricediscadmtrans_Ticket123494 from pricediscadmtrans

-- Revisar la data a Actualizar  -------------------------------------------------------
select todate,* from pricediscadmtrans
where dataareaid = '050'
and journalnum = '067_000372'
--and todate = '2022-08-31'

/* Eliminar los registros vencidos -----------------------------------------------------
--commit    -- 800 registros
begin tran
delete from pricediscadmtrans
where dataareaid = '050'
and journalnum = '067_000372'
and todate = '2022-08-31'
*/

/* Actualizar los registros restantes con la nueva fecha de vigencia -------------------
--commit -- 1387 registros
begin tran
update pricediscadmtrans
set todate = '2022/10/05'
where dataareaid = '050'
and journalnum = '067_000372'
*/