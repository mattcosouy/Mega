-- Consulta q devuelve art�culos de Pedidos de transferencia con transacciones en estado Registrado 
-- Art�culos de los grupos PTTR y MMTR
-- Transacciones en estado Registrado cuya referencia sea Pedidos de transferencia
-- Almac�n virtual de Panam�: MEGAPAN-01

select	'Registrado' as Estado, it.MODIFIEDBY as ModificadoPor, it.MODIFIEDDATETIME as ModificadoEl, it.DATEINVENT as FechaInvent,
		it.ITEMID as Art�culo, it.TRANSREFID as PedTransf, it.QTY as Cantidad from INVENTTRANS it
join INVENTTABLE i
on i.DATAAREAID = it.DATAAREAID
and i.ITEMID = it.ITEMID
--and i.ITEMGROUPID in ('PTTR','MMTR')
join inventdim id
on id.DATAAREAID = it.DATAAREAID
and id.INVENTDIMID = it.INVENTDIMID
join INVENTLOCATION il
on il.DATAAREAID = id.DATAAREAID
and il.INVENTLOCATIONID = id.INVENTLOCATIONID
and il.INVENTLOCATIONID = 'MEGAPAN-01'
where it.DATAAREAID = '120'
and it.TRANSTYPE = 22		-- Rececpci�n de Pedidos de Transferencia
and it.STATUSRECEIPT = 3	-- Registrado


