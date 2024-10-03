
select i1.unitid, i2.unitid, p.* from purchline p
 join inventtablemodule i1
on i1.DATAAREAID = p.DATAAREAID
and i1.ITEMID = p.ITEMID
and i1.MODULETYPE = 1 -- Compras
 join inventtablemodule i2
on i2.DATAAREAID = p.DATAAREAID
and i2.ITEMID = p.ITEMID
and i2.MODULETYPE = 0 -- Inventario
join inventtable i
on i.DATAAREAID = p.DATAAREAID
and i.ITEMID = p.ITEMID
where p.dataareaid = '010'
and p.purchunit = ''
and i.ITEMGROUPID != 'FACON'

--Actualizo las líneas con la unidad de medida de Compras. 
--Luego buscaré las transacciones relacionadas a estas líneas y se actualizarán con la unidad de medida de inventario