
select TPLWAREHOUSEUNITID_MPH, * from INVENTTABLEMODULE
where DATAAREAID = '080'

select * from [ROAP249STD\AX4DOMROWPRE].[Ax4DomRowPre].dbo.[Ax4-365-ReleasedProductsV2]
--where DATAAREAID = '080'
/*
--rollback
--commit
begin tran 
update INVENTTABLEMODULE
set TPLWAREHOUSEUNITID_MPH = isnull((case MODULETYPE when 0 then u.INVENTORYUNITSYMBOL when 1 then u.PURCHASEUNITSYMBOL when 2 then u.SALESUNITSYMBOL end),'')
from INVENTTABLEMODULE itm
join   [ROAP249STD\AX4DOMROWPRE].[Ax4DomRowPre].dbo.[Ax4-365-ReleasedProductsV2] u
on itm.ITEMID = u.ITEMNUMBER
--and itm.MODULETYPE = 0 -- 0=Inventario, 1=Compras, 2=Ventas
where itm.DATAAREAID = '080'
*/