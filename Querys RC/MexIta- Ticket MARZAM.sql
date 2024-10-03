
--ASN4500015963,4500015963,002_000004,PZJ547B,20220407,7501390913114,10,108357,20230605,1102,S/I,El producto se entrega al 100,A072711,49F5EBBC-4184-4BDB-8C92-BD82A34E2000

declare
  @DATAAREAID	nvarchar(004)		= '100',										-- Empresa de Ejecución
  @SALESID      nvarchar(020)		= '',											-- Nro de PEDIDO DE VENTA
  @TIPO_ACCION	nvarchar(010)		= 'M', 											-- A=Actualiza, M=Muestra, E=Envio Confirmado 
  @TIPO_SALIDA	nvarchar(003)		= 'TXT',										-- TXT=Texto, EDI=Salida Archivo, XLS=Excel de Control
  @CANTDIAS     int					= '3'											-- Cantidad de días a sumar a la fecha de creación del documento
		SELECT 
				'ASN' + st.CUSTOMERREF																							as [ASN],
				isnull(st.CUSTOMERREF,'')																						as [Num_OC],
				isnull(st.CONTACTPERSONID,'')																					as [Vendor],
				isnull(wbl.trailerId,'')																						as [Placa],
				convert(varchar(8),dateadd(day,@CANTDIAS,cit.CREATEDDATETIME),112)												as [Fecha_Entrega],    -- Sumar 3 días ponerlo como variable.
				isnull(sl.BarCode,'')																							as [SKU],
				convert(decimal,abs(isnull((select sum(Qty) from custInvoiceTrans
                    where custInvoiceTrans.DATAAREAID = sl.dataareaid and
					      custInvoiceTrans.InventTransId = sl.InventTransId),0)) )												as [QTY],
				isnull(ib.INVENTBATCHID,'')		                                                                                as [Lote],
				convert(varchar(8),ib.EXPDATE,112)																				as [Fecha_Caducidad],
				isnull((select top 1 a.TELEFAX	from Address a
				 inner join Custtable c on
					c.DATAAREAID = st.DATAAREAID and
					c.ACCOUNTNUM = st.CUSTACCOUNT
		        left join DirPartyTable dpt on
					dpt.DATAAREAID = st.DATAAREAID and
					dpt.PARTYID = c.PARTYID
				left join DirPartyAddressRelationship dpa on
					dpa.DataAreaID = dpt.DataAreaID and
					dpa.PartyID = dpt.PartyID
				left join DirPartyAddressRelationshi1066 dpar on
					dpar.PartyAddressRelationShipRecID = dpa.RecID  and
					dpar.DATAAREAID = dpa.DataAreaID
				where
					a.DataAreaID = dpar.RefCompanyID  and
					a.DataAreaID = st.DataAreaID and
					a.RecID = dpar.AddressRecID and
					a.NAME	= st.DELIVERYNAME),'') 															   					as [Almacen],
				isnull(wl.BRANDS_MPH,'')																						as [Cond_embalaje],
				isnull(wl.OBSERVATIONS_MPH,'')																					as [Observaciones],
				isnull((select top 1 InvoiceId
					from custInvoiceSalesLink 
                    where  custInvoiceSalesLink.OrigSalesId = st.SalesId
					order by InvoiceDate desc, InvoiceId desc),'')																as [Num_Factura],
				isnull(wbl.OBSERVATIONS,'')																						as [UUID],
				'ASN' + isnull(st.CUSTOMERREF,'')																				as [TITULO],
				'ASN' + isnull(st.CUSTOMERREF,'')																				+ ',' +
				isnull(st.CUSTOMERREF,'')																						+ ',' +
				isnull(st.CONTACTPERSONID,'')																					+ ',' +
				isnull(wbl.trailerId,'')																						+ ',' +
				convert(varchar(8),dateadd(day,@CANTDIAS,cit.CREATEDDATETIME),112)												+ ',' +    
				isnull(sl.BarCode,'')																							+ ',' +

				isnull(CONVERT(nvarchar(100), convert(decimal,(select sum(Qty) from custInvoiceTrans
                    where custInvoiceTrans.DATAAREAID = sl.dataareaid and
					      custInvoiceTrans.InventTransId = sl.InventTransId	)) ),'')											+ ',' +


				isnull(ib.INVENTBATCHID,'')                                                                                     + ',' +
				isnull(convert(varchar(8),ib.EXPDATE,112),'')																	+ ',' +
				isnull((select top 1 a.TELEFAX	from Address a
				inner join Custtable c on
					c.DATAAREAID = st.DATAAREAID and
					c.ACCOUNTNUM = st.CUSTACCOUNT
		        left join DirPartyTable dpt on
					dpt.DATAAREAID = st.DATAAREAID and
					dpt.PARTYID = c.PARTYID
				left join DirPartyAddressRelationship dpa on
					dpa.DataAreaID = dpt.DataAreaID and
					dpa.PartyID = dpt.PartyID
				left join DirPartyAddressRelationshi1066 dpar on
					dpar.PartyAddressRelationShipRecID = dpa.RecID  and
					dpar.DATAAREAID = dpa.DataAreaID
				where
					a.DataAreaID = dpar.RefCompanyID  and
					a.DataAreaID = st.DataAreaID and
					a.RecID = dpar.AddressRecID and
					a.NAME	= st.DELIVERYNAME),'')														   						+ ',' +
				isnull(wl.BRANDS_MPH,'')																						+ ',' +
				isnull(wl.OBSERVATIONS_MPH,'')																					+ ',' +
				isnull((select top 1 InvoiceId
					from custInvoiceSalesLink 
                    where  custInvoiceSalesLink.OrigSalesId = st.SalesId
					order by InvoiceDate desc, InvoiceId desc),'')																+ ',' +
				isnull(wbl.OBSERVATIONS,'')																								
																																as [TXT]
-- drop table #TmpMARZAM
--		into #TmpMARZAM
		FROM SALESTABLE as st 
 		--inner join XLS_DIM_Seguridad s on	s.DataAreaID = st.DATAAREAID
		inner join SALESLINE as sl ON 
			st.SALESID = sl.SALESID and 
			st.DATAAREAID = sl.DATAAREAID
		inner join custInvoiceTrans as cit ON
			sl.InventTransId = cit.InventTransId AND
			sl.DATAAREAID = cit.DATAAREAID 
		inner join inventtrans itr on
			itr.DataAreaId = sl.DataAreaId and
			itr.InventTransId = sl.InventTransId
		inner join inventdim idm on
			itr.DataAreaId = idm.DataAreaId and
			itr.inventdimid = idm.InventDimId
		inner join inventBatch ib on
			ib.DataAreaId = sl.DataAreaId and
			ib.InventBatchId = idm.InventBatchId and
			ib.ItemId = sl.ItemId
		left join WMSORDER as w on 
			w.DATAAREAID = st.DATAAREAID and
			w.INVENTTRANSID = sl.InventTransId
		left join WMSORDERTRANS as wo on 
			wo.DATAAREAID = st.DATAAREAID and
			wo.ORDERID = w.ORDERID 
	--		wo.INVENTTRANSID = itr.INVENTTRANSID 
        left join WMSSHIPMENT as ws on
		    ws.DATAAREAID = st.DATAAREAID and
			ws.SHIPMENTID = wo.SHIPMENTID
		left join WMSBillOfLading as wl on 
		    wl.DATAAREAID = st.DATAAREAID and
		    wl.SHIPMENTID = wo.SHIPMENTID 
		left join WMSBillOfLadingLogBook_MPH as wbl on
		   wbl.DATAAREAID = st.DATAAREAID and
		   wbl.BILLOFLADINGID = wl.BILLOFLADINGID 
		WHERE st.DATAAREAID = @DATAAREAID 
			AND (st.SALESID = isnull(@SALESID,'')
				 or ( isnull(@SALESID,'')='' and (sl.CREATEDDATETIME > '2022-04-01') ) )

