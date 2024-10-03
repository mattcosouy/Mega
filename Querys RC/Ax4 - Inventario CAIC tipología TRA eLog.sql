/*	Ax V4. RC - 2021-04-19 - Proyecto CAIC
	Inventario con tipología "TRA - En Tránsito", para eLog. 
	Agregar en Inventario CAIC, al final con el mismo formato.
	En Ax4, el inventario en tránsito se obtiene según el siguiente detalle, el cual aparece en el siguiente mail:

	De: Patricia Piñeyrua 
	Enviado el: jueves, 10 de setiembre de 2020 12:19
	Para: Mathias Robinson <mrobinson@megalabs.global>
	Asunto: RE: TipoExistencia Ax2k4

	Hola Mathi,
	Como estas?
	Según la reunión que generamos hoy con Gean Carlo Cobeña (Ecuador) y Gabriela Peyrous identificamos el criterio para considerar el Inventario en Transito en la Version 4.

	Desde el formulario de Lineas de Pedido de compras Abiertas, se debe considerar:
	-	el estado: Facturado Sin Remito
	-	líneas de Pedio de Compras cuyo Proveedor sea del grupo PUCE o PUCV (PUCE es Proveedor Exterior, y PUCV es Grupo de Empresas Vinculadas)
	-	los artículos a informar están identificados como de “ interés MP” en el Maestro de Artículos
*/

DECLARE @AREA varchar(3) 
SET @AREA = isnull(@AREA, '090')
-- Fto CAIC actual
select
  	pl.DATAAREAID																									AS [Empresa],
	(case @AREA
		when '010' then 'URU-ROE'
		when '015' then 'AX5URUROE'
		when '020' then 'AX5URUROE' 
		when '040' then 'AX4VENKLI'
		when '045' then 'AX4VENKLI'
		when '050' then 'AX5COLSCA'
		when '060' then 'AX4CHIPHI'
		when '070' then 'AX5ARGRAY'
		when '080' then 'AX4DOMROW'
		when '090' then 'AX4ECUACR'
		when '100' then 'AX5MEXITA'
		when '150' then 'AX5MEXLET'
		when '120' then 'AX5URUMPH'
		when '125' then 'AX5URUSEL'
		when '310' then 'AX5PERROE'
		when '320' then 'AX5PANLET'
		when '330' then 'AX5GUALET'
	 else 'Ax2k9-S/D'
    end)																											AS [IdBase],
	--pl.MODIFIEDDATE																									AS [Fecha],	
	getdate()																										AS [Fecha],
	pl.ItemID																										AS [ArtCod],
	i.ItemName																										AS [ArtDes], 
	i.ItemGroupID																									AS [ArtCtoGruCod],
	il.InventLocationId																								AS [AlmCod],
	isnull(inb.InventBatchID,'')																					AS [Lote],
    'N/A'        																									AS [SubLoteNro],
    'N/A'																											AS [Estado de disposicion],
    '19000101'																										AS [Fecha validacion],
    isnull(inb.ExpDate,'1900-01-01')																				AS [LoteVto],
	(case inb.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
-- ADD+ 2021-04-12 - RC - Ampliación valores Marca de empaque- Ticket 103257 
			when 3 then 'VERDE'
			when 4 then 'NRZ'
			when 5 then 'NRZ1'
-- ADD- 2021-04-12 - RC - Ampliación valores Marca de empaque- Ticket 103257 
	else '' end)																									AS [MarcaEmpaque],
	sum(pl.PURCHQTY)																								AS [Cantidad],
	isnull((select UnitID
			from InventTableModule itm
			where itm.ItemID = pl.ItemID
				and itm.DataAreaID = pl.DataAreaId
				and itm.ModuleType = 0
			), ' ')																									AS [UnInv],
	-- unidad de compra resultante a donde se convirtió.  Los países homogenizan las cantidades como lo requiere e-Log
	--(select isnull((select ul.UndDestino
	--				from XLS_DIM_UnidadeLogistica ul
	--				where ul.DataAreaID = '090' and
	--					  ul.UndOrigen = x.ArtUn),x.ArtUnComp))	AS [UnComp],  -- Esto no esta correcto en ninguna filial
	(case when itm1.UnitID = '' then itm0.UnitID 
	 else itm1.UnitID end)																							AS [UnComp],
	1																												AS [FactorUnInvUnComp], --FALTA IMPL. XLS_DIM_Articulos_Unidades
	'TRA' 																											AS [TipoExistencia], --VER. Shipment Tracking
	(case il.InventLocationId 
		when 'MEGAPAN-01' then 'ACCEAM'		--+ FUM 11/03/2019 RC - Incluir el almacén de tránsito de Panamá
		when 'EXT-TRAN'	  then 'ACCEAM' 	--+ FUM 19/03/2019 - Incluir artículos Trade del almacén de tránsito general
		when 'TRANSITO'	  then (case when i.ItemGroupID like '%TR' then 'ACCEAM' 
		                        else '' end)					
	else ''	 end)																									AS [Destino],
	'N/A'																											AS Exportacion, -- ver esto a detalle con el pais
	(case when i.MPHInterestingItem = 0 then 'No'
		  when i.MPHInterestingItem = 1 then 'Si' end)																AS [ArtInteres],
	(case when i.ItemGroupID like '%TR' then 'Si'
		  else 'No' end)																							AS [EsTrade],
	getdate()																										AS [FechaSyncro]
--select * 
from PURCHLINE pl
	inner join PURCHTABLE pt
		on pt.DATAAREAID = pl.DATAAREAID
		and pt.PURCHID = pl.PURCHID
	-- Artículos
	inner join INVENTTABLE i
		on i.DATAAREAID = pl.DATAAREAID
		and i.ITEMID = pl.ITEMID
	-- Grupo de Articulos
	inner join InventItemGroup iig (NOLOCK) on
		iig.DataAreaID = pl.DataAreaID and
		iig.ItemGroupID = i.ItemGroupID
	-- Grupo de Dimension Linea
	left join mphDimension3 lg on
		lg.DataAreaID = i.DataAreaID and
		lg.num = i.Dimension4_
	-- Grupo de Dimension SubMarca
	left join mphDimension7 sg on
		sg.DataAreaID = i.DataAreaID and
		sg.num = i.Dimension8_
	-- Cruce con Almacenes  // Puede no tener asignado almacen.
	inner join INVENTDIM id  (NOLOCK)
		on id.DATAAREAID = pl.DATAAREAID
		and id.INVENTDIMID = pl.INVENTDIMID
	left join InventLocation il (NOLOCK) on
		il.DataAreaID  = pl.DataAreaID and
		il.InventLocationId  = id.InventLocationId
	-- Apertura por Lote, Vencimiento y Disponibilidad.
	left join InventBatch inb (NOLOCK) on										
		inb.DataAreaID  = id.DataAreaID and
		inb.InventBatchID = id.InventBatchID and
		inb.ItemID = pl.ItemId
	-- Configuración Modulo de Inventarios --
	inner join InventTableModule itm0 on
		itm0.DataAreaID = pl.DataAreaID and
		itm0.ItemID = pl.ItemID and
		itm0.ModuleType = 0										-- Modulo de Inventarios
	-- Configuración Modulo de Compras --
	inner join InventTableModule itm1 on
		itm1.DataAreaID = pl.DataAreaID and
		itm1.ItemID = i.ItemID and
		itm1.ModuleType = 1										-- Modulo de Compras
where pt.DATAAREAID = @AREA
and pl.MPHPURCHSTATUS = 6 -- Facturado s/Remito
and pt.VENDGROUP in ('PUCE','PUCV')
and i.MPHINTERESTINGITEM = 1 -- Interés Corpo
 GROUP BY
	pl.DataAreaID
	,pl.MODIFIEDDATE	
	,pl.ItemID			
	,i.ItemName			
	,i.ItemGroupID		
	,il.InventLocationId	
	,inb.InventBatchID	
	,inb.ExpDate
	,inb.PackingTradeManufacturer_MPH
	,i.DataAreaId
	,itm1.UnitID
	,itm0.UnitID 
	,i.Dimension4_
	--,t.WMSLocationId
	,i.MPHInterestingItem
	,il.MPHLOCATIONLOGISTIC