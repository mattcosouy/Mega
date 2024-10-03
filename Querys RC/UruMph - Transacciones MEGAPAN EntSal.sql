

 select
	itr.DataAreaID																												as [Area],
	(case itr.Direction
		when 000 then 'Ninguno'
		when 001 then 'Recepcion'
		when 002 then 'Emision'
	 end)																														as [TrnTipo],
	(case itr.TransType
		when 000 then 'Ped. de Ventas'
		when 002 then 'Produccion'
		when 003 then 'Ped. de Compras'
		when 004 then 'Transaccion'
		when 005 then 'Perdidas/Ganancias'
		when 006 then 'Transferir'
		when 007 then 'Cierre de Inv. Media Ponderada'
		when 008 then 'Línea de Producción'
		when 009 then 'Linea de LMAT'
		when 010 then 'LMAT'
		when 011 then 'Pedido de Salida'
		when 012 then 'Proyectos'
		when 013 then 'Recuento'
		when 014 then 'Transporte de pallet'
		when 015 then 'Orden de Cuarentena'
		when 016 then 'DEL_Obsoleto'
		when 020 then 'Activo Fijo'
		when 021 then 'Envio de Pedido de Transf.'
		when 022 then 'Recepcion de Pedido de Transf.'
		when 023 then 'Baja de Pedido de Transf.'
		when 024 then 'Presupuesto'
		when 025 then 'Pedido de Calidad'
		when 100 then 'Produccion conjunta o derivada'
	end)																														as [TrnOrigen],

	-- Informacion referida al Articulo	
	itr.ItemID																													as [ArtCod],
	it.ItemName																													as [ArtDes],
--	(case it.ItemType when 0 then 'Artículo' when 1 then 'LMAT' when 2 then 'Servicio' when 3 then 'Fórmula' end)				as [ArtTipo],
 	it.ItemGroupID																												as [ArtGrupoCod],
 	iig.Name																													as [ArtGrupoDes],
-- 	(case when inv.ItemGroupID is null then 'No' else 'Si' end)																	as [ArtInv],
-- 	(case when com.ItemID is null then 'No' else 'Si' end)																		as [ArtRequerido],
 	-- +SC 01/07/2012
-- 	(case when it.PSICOTROPIC_MPH = 0 then 'No' else 'Si' end)																	as [ArtPsicotropico],
-- 	isnull(cve.EXTERNALITEMID,'')																								as [ArtCodMSP],
-- 	isnull(cve.EXTERNALITEMTXT,'')																								as [ArtDesMSP],
 	-- -SC 01/07/2012
 	-- +RC 01/07/2020 - #98720 - Panel INVE_TransaccionesTodasAcotado_PV_89524 - Agregar campo Grupo costes y tipo diario recuento
--	it.COSTGROUPID																												as [ArtGrupoCost],
	-- +RC 01/07/2020 - #98720 - Panel INVE_TransaccionesTodasAcotado_PV_89524 - Agregar campo Grupo costes y tipo diario recuento
 	-- Dimensiones de Inventario	
-- 	id.InventSiteID																												as [InvSitio],
 	id.InventLocationID																											as [InvAlmaCod],
 	isnull(il.Name,'')																											as [InvAlmaDes],
 	(case il.InventLocationType when 0 then 'Normal' when 1 then 'Cuarentena' when 2 then 'Transito' end)						as [InvAlmaTipo],
 	id.wmsLocationID																											as [InvLugar],
 	id.wmsPalletID																												as [InvPallet],
 	id.InventContainerID																										as [InvBulto],
 	id.InventLegalNumID																											as [InvDUA],
 
	-- Lote - Vencimiento y Disponibilidad
	ib.InventBatchID																											AS [LoteNro],
	ib.ExpDate																													AS [LoteVto],
	(case dm.Status when 0 then 'No Disponible' else 'Disponible' end)															AS [LoteEstadoCod],
	isnull(dm.Description,'Operación Interna. Disponible')																		AS [LoteEstadoDes],
 	
 	-- Fechas de la transaccion
	itr.DateFinancial																											as [TrnFechaFinanc],
	(case when itr.DatePhysical = '19000101' then convert(date,convert(varchar(10),getdate(), 112)) else itr.DatePhysical end)	as [TrnFechaFisica],
	
	-- Se consolidan los estatus para facilitar la visualizacion.  Cuando itr.StatusIssue es 0 es porque corresponde a una
	-- recepcion y viceversa. Igualmente se dejan ambos codigos para poder filtrar por codigo y evitar hacerlo por la descripcion
	-- que se ajusto para que la visualizacion sea homogenea.
	-- Estos estados son los estandar de Ax.
	itr.StatusIssue																												as [TrnEstadoEmiCod],
	itr.StatusReceipt																											as [TrnEstadoRecCod],
	(case itr.StatusIssue													-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt								-- Estados de la Recepcion
						when 000 then 'Ninguno     '
						when 001 then 'Comprado    '
						when 002 then 'Recibido    '
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 001 then 'Vendido     '										-- No esta en el inventario
		when 002 then 'Deducido    '										-- No esta en el inventario
		when 003 then 'Seleccionado'										-- Esta en el inventario
		when 004 then 'Fisica Reser'										-- Esta en el inventario
		when 005 then 'Pedido Reser'										-- Esta en el inventario
		when 006 then 'En Pedido   '										-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																														as [TrnEstado],
	itr.TransRefId + (case when itr.ShipID <> '' then  ' - ' + upper(itr.ShipID) else '' end) 									as [TrnRefNro],
	itr.ShipID																													as [TrnEmbarque],
	itr.DateExpected																											as [TrnRefFecha],

	-- Estados MPH para facilitar la lectura (Podria mostrarse Error por algun caso aun no utilizado)
	(case
		-- Mercaderia en Transito
		when itr.StatusIssue <> 0	and il.InventLocationType = 2			then '2.0 En Transito'	-- Mercaderia aun en Transito.
	end)																														as [TrnEstadoRes],
	
	--Información Referida a la Contabilizacion
	itr.CurrencyCode																											as [TrnMonOrig],
	itr.InvoiceID,
	itr.Voucher,
	itr.VoucherPhysical,
	itm0.UnitID	   																												as [Un],
	itr.Qty																														as [Cantidad],
	itr.CostAmountPhysical,
	itr.CostAmountPosted																										as CtoValMonPpal,		-- Contabilizado
	itr.CostAmountAdjustment																									as CtoValMonPpalAdj,	-- Contabilizado (Ajuste)
	isnull(sl.SHIPPINGROUTEID_MPH,'N/A')																						as [RutaMPH],
	isnull(sl.CUSTOMERREF,'N/A')																								as [CliRefCompra],
	--#89524 - Agregar campo "Proyectos" a Panel "INVE_TransaccionesTodasAcotado"
	itr.ProjId																													as [ProyectoId],
	--#89524 - Agregar campo "Proyectos" a Panel "INVE_TransaccionesTodasAcotado"
 	-- +RC 01/07/2020 - #98720 - Panel INVE_TransaccionesTodasAcotado_PV_89524 - Agregar campo Grupo costes y tipo diario recuento
	isnull(ijn.JOURNALNAMEID,'')																								as [NomDiario],
	isnull(ijn.DESCRIPTION,'')																									as [DescDiario],
	isnull(ijt.DESCRIPTION,'')																									as [CabDiario]
	-- +RC 01/07/2020 - #98720 - Panel INVE_TransaccionesTodasAcotado_PV_89524 - Agregar campo Grupo costes y tipo diario recuento
  from InventTrans itr 												-- Transacciones de Inventario
	left join SalesLine sl on										-- Cruza por Linea de Venta para Ruta
		sl.DataAreaID = itr.DataAreaID and
		sl.InventTransID = itr.InventTransID
	inner join InventDim id on										-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on										-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID AND
		ib.ItemID = itr.ItemID 
	left join PdsDispositionMaster dm on							-- Disponibilidad
		dm.DataAreaID = ib.DataAreaID and
		dm.DispositionCode = ib.PdsDispositionCode 
	
	-- Articulos --
	inner join InventTable it on									-- Maestro de Articulo
		it.DataAreaID = itr.DataAreaID and
		it.ItemID = itr.ItemID
	inner join InventItemGroup iig on								-- Maestro Grupo de Articulos
		iig.DataAreaID = it.DataAreaID and
		iig.ItemGroupID = it.ItemGroupID
	inner join InventTableModule itm0 on							-- Configuración Modulo de Inventarios --
		itm0.DataAreaID = it.DataAreaId and
		itm0.ItemID = it.ItemID and
		itm0.ModuleType = 0
 	-- +SC 15/11/2012
	left join CustVendExternalItem cve on							-- Configuración Cod.Externo para MSP --
		cve.DataAreaID = it.DataAreaId and
		cve.ItemID = it.ItemID and
		cve.MODULETYPE = 4 and										-- Cliente
        cve.CustVendRelation = '999999'								-- Solo busco relación con MSP
 	-- -SC 15/11/2012
  	inner join (select it1.ItemGroupID, it1.DataAreaID				-- Identifica los Grupos de Articulo que llevan inventario fisico
				from XLS_DIM_Seguridad s1							-- Nota: Por el momento se hace inner join para que no cruce con 
					inner join InventTable it1 on					-- aquellos articulos de los que no se lleva inventario.
						it1.DataAreaID = s1.DataAreaID and			-- Si quiere ver todos los harticulos haga left join. En el select
						it1.ItemType <> 2							-- Se excluyen los articulos de tipo servicio. 
					inner join InventDimSetup ids on				-- ya esta contemplada la posibilidd de ver todo.
						ids.DataAreaID = it1.DataAreaID and
						ids.DimGroupID = it1.DimGroupID and
						ids.LineNum >= 5
				where it1.DataAreaID = s1.DataAreaID
				group by ItemGroupID, it1.DataAreaID
				having sum(ids.PhysicalInvent) > 0) Inv	on
		inv.DataAreaID = iig.DataAreaID and
		inv.ItemGroupID = iig.ItemGroupID

	-- Cruce con Almacenes  // Puede no tener asignado almacen.
	left join InventLocation il on
		il.DataAreaID = id.DataAreaID and
		il.InventLocationId = id.InventLocationId
	
	-- Detecta Articulos que tienen compromisos de Venta o de Produccion
	left join (select itr1.ItemID
				from XLS_DIM_Seguridad s2
					inner join InventTrans itr1 on
						itr1.DataAreaID = s2.DataAreaID
				where ((itr1.TransType in (2,8) and itr1.StatusIssue <> 2) or itr1.TransType = 000)
				group by itr1.ItemID) com on
		com.ItemID = itr.ItemID
 	-- +RC 01/07/2020 - #98720 - Panel INVE_TransaccionesTodasAcotado_PV_89524 - Agregar campo Grupo costes y tipo diario recuento
	left join INVENTJOURNALTABLE ijt on 
		ijt.DATAAREAID = itr.DATAAREAID and 
		ijt.JOURNALID = itr.TRANSREFID --and
		--itr.TRANSTYPE = 013 -- Recuento
	left join INVENTJOURNALNAME ijn on
	    ijn.DATAAREAID = itr.DATAAREAID and 
		ijn.JOURNALNAMEID = ijt.JOURNALNAMEID
	-- +RC 01/07/2020 - #98720 - Panel INVE_TransaccionesTodasAcotado_PV_89524 - Agregar campo Grupo costes y tipo diario recuento
		-- +MR 13/11/2015
where itr.DataAreaID = '120' 
and il.INVENTLOCATIONID = 'MEGAPAN-01'
and (STATUSRECEIPT = 1 or STATUSISSUE = 1) --Comprado / Vendido
and itr.TransType in ( 0, 3, 6, 13, 22)  -- PV, PC, Recuento, Recepción de PT
order by itr.ITEMID, itr.inventdimid, itr.DateFinancial, STATUSISSUE -- Ingresos primero
/*
		when 000 then 'Ped. de Ventas'
		when 002 then 'Produccion'
		when 003 then 'Ped. de Compras'
		when 004 then 'Transaccion'
		when 005 then 'Perdidas/Ganancias'
		when 006 then 'Transferir'
		when 007 then 'Cierre de Inv. Media Ponderada'
		when 008 then 'Línea de Producción'
		when 009 then 'Linea de LMAT'
		when 010 then 'LMAT'
		when 011 then 'Pedido de Salida'
		when 012 then 'Proyectos'
		when 013 then 'Recuento'
		when 014 then 'Transporte de pallet'
		when 015 then 'Orden de Cuarentena'
		when 016 then 'DEL_Obsoleto'
		when 020 then 'Activo Fijo'
		when 021 then 'Envio de Pedido de Transf.'
		when 022 then 'Recepcion de Pedido de Transf.'
		when 023 then 'Baja de Pedido de Transf.'
		when 024 then 'Presupuesto'
		when 025 then 'Pedido de Calidad'
		when 100 then 'Produccion conjunta o derivada'
		*/
