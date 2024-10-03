

SELECT ot.DATAAREAID										as AREA
     , sh.SHIPMENTID										as ENVIO
     , en1.EnumDes													as ENV_Estado
     , en2.EnumDes													as SEL_Estado
     , ot.SHIPMENTIDORIGINAL										as ENVORIGINAL
     , en3.EnumDes													as LIN_Estado
     , ot.DLVDATE											as ENV_Fecha

--/*
     --// REMITO
     , isnull(ltrim(rtrim(cpj.PackingSlipId)),'')									as RemNro
	 , convert(varchar(10), (case when isnull(cpj.CreatedDateTime,'19000101') = '19000101'
								then getdate() 
								else (select dateadd(hh, datediff(hh, getutcdate(), getdate()), cpj.CreatedDateTime))
							  end), 103)											as RemCreEl
	 , isnull(cpj.CreatedBy,'?')													as RemCrePor

	 --// FACTURACION //--
	 , isnull(ltrim(rtrim(cij.InvoiceID)),'')										as NroFactura
	 , convert(varchar(10), (case when isnull(cij.CreatedDateTime,'19000101') = '19000101'
								then getdate() 
								else (select dateadd(hh, datediff(hh, getutcdate(), getdate()), cij.CreatedDateTime))
							  end), 103)											as FechaFactura
	 , isnull(cij.CreatedBy,'?')													as FacCrePor
--*/

     , isnull(ot.ROUTEID,'S/D')								as IDRUTA
	 , ltrim(str(ot.INVENTTRANSTYPE,2))
	 + case ot.INVENTTRANSTYPE
			when 0 then '- Ped. Venta'
			when 2 then '- Producción'
			when 3 then '- Ped. Compra'
			when 4 then '- Transaccion'
			when 5 then '- Perdidas/Ganancias'
			when 6 then '- Transferencia'
			when 7 then '- Linea Prod.'
			else '- S/Especificar'
       END													as TipoRefEnv
     , ot.INVENTTRANSREFID									as RefEnEnvio
     , isnull(sl.INVENTREFID,'s/Ref.')						as Referencia
	 , convert(varchar(10), isnull(sl.ReceiptDateRequested,'19000101'), 103)					as FecRecSol
	 , convert(varchar(10), isnull(sl.ReceiptDateConfirmed,'19000101'), 103)					as FecRecCnf
	 , isnull(sl.RemainSalesPhysical,0)						as VtaPenEnt
     , ot.CUSTOMER											as CLIENTE
     , isnull(ct.NAME,'')									as CLINombre
     , isnull(st.DIMEMPLID_MPH,'')							as EmpGasto
     , isnull(st.SALESNAME,'')								as EmpGtoNombre
     , ot.ITEMID											as ARTICULO
     , it.ITEMNAME											as NOMBRE
     , ot.QTY												as CANTIDAD
	 , itm.UNITID 											as Uni
     , ot.INVENTDIMID										as InventDimId
     , id.INVENTSITEID										as SITIO
     , id.INVENTLOCATIONID									as ALMACEN
     , id.INVENTBATCHID										as LOTE
     , ib.EXPDATE											as VTOLOTE
--SCa+ 19/10/2015 - Se agregan estos campos por pedido de Carolina Abreu
     , ib.PDSVENDBATCHID									as LoteProv
	 , convert(varchar(10), isnull(ib.PDSVENDEXPIRYDATE,'19000101'), 103) as VtoLoteProv
     , ib.PDSCOUNTRYOFORIGIN1								as Origen1LoteProv
--SCa- 19/10/2015 - Se agregan estos campos por pedido de Carolina Abreu
     , id.WMSLOCATIONID										as UBICACION
     , id.INVENTLEGALNUMID									as DUA
     , id.WMSPALLETID										as NroPALLET
/*     , CASE when id.INVENTCONTAINERID = (SELECT MIN(INVENTCONTAINERID) 
										FROM INVENTDIM id2, WMSORDERTRANS ot2
										WHERE id2.INVENTCONTAINERID <> '' 
										  and id2.DATAAREAID = ot2.DATAAREAID 
										  and ot2.INVENTDIMID = id2.INVENTDIMID
										  and id2.DATAAREAID = id.DATAAREAID 
										  and id2.WMSPALLETID = id.WMSPALLETID 
										  and ot2.DATAAREAID = ot.DATAAREAID 
										)
			then 1
			else 0
	   END													as CtaPALLETS */
	   	 , CASE WHEN MICI.MININVENTCONTAINERID IS NULL THEN 0 else 1 END				as CtaPALLETS
     , isnull(id.INVENTCONTAINERID,'N/A')					as BULTO
     , ic.INVENTCONTAINERID
     , ic.NETWEIGHT											as PNETO
     , ic.GROSSWEIGHT										as PBRUTO
     , isnull(ic.LENGTH,0)/100								as LARGO
     , isnull(ic.HEIGHT,0)/100								as ALTO
     , isnull(ic.WIDTH,0)/100								as ANCHO
     , isnull((ic.LENGTH * ic.HEIGHT * ic.WIDTH),0)/1000000	as VOLBULTO
-- + FUM RC - 2020/02/06 - Se agrega Cliente Entrega final y su Nombre y los 4 campos nuevos de Sincronismo
	 --Nombres de los clientes
	 , isnull(st.CustFinalDestinationAccou40002,'')			as CliEntFinCod
	 , isnull(ct3.Name,'')									as CliEntFinDes
	 , case sh.SHIPMENTPICKINGPRIORITY_MPH			
	   when 0 then 'Baja'
	   when 1 then 'Media'
	   when 2 then 'Alta'
	   else 'S/D'					   						
	   end													as PrioEnv
	 , convert(varchar(10), isnull(sh.SHIPPINGDATEREQUESTED_MPH,'19000101'), 103) as FecEnvSol
	 , case sh.SHIPDLVMODE_MPH			
	   when 0 then 'Marítimo'
	   when 1 then 'Aéreo'
	   when 2 then 'Terrestre'
	   else 'S/D'					   						
	   end													as EnvModEnt
	 , convert(varchar(10), isnull(sh.SHIPDATETIME_MPH,'19000101'), 103)		as FecHorFinEnv
-- - FUM RC - 2020/02/06 - Se agrega Cliente Entrega final y su Nombre y los 4 campos nuevos de Sincronismo

--12/12/2016 SC+	Se agrega Texto de Referencia de Cliente (OC recibida de ELog)
     , isnull(sl.CUSTOMERREF,'')							as LinRefCli,
--12/12/2016 SC-	Se agrega Texto de Referencia de Cliente (OC recibida de ELog)

	--- GC 94801 13/03/2020 Agregar campos MarcaDeEmpaque y E-Remito
-- + FUM 2020/06/09 - Ajustar el despliegue del campo, dado q es un eNUM
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	    case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end														as MarcaEmpaque,
-- - FUM 2020/06/09 - Ajustar el despliegue del campo, dado q es un eNUM
	itj.EPACKINGSLIP_MPH									as ERemito


FROM XLS_DIM_Seguridad s											-- Esquema de Seguridad
inner JOIN WMSShipment sh ON s.DATAAREAID = sh.DATAAREAID
inner JOIN WMSOrderTrans ot ON sh.DataAreaID = ot.DataAreaID
		and sh.SHIPMENTID = ot.SHIPMENTID
		and inventlocationid = 'DhlExport00'
inner join XLS_DIM_ENUM en1 on								 
		en1.EnumID = 'fc_ENUM_EnviosPicking_E' and
		en1.EnumCod= sh.STATUS
inner join XLS_DIM_ENUM en2 on								 
		en2.EnumID = 'fc_ENUM_EnviosPicking_X' and
		en2.EnumCod= sh.PICKEXPEDITIONSTATUS
inner join XLS_DIM_ENUM en3 on								 
		en3.EnumID = 'fc_ENUM_EnviosPicking_X' and
		en3.EnumCod= ot.EXPEDITIONSTATUS
LEFT JOIN INVENTDIM id ON id.DATAAREAID = ot.DATAAREAID
		and id.INVENTDIMID = ot.INVENTDIMID
LEFT JOIN InventBatch ib on ib.DataAreaID = id.DataAreaID 	-- Recuparar el Vencimiento del Lote
		and	ib.InventBatchId = id.InventBatchID 
		and	ib.ItemID = ot.ItemID
LEFT JOIN InventContainer_MPH ic ON ic.DATAAREAID = ot.DATAAREAID
		and ic.INVENTCONTAINERID = id.INVENTCONTAINERID
LEFT JOIN CUSTTABLE ct ON ct.DATAAREAID = ot.DATAAREAID
		and ct.ACCOUNTNUM = ot.CUSTOMER
inner JOIN INVENTTABLE it ON it.DATAAREAID = ot.DATAAREAID
		and it.ITEMID = ot.ITEMID
inner JOIN INVENTTABLEMODULE itm ON itm.DATAAREAID = ot.DATAAREAID
		and itm.ITEMID = it.ITEMID
		and itm.MODULETYPE = 0				-- 0=Inventario 1=Compra 2=Venta

LEFT JOIN SALESLINE sl on sl.DATAAREAID = ot.DATAAREAID
		and sl.SALESID = ot.INVENTTRANSREFID
		and sl.INVENTTRANSID = ot.INVENTTRANSID
		and sl.ITEMID = ot.ITEMID
LEFT JOIN SALESTABLE st on st.DATAAREAID = ot.DATAAREAID
		and sl.SALESID = st.SALESID
-- + FUM RC - 2020/02/06 - Se agrega Cliente Entrega final y su Nombre y los 4 campos nuevos de Sincronismo
left join CustTable ct3 on										-- Recupera los datos del Cliente Destino Final
		ct3.DataAreaID = st.DataAreaID and
		ct3.AccountNum = st.CustFinalDestinationAccou40002
-- - FUM RC - 2020/02/06 - Se agrega Cliente Entrega final y su Nombre y los 4 campos nuevos de Sincronismo
--/*
LEFT JOIN (SELECT id2.DATAAREAID, id2.WMSPALLETID, MIN(INVENTCONTAINERID) AS 'MININVENTCONTAINERID'
										FROM INVENTDIM id2
										INNER JOIN WMSORDERTRANS ot2
										  ON id2.DATAAREAID = ot2.DATAAREAID 
										  and ot2.INVENTDIMID = id2.INVENTDIMID
										WHERE id2.INVENTCONTAINERID <> ''
										GROUP BY id2.DATAAREAID, ot2.DATAAREAID, id2.WMSPALLETID) MICI ON
										  MICI.DATAAREAID = id.DATAAREAID 
										  and MICI.WMSPALLETID = id.WMSPALLETID
										  and MICI.MININVENTCONTAINERID = id.INVENTCONTAINERID
-----------------------------------------------------------------
-- GC 13/03/2020  Se agrega esta parte para obtener el E-Remito
-----------------------------------------------------------------
        left join INVENTTRANSFERLINE itl on
            itl.DATAAREAID = ot.DATAAREAID and
            itl.InventTransId = ot.InventTransId  
        left join INVENTTRANSFERTABLE itt on
            itl.DATAAREAID = ot.DATAAREAID and
            itl.TRANSFERID = itt.TRANSFERID and
			itl.ITEMID = ot.ITEMID  and
			itl.INVENTDIMID = ot.INVENTDIMID
        left join INVENTTRANSFERJOUR itj on
            itj.DATAAREAID = ot.DATAAREAID and
            itj.TRANSFERID = itt.TRANSFERID 

------------ Inicio Corregido por CG 20140219 ----------------
--------------------------------------------------------------
-- Cruzo con las Facturas Registradas						-- Registro de la Factura

		---<+> NUEVO PARA RELACIONAR FACTURA CON ENVIO
left join shipCarrierShipmentInvoice fca on
		fca.DATAAREAID = sh.DATAAREAID and
		fca.WMSShipmentID = sh.ShipmentId 
		---<->
left join CustInvoiceJour cij on
		cij.DataAreaID =  fca.DataAreaID and
		cij.RecID = fca.CustInvoiceJourRefRecId 

left join CustInvoiceTrans cit on
		cit.DataAreaID = cij.DataAreaID and
		cit.salesID = cij.salesID and
		cit.invoiceid = cij.invoiceid and
		cit.numberSequenceGroup = cij.numberSequenceGroup and
		cit.DataAreaID = sl.DataAreaID and
		cit.OrigSalesID = sl.salesID and
		cit.InventTransID = sl.InventTransID and
		cit.ItemID = sl.ItemID

--------------------------------------------------------------
-- Cruzo con las Remitos Registrados
		---<+> NUEVO PARA RELACIONAR REMITO CON ENVIO
left join ShipCarrierShipmentPackingSlip rca on
		rca.DataAreaID = sh.DataAreaID and
		rca.WMSShipmentID = sh.ShipmentId
				
left join CustPackingSlipJour cpj on
		cpj.DataAreaID = rca.DataAreaID and
		cpj.PackingSlipId = rca.SalesPackingSlipID
								
left join CustPackingSlipTrans cpt on						-- Registro de Remito
		cpt.DataAreaID = cpj.DataAreaID and
		cpt.salesID = cpj.salesID and
		cpt.PackingSlipId = cpj.PackingSlipId and
		cpt.numberSequenceGroup = cpj.numberSequenceGroup and
		cpt.DataAreaID = sl.DataAreaID and
		cpt.OrigSalesID = sl.salesID and
		cpt.InventTransID = sl.InventTransID and
		cpt.ItemID = sl.ItemID

where (convert(datetime, FechaFactura,103) >= DATEADD(dd, -45, GETDATE()) OR isnull(FechaFactura,'') = '')

	---<->