if exists (select name
  from sysobjects 
  where name = 'XLS_DIM_PedidosDeCalidad' AND type = 'V')
  drop view XLS_DIM_PedidosDeCalidad
GO 

create view XLS_DIM_PedidosDeCalidad as
-------------------------------------------------------------------------------------------------------------------------------------
-- Creada por: GN el 17/01/2013
-------------------------------------------------------------------------------------------------------------------------------------
-- Nota: Esta consulta devuelve todas las cabeceras de Pedidos de Calidad en el estado en que se encuentra a la fecha. 
-- select top 100 * from XLS_DIM_PedidosDeCalidad where PQ_CreEl >= dateAdd(dd, -7, getdate())
-------------------------------------------------------------------------------------------------------------------------------------

  select
	-- Informacion para cruzar en otras consultas
	pq.DataAreaID																													AS [DataAreaID],
	pq.QualityOrderID																												AS [QualityOrderID],
	pq.InventDimID																													AS [InventDimID],
	pq.InventRefTransID																												AS [InventRefTransID],
	pq.InventTransID																												AS [InventTransID],
	
	-- Informacion del Pedido de Calidad
	pq.QualityOrderID																												AS [PQ_Nro],
	pq.ReferenceType																												AS [PQ_TipoCod],
	dbo.fc_ENUM_InventTestReferenceType(pq.ReferenceType)																			AS [PQ_TipoDes],
	pq.OrderStatus																													AS [PQ_StatusCod],
	dbo.fc_ENUM_InventTestOrderStatus(pq.OrderStatus)																				AS [PQ_StatusDes],
	pq.InventRefID																													AS [PQ_Invent_RefID],
	pq.TestGroupID																													AS [PQ_GrupoTestCod],
	
	-- Informacion complementaria
	isnull(pq.Remark_MPH,'')																										AS [PQ_Observacion],
	isnull(pq.ReferenceText_MPH,'')																									AS [PQ_Rerencia],
	SamplingPlan_MPH																												AS [PQ_PlanDeMuestreo],
	InspectionLevel_MPH																												AS [PQ_NivelDeInspeccion],
	
	pq.PDSOPENQUALITYDISPOSITIONCODE																								AS [PQ_DispAbierta],
	pq.PDSFAILEDQUALITYDISPOSITI20003																								AS [PQ_DispNoSuperada],
	pq.PDSPASSQUALITYDISPOSITIONCODE																								AS [PQ_DispSuperada],
	
	-- Dimensiones
	pq.Dimension																													AS [PQ_DimDepar],	
	pq.Dimension2_																													AS [PQ_DimCCsto],	
	pq.Dimension3_																													AS [PQ_DimPropo],
	pq.Dimension4_																													AS [PQ_DimPropi],
	pq.Dimension5_																													AS [PQ_DimCanal],
	pq.Dimension6_																													AS [PQ_DimLinea],	
	pq.Dimension7_																													AS [PQ_DimEstad],
	
	-- Fechas del Sistema
	pq.ModifiedDateTime																												AS [PQ_ModEl],
	pq.ModifiedBy																													AS [PQ_ModPor],
	pq.CreatedDateTime																												AS [PQ_CreEl],
	f1.AA																															AS [PQ_CreAA],
	f1.AAAct																														AS [PQ_CreAAAct],
	f1.AM																															AS [PQ_CreAM],
	f1.MMMov																														AS [PQ_CreMMMov],
	f1.MMAct																														AS [PQ_CreMMAct],
	pq.CreatedBy																													AS [PQ_CrePor],
	pq.ModifiedTransactionID,
	pq.CreatedTransactionID,
	
	-- Cantidad
	pq.Qty																															AS [PQ_Cant],
	
	-- Informacion de la Validacion
	IssueDate_MPH																													AS [PQ_EmitidoElHs],	
	ValidatedBy																														AS [PQ_ValPorCod],
	isnull(rh.Nombre, '')																											AS [PQ_ValPorDes],
	ValidatedDateTime																												AS [PQ_ValElHs],
	f2.AA																															AS [PQ_ValAA],
	f2.AAAct																														AS [PQ_ValAAAct],
	f2.AM																															AS [PQ_ValAM],
	f2.MMMov																														AS [PQ_ValMMMov],
	f2.MMAct																														AS [PQ_ValMMAct],

	-- Demora en Dias
	datediff(dd, pq.CreatedDateTime, (case when ValidatedDateTime = '19000101' then getdate() else ValidatedDateTime end))			AS [PQ_DemDD],
	
	-- Articulo/Inventario -- Solo muestra las unidades afectadas por un pedido de calidad abierto para el Articulo / Lote y SubLote
	a.ArtCod																														AS [ArtCod],
	a.ArtDes																														AS [ArtDes],
	a.ArtGrupoCod																													AS [ArtGrupoCod],
	a.ArtGrupoDes																													AS [ArtGrupoDes],
	a.UnInve																														AS [ArtUnInv],
	id.InventBatchID																												AS [ArtLoteNro],
	inb.ExpDate																														AS [ArtLoteVto],
	id.InventSubBatchID																												AS [ArtSubLoteNro],
	id.InventLocationId																												AS [ArtAlmacen],
	inb.PdsVendBatchId																												AS [ArtLoteProv], --InventBatchPdsVendBatchId_MPH, 
	(case when pq.OrderStatus != 0
		then pq.OnHandSubBatchQty_MPH								-- Si es otro estado distinto a abierto leo la cantidad del registro
		else														-- Leo la antidad en el inventario para ese Art/Lote/SubLote.
			(select
				sum(insu.PostedQty - insu.Deducted + insu.Received)
			 from InventSum insu 
				inner join InventDim indi on
					indi.DataAreaID = insu.DataAreaID and
					indi.InventDimID = pq.InventDimID and ------- RC 2018/07/31 Mejora de Performance. De 28 seg pasa a 7 seg.								
					indi.InventDimID = insu.InventDimID
			 where
				insu.Closed = 0 and 
				insu.DataAReaID = pq.DataAreaID and
				insu.ItemID = pq.ItemID and
				indi.InventBatchId = id.InventBatchID and
				indi.InventSubBatchID = id.InventSubBatchID
			)
	 end)																															AS [ArtCant],
	 CtoGrupoCod																													AS [ArtCtoGrupoCod],
	 a.ArtTipo																														AS [ArtTipo] -- 20170707 - CG - UuMph - Corp -Ticket # 68043 
			
	/*
	'------> aun por revisar' [Aun por revisar],
	ACCOUNTRELATION,
	ROUTEOPRID,
	OPRNUM,
	WRKCTRID,
	ACCEPTABLEQUALITYLEVEL,
	TESTDESTRUCTIVE,
	ITEMSAMPLINGID,
	ROUTEID,
	PDSUPDATEINVBATCHATTRIBUTES,
	GROUPSEQUENCE_MPH,
	LOWER_MPH,
	UPPER_MPH,
	CRITIC_MPH,
	VERSION_MPH,
	REPLACE_MPH,
	CONTAINERS_MPH
	*/
  from XLS_DIM_Seguridad s
	inner join InventQualityOrderTable pq on
		pq.DataAreaID = s.DataAreaID
	inner join XLS_DIM_Articulos a on
		a.DataAreaID = pq.DataAreaID and
		a.ItemID = pq.ItemID
	left join XLS_ADM_RecursosHumanos rh on				-- Se cruza como Left por si el codigo de aprobador no existiera en el maestro de empleado
		rh.DataAreaID = a.DataAreaID and
		rh.Codigo = pq.ValidatedBy
	
	-- Dimensiones de Inventario
	inner join InventDim id on
		id.DataAreaID = pq.DataAreaID and
		id.InventDimID = pq.InventDimID
	left join InventBatch inb on										
		inb.DataAreaID = id.DataAreaID and
		inb.InventBatchID = id.InventBatchID and
		inb.ItemID = pq.ItemID 
		
	-- Manejo Fechas
	inner join XLS_DIM_TIEMPO f1 on						-- Cruza para manejor fechas de creacion de los PQ
		f1.fecha = convert(varchar(10), pq.CreatedDateTime ,112)
	inner join XLS_DIM_TIEMPO f2 on						-- Cruza para manejor fechas de validacion de los PQ
		f2.fecha = convert(varchar(10), (case when pq.ValidatedDateTime = '19000101' then getdate() else pq.ValidatedDateTime end) ,112)
		
	
	--select * from InventQualityOrderTable
	-- select CtoGrupoCod * from XLS_DIM_Articulos
	