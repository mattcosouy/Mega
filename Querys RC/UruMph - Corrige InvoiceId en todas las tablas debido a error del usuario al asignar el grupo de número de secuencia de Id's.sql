/* 2020/06/23 - RC - Modificar el id de Factura en todas las tablas necesarias, debido a configuraci�n incorrecta de los usuarios en el 
Grupo de n�meros de Secuencia num�rica en la cabecera del PV.
La factura queda generada con un ID que no corresponde con el tipo de documento a enviar a Rondanet/DGI. Dado q esta situaci�n es post-mortem, la 
�nica manera de corregirlo es "por debajo" mediante este script. 
La opci�n real ser�a hacer NC y nuevo PV y facturaci�n. Como esto siempre es urgente, no es posible ir por la opci�n correcta.
Se habl� con Isamel Da Rosa, de forma de integrar los mismos controles de Rondanet, previa registraci�n de la factura.
*/

select FILENAME, * from CUSTINVOICEJOUR_EINVOICE_MPH
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
/*begin tran 
update CUSTINVOICEJOUR_EINVOICE_MPH
set  FILENAME = '103_NPG_A00005019', INVOICEID = 'A00005019'
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
--commit
*/
select invoiceid, * from CUSTINVOICEJOUR
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
/*begin tran
update CUSTINVOICEJOUR
set INVOICEID = 'A00005019' 
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
--commit
*/

select invoiceid, * from CUSTINVOICETRANS
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
/*begin tran
update CUSTINVOICETRANS
set INVOICEID = 'A00005019' 
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
--commit
*/

select invoiceid, * from CUSTINVOICESALESLINK
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
/*begin tran
update CUSTINVOICESALESLINK
set INVOICEID = 'A00005019'
where DATAAREAID = '120' and INVOICEID = 'A00015731' and SALESID = 'PV_00015987'
--commit
*/

select invoiceid, * from INVENTTRANS
where DATAAREAID = '120' and INVOICEID = 'A00015731' and TRANSREFID = 'PV_00015987'
/*begin tran
update INVENTTRANS
set INVOICEID = 'A00005019'
where DATAAREAID = '120' and INVOICEID = 'A00015731' and TRANSREFID = 'PV_00015987'
--commit
*/

select txt, replace(txt,'A00015731','A00005019') , INVOICE, * from CUSTTRANS
where DATAAREAID = '120'  and voucher = 'FV_10020199'
/*begin tran
update CUSTTRANS
 set txt = replace(txt,'A00015731','A00005019') , INVOICE = 'A00005019'
where DATAAREAID = '120'  and voucher = 'FV_10020199'
--commit
--rollback
*/

select txt, DOCUMENTNUM, * from LEDGERTRANS
where DATAAREAID = '120'  and voucher = 'FV_10020199'
/*begin tran
update LEDGERTRANS
set txt = replace(txt,'A00015731','A00005019') , DOCUMENTNUM = 'A00005019'
where DATAAREAID = '120'  and voucher = 'FV_10020199'
--commit
*/