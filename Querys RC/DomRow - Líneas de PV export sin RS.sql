

select  -- Datos de la prefactura
/*	el.mphExportID											PrefNro,
	el.CreatedDate											PrefCreEl,
	year(el.CreatedDate)										PrefCreAA,
	right('0'+convert(varchar(02),month(el.CreatedDate)),2)   					PrefCreMM,
	convert(varchar(04),year(el.CreatedDate))+'-'+right('0'+convert(varchar(02),month(el.CreatedDate)),2)
													PrefCreAAMM,
	-- Datos Complementarios del Pedido / Linea
	st.DataAreaID											Area,
	st.mphSalesOrderType										PedidoCod,
	isnull((select sot.Description
		from MPHSalesOrderType sot WITH (NOLOCK)
		where sot.SalesOrderType = st.mphSalesOrderType
			and sot.DataAreaID = st.DataAreaID
			),'S/D')									PedidoDesc,
	 (case st.MPHBudgetType
		when 0 then 'Venta Plaza'
		when 1 then 'Exportacion'
		when 2 then 'Muestra Med'
		when 3 then 'Compras'
		when 4 then 'Inversiones'
		when 5 then 'Gastos'
		when 6 then 'Fason'
		when 7 then 'Servicios'
	  end) 												PedidoGrupo,
	rtrim(ltrim(st.SalesID))									NroPedido,
	(case st.SalesType
		when 0 then 'Diario'
		when 1 then 'Presupuesto'
		when 2 then 'Subscripcion'
		when 3 then 'Pedido de Vta'
		when 4 then 'Articulo Devuelto'
		when 5 then 'Pedido Marco'
		when 6 then 'Articulos Requeridos'
	 end)												PedidoTipo,
	(case (select sot.Active
		from MPHSalesOrderType sot WITH (NOLOCK)
		where sot.DataAreaID = st.DataAreaID 
			and sot.DataAreaID = st.DataAreaID
			and sot.SalesOrderType	= st.mphSalesOrderType
			)

		when 1 then 'Si'
		else 'No'
	 end)												Activo,
	(case sl.SalesStatus
		when 0 then 'S/D'
		when 1 then 
		   (case when sl.MPHExportSelection = 0
			then 'Orden Abierta'
			else 'PreFactu'
	 	   end) 			
		when 2 then 'Entregado'
		when 3 then 'Facturado'
		when 4 then 'Cancelado'
		else 'S/D'
	 end)												Estado,
	(case st.citaSalesStatus
		when 0 then 'S/D'
		when 1 then 'Suspendido'
		when 2 then 'Revisado'
		when 3 then 'Cerrado'
		when 4 then 'Aprobado'
		when 5 then 'Bloqueado'
		else 'S/D'
	 end)												EstadoDelPedido,
	isnull((select FirstName+' '+LastName
	from EmplTable et WITH (NOLOCK)
	where et.DataAreaID = st.DataAreaID
		and et.EmplID = st.SalesTaker
		),'S/D')										OperNombre,
	(case when st.SalesTaker = '' then 'S/D' else st.SalesTaker end)				OperCodigo,
	st.PostingProfile										Tipo,
	(case when st.mphRestrictionPolicy = '' then 'S/D' else st.mphRestrictionPolicy end)		PolitEntrega,

	-- Cliente a Entregar --
	ltrim(rtrim(st.CustAccount))									EntCliCodigo,
	st.SalesName											EntCliNombre,
	st.DeliveryAddress										EntCliDireccion,

	--st.DeliveryCountry										EntPais, -- V3  */
 	st.DeliveryCountryRegionID									EntPais, -- V4

/*	(case when (select ct.mphTownID
	 		from CustTable ct WITH (NOLOCK)
			where ct.DataAreaID = st.DataAreaID
				and ct.AccountNum = st.CustAccount
			) = ''
		then 'S/D'
		else (select ct.mphTownID
	 		from CustTable ct WITH (NOLOCK)
			where ct.DataAreaID = st.DataAreaID
				and ct.AccountNum = st.CustAccount
			)
	 end)												EntCliBrick,
	(case when (select ct.Phone from CustTable ct WITH (NOLOCK)
			where ct.DataAreaID = st.DataAreaID
				and ct.AccountNum = st.CustAccount
				) = ''
		then 'S/D'
		else (select ct.Phone from CustTable ct WITH (NOLOCK)
			where ct.DataAreaID = st.DataAreaID
			and ct.AccountNum = st.CustAccount
			)
	 end)												EntCliTelef,
	isnull((select ct.CustGroup
	 	from CustTable ct WITH (NOLOCK)
		where ct.DataAreaID = st.DataAreaID
			and ct.AccountNum = st.CustAccount
			),'S/D')									EntCliGrupo,
	sl.ConfirmedDlv      										EntFecha,
	year(sl.ConfirmedDlv)										EntAA,
	right('0'+convert(varchar(02),month(sl.ConfirmedDlv)),2)					EntMM,
	right('0'+convert(varchar(02),day(sl.ConfirmedDlv)),2)						EntDD,
	convert(varchar(04),year(sl.ConfirmedDlv))+'-'+right('0'+convert(varchar(02),month(sl.ConfirmedDlv)),2)
													EntAAMM,
	st.DlvTerm											EntForma,

	(case when st.mphCarrier = '' then 'S/D' else st.mphCarrier end)				Tramsportista,

	-- Cliente a Facturar --
	rtrim(ltrim(st.InvoiceAccount))									FacCliCodigo,
	isnull((select ct.Name
		from CustTable ct WITH (NOLOCK) 
		where ct.DataAreaID = st.DataAreaID
			and ct.AccountNum = st.InvoiceAccount
			),'S/D')									FacCliNombre,
	(case when (select ct.mphTownID
			from CustTable ct WITH (NOLOCK) 
			where ct.DataAreaID = st.DataAreaID
				and ct.AccountNum = st.InvoiceAccount
				) = ''
		then 'S/D'
		else (select ct.mphTownID
			from CustTable ct WITH (NOLOCK) 
			where ct.DataAreaID = st.DataAreaID
				and ct.AccountNum = st.InvoiceAccount
				)
	 end)												FacCliBrick,

	(case when (select ct.Phone from CustTable ct WITH (NOLOCK)
			where ct.DataAreaID = st.DataAreaID
				and ct.AccountNum = st.InvoiceAccount
				) = ''
		then 'S/D'
		else (select ct.Phone from CustTable ct WITH (NOLOCK)
			where ct.DataAreaID = st.DataAreaID
			and ct.AccountNum = st.InvoiceAccount
			)
	 end)												FacCliTelef,
	isnull((select ct.CustGroup
	 	from CustTable ct WITH (NOLOCK)
		where ct.DataAreaID = st.DataAreaID
			and ct.AccountNum = st.InvoiceAccount
			),'S/D')									FacCliGrupo,
	st.citaInvoiceFormat										FacFormato,
	st.TaxGroup											FacGrupoImp,	
	st.CurrencyCode											FacCliMoneda,
	st.Payment											ConPagoCod,
	st.PriceGroupID											GrupoPrecio,
	isnull((select Description
		from PaymTerm pt WITH (NOLOCK)
		where pt.PaymTermID = st.Payment
			and pt.DataAreaID = st.DataAreaID
			),'S/D')									ConPagoDes,
	st.DiscPercent											DtoCondPago,
	(case when st.SalesGroup = '' then'S/D' else st.SalesGroup end)					VtaGrupo,
	st.Dimension											PaisEmpr,
	st.Dimension2_											Empre,
	st.Dimension3_											Sucursal,
	st.Dimension5_											CodTrib,
	st.Dimension6_											CCosto,
	st.Dimension7_											Canal,
	st.Dimension9_											Estadistic,
	st.CreatedDate											CreadoEl,
	convert(smallDatetime,convert(varchar(20),dateadd(s,st.CreatedTime,  st.CreatedDate),113))	CreadoElHs,
	st.CreatedBy											CreadoPor,
	convert(smallDatetime,convert(varchar(20),dateadd(s,st.ModifiedTime,  st.ModifiedDate),113))	ModifiEl,
	st.ModifiedBy											ModifiPor,
	(case st.mphBlocked when 1 then 'Si' else 'No' end)						[Bloq?],
	st.mphFirstDiscountPercent									DtoComCab1,
	st.mphSecondDiscountPercent									DtoComCab2,
	st.mphThirdDiscountPercent									DtoFinCab3,

	-- Lineas del Pedido
	sl.LineNum											NroPos, */
	sl.ItemID											ArticuloCod,
	sl.Name												ArticuloDes,
/*	(case when sl.citaSupplementaryLine = 1 then 'Si' else 'No' end)				[Bonif?],
	sl.SalesUnit											Unidad,
	sl.SalesQty											Cantidad,
	sl.SalesDeliverNow										EntrAhora,

	(case when sl.MPHExportSelection = 0
		then sl.RemainSalesPhysical	
		else 0
	  end) 												EntrPendiente,	

	(case when sl.MPHExportSelection = 1
		then sl.RemainSalesPhysical	
		else 0
	  end) 												Prefactura,	

	(case sl.SalesStatus
		when 4 then 0
		else
		  (sl.SalesQty - sl.RemainSalesPhysical)
	 end)												Facturado,
	sl.CurrencyCode											Moneda,
	sl.SalesPrice											PrecioUnit,  
	sl.LineAmount											ImporteNeto,
	sl.Dimension4_											Linea,
	sl.Dimension8_          									SubMarca,
	sl.mphBatchInputUniqueId									BIInterno,
	ltrim(rtrim(sl.mphCustBatchInputID))								AS [PoliticaMPH],

	-- Verifica si tiene proforma o no, indicando su numero
        (case when sl.MPHExportSelection = 0
		then 'No'
		else 'Si'
	 end) 												[Prafac?],

	-- Indices de Analisis
	datediff(dd, sl.ConfirmedDlv, el.CreatedDate)							[PrefVSEnt],
	datediff(dd, el.CreatedDate, getdate())								[PrefVSHoy],

	-- Evalua la criticidad basados en 30 dias para la gestion antes de la fecha de entrega
	(case when datediff(dd, sl.ConfirmedDlv, el.CreatedDate) < -30
		then 'En Tiempo'
		else 'Critico'
	 end)												[SitLocal],

	-- Evalua la criticidad basados en 40 dias para la gestion antes de la fecha de entrega
	(case when datediff(dd, el.CreatedDate, getdate()) < 30
		then 'En Tiempo'
		else 'Critico'
	end)												[SitCliente], */
	-- Muestra el Registro Sanitario si lo tiene
	isnull( (select HEALTHREGISTRATIONID+' '+HEALTHREGISTRATIONDESC from HEALTHREGISTRATION_MPH h 
			where sl.DataAreaID = h.DATAAREAID 	and sl.ITEMID = h.ITEMID and h.HEALTHREGISTRATIONSTATUS = 1 --Activo
			and h.REGISTRATIONDUEDATE > GETDATE() and h.REGISTRATIONCOUNTRYREGIONID = st.DELIVERYCOUNTRYREGIONID), '')	[RegSanitario]

from 	SalesTable st, SalesLine sl, mphexportline el, mph_XLSViewCompany xv
where  st.DataAreaID = xv.mph_DataAreaID and mph_IdView = 'XLS_XPO_PedidosPrefacturados' and mph_Step = 0 and mph_Action = 0
	and st.DataAreaID = sl.DataAreaID
	and st.SalesID = sl.SalesID
	and st.MPHBudgetType = 1 
	and sl.SalesID 			= el.SalesID
	and sl.LineNum 			= el.SalesLineNum
	and sl.DataAreaID 		= el.DataAreaID
	and sl.RemainSalesPhysical	<> 0
	and sl.MPHExportSelection	 = 1
	and sl.DELIVERYCOUNTRYREGIONID in ('CR','HN','SV','NI','GT','PA')
order by [RegSanitario] asc, EntPais, ArticuloCod

--select * from salesline