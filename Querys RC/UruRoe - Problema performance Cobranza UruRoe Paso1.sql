
select-- count(*) -- ct.TRANSDATE, cij.INVOICEDATE,* 
  		'Paso 01'																													as [Paso],
 -- 		@AHORA																														as [ActualizadoAl],
 		ct.DataAreaID																												as [Area], 
		'Abiertas'																													as [OpeEstado],
		(case when ct.TransType = 15 then 'Cobro' else 'Factura' end)																as [OpeTipo],
		ct.TransType																												as [OpeOrigCod],
		dbo.fc_ENUM_TransType(ct.TransType)																							as [OpeOrigDes],
		ct.TransDate																												as [OpeFecha],		--// Fecha de la Transacción //-- 
		(case when ct.DueDate > getdate() then ct.DueDate else convert(varchar(10), getdate(), 112) end)							as [LiqFecha],		--// Fecha de Liquidación //--
--		(case when ct.DueDate <= @FECHAATRASDEUDA
--			then @FECHAATRASDEUDA
--			else ct.DueDate
--		 end)																														as [VtoFecha],		--// Fecha Vencimiento del Documento //--

		--// Analisis de Vencimientos (basado en AX Estandar
		(case when datediff(dd, ct.DueDate, convert(varchar(10), getdate(), 112)) > 0 then 'Si' else 'No' end)						as [VtoEstado],
		datediff(dd, ct.DueDate, getdate())																							as [VtoDias],
		(case 
			when datediff(dd, ct.DueDate, convert(varchar(10), getdate(), 112)) > 0
				then																	  '1-Crítico = Vencido '
				else (case 
						when datediff(dd, ct.DueDate, getdate()) between  -07 and  00 then '2-Entre  0 y   7 Días'
						when datediff(dd, ct.DueDate, getdate()) between  -15 and -08 then '3-Entre  8 y  15 Días'
						when datediff(dd, ct.DueDate, getdate()) between  -30 and -16 then '4-Entre 16 y  30 Días'
						when datediff(dd, ct.DueDate, getdate()) between  -60 and -31 then '5-Entre 31 y  60 Días'
						when datediff(dd, ct.DueDate, getdate()) between  -90 and -61 then '6-Entre 61 y  90 Días'
						when datediff(dd, ct.DueDate, getdate()) between -120 and -91 then '7-Entre 91 y 120 Días'
						else															   '8-Mayor de 120 Dias  ' 
					  end)
		 end)																														as [VtoAnalisis],
		 
		--<+ GN 21/11/2012>---------------------------------------------------------------------------------------------------------------
		-- NOTA: Este bloque permite analizar los vencimientos de la deuda en funcion de al fecha de entrega de la factura al cliente.	--
		--		 Habitualmente una via de al factura, sellada con la fecha de recepcon regresa a la empreas. Esa fecha es registrada	--
		--		 en Diarios\Facturas. Ademas puede definirse una prorroga indistintamente se indique o no una fecha de entrega.			--
		----------------------------------------------------------------------------------------------------------------------------------

		--// Fecha de Entrega del documento o la original de la operación si no se hubiera ingresado
		isnull((case when cij.ReceptionDate_MPH = '19000101' then ct.TransDate else cij.ReceptionDate_MPH end),ct.TransDate)		as [OpeFechaEnt],
		 
		--// Analisis de Vencimientos (basado en Fecha que el Cliente recibio la factura
		isnull(cij.ExtensionDays_MPH, 0) * -1																						as [VtoProrroga],
		(case when isnull(cij.ReceptionDate_MPH, ct.DueDate)  = '19000101'
			then (case when datediff(dd, dateadd(dd, ExtensionDays_MPH, ct.DueDate), convert(varchar(10), getdate(), 112)) > 0
					then 'Si'
					else 'No'
				  end) 
			else (case when datediff(dd, dateadd(dd, isnull(ExtensionDays_MPH,0), dateadd(dd, datediff(dd, ct.TransDate, ct.DueDate), isnull(cij.ReceptionDate_MPH, ct.TransDate))),
										 convert(varchar(10), getdate(), 112)
										 ) > 0
					then 'Si'
					else 'No'
				  end)
		 end)																														as [VtoEstadoEnt],

		--// Nueva fecha de vencimiento basado en la fecha de entrega del documento + la condicion de pago + Prorroga
		isnull((case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
					then ct.TransDate
					else cij.ReceptionDate_MPH
				end) +												
				datediff(dd, ct.TransDate, ct.DueDate)  +															
				isnull(cij.ExtensionDays_MPH, 0), ct.DueDate)																		as [VtoFechaEnt],
		
		--// Dias para el nuevo Vto. o dias de Vencido																									
		datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
						then ct.TransDate
						else isnull(cij.ReceptionDate_MPH, ct.TransDate)
					end)+ 
					datediff(dd, ct.TransDate, ct.DueDate) +
					isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112)
				 )																													as [VtoDiasEnt],
				 
		--// Basado en los dias de nuevo vencimeinto anterior se analisa su criticidad
		(case 
			when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
						then ct.TransDate
						else isnull(cij.ReceptionDate_MPH, ct.TransDate)
					end)+ 
					datediff(dd, ct.TransDate, ct.DueDate) +
					isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
				  ) > 0
				then																							'1-Crítico = Vencido '
				else (case 
						when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
									then ct.TransDate
									else isnull(cij.ReceptionDate_MPH, ct.TransDate)
								end)+ 
								datediff(dd, ct.TransDate, ct.DueDate) +
								isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
								) between -07 and  00 then														'2-Entre  0 y   7 Días'
						when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
									then ct.TransDate
									else isnull(cij.ReceptionDate_MPH, ct.TransDate)
								end)+ 
								datediff(dd, ct.TransDate, ct.DueDate) +
								isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
								) between -15 and -08 then														'3-Entre  8 y  15 Días'
						when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
									then ct.TransDate
									else isnull(cij.ReceptionDate_MPH, ct.TransDate)
								end)+ 
								datediff(dd, ct.TransDate, ct.DueDate) +
								isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
								) between -30 and -16 then														'4-Entre 16 y  30 Días'
						when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
									then ct.TransDate
									else isnull(cij.ReceptionDate_MPH, ct.TransDate)
								end)+ 
								datediff(dd, ct.TransDate, ct.DueDate) +
								isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
								) between -60 and -31 then														'5-Entre 31 y  60 Días'
						when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
									then ct.TransDate
									else isnull(cij.ReceptionDate_MPH, ct.TransDate)
								end)+ 
								datediff(dd, ct.TransDate, ct.DueDate) +
								isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
								) between -90 and -61 then														'6-Entre 61 y  90 Días'
						when (datediff(dd,(case when isnull(cij.ReceptionDate_MPH, ct.TransDate) = '19000101'
									then ct.TransDate
									else isnull(cij.ReceptionDate_MPH, ct.TransDate)
								end)+ 
								datediff(dd, ct.TransDate, ct.DueDate) +
								isnull(cij.ExtensionDays_MPH, 0), convert(varchar(10), getdate(), 112))
								) between -120 and -91 then														'7-Entre 91 y 120 Días'
						else																					'8-Mayor de 120 Dias  ' 
					  end)
		 end)																														as [VtoAnalisisEnt],
		
		--// Datos del Cliente //--
		ct.AccountNum																												as [CliCod],
		-- VtoFecha - OpeFecha // Agregado por GN para Leterago 1
		(case when datediff(dd, ct.TransDate, isnull(ct.DueDate, ct.TransDate)) < 0
			then 0
			else datediff(dd, ct.TransDate, isnull(ct.DueDate, ct.TransDate)) 
		 end)																														as [CliConPago], 

		--// Informacion del Cobro y Partidas Referenciadas y/o Abiertas //--
		ct.CancelledPayment																											as [DocCancelado],
		ct.Invoice																													as [DocOrig],
		''																															as [DocOrigFecha],
		ct.PaymReference																											as [DocRefer],
		pre.PreImpNro																												as [DocOrigPapel],
		(select count(1)		
		 from XLS_DIM_Preimpresos pre1
		 where pre1.Area = pre.Area and
			pre1.AxDocNro = pre.AxDocNro and								-- Nro Legal de AX   --'00000012'
			pre1.PreImpAnuladoCod= pre.PreImpAnuladoCod	and					-- No Anulado
			pre1.AxDocNroVia = pre.AxDocNroVia								-- 1=Via 1
			)																														as [DocOrigPapelCant],	
		ct.CurrencyCode																												as [DocMon] ,
		ct.Txt																														as [DocDescripcion],
		'Part. Abierta'																												as [DocLiq ],
		ct.Voucher																													as [DocVouchOrig],

		--// Dimensiones Financieras --
		ct.Dimension																												as [DocDepar],
		ct.Dimension2_																												as [DocCCsto],
		ct.Dimension3_																												as [DocPropo],
		ct.Dimension4_																												as [DocPropi],
		ct.Dimension5_																												as [DocCanal],
		ct.Dimension6_																												as [DocLinea],

		'Part. Abierta'																												as [DocVouchLiq ],
		'Part. Abierta'																												as [DocDiarioLiq],

		--// Información Derivada de las lineas de la Factura
		isnull(cit.ItemID,'')																										as [ArtCod],

		--// Accion Sugerida
		(case when cto.AmountCur < 0 then 'Falta Liquidar' else '' end)																as [AccionSugerida],

		--// Valores en Moneda Origial (Sin Impuesto) //--
		0																															as [ValPartLiquidMonOrig],
		(case
			when (ct.TransType = 0 or ct.TransType = 15)
			then round(cto.AmountCur,2)
			else round(cto.AmountCur * (cit.LineAmount / cij.InvoiceAmount),2)
		 end)																														as [ValPartAbiertaMonOrig],

		--// Valores en Moneda Origial (Solo Impuesto) //--
		0																															as [ValPartLiquidMonOrigTax],
		(case
			when (ct.TransType = 0 or ct.TransType = 15)
			then 0
			else round((cit.TaxAmount) / cij.InvoiceAmount * cto.AmountCur,2)
		 end)																														as [ValPartAbiertaMonOrigTax],

		--// Valores en Moneda Local al Tipo de Cambio del Dia (Sin Impuesto)
		0																															as [ValPartLiquidMonLoc],
		(case
			when ct.TransType in (00, 15)
			then round(cto.AmountMST,2)
			else round((cit.LineAmountMST) / cij.InvoiceAmountMST * cto.AmountMST,2)
		 end)																														as [ValPartAbiertaMonLoc],

		--// Valores en Moneda Local al Tipo de Cambio del Dia (Solo Impuesto)
		0																															as [ValPartLiquidMonLocTax],
		(case
			when ct.TransType in (00, 15)
			then 0
			else round((cit.TaxAmountMST) / cij.InvoiceAmountMST * cto.AmountMST,2)
		 end)																														as [ValPartAbiertaMonLocTax],

		
		--// Valores en Moneda Secundaria al Tipo de Cambio del Dia (Sin Impuesto)
		0																															as [ValPartLiquidMonSec],
		(case
			when ct.TransType in (00, 15)
			then (case
					when ct.CurrencyCode = s1.SecondaryCurrencyCode
					then round(cto.AmountCur,2)
					else round(dbo.fc_Cambio(cto.AmountCur,ct.TransDate, ct.CurrencyCode, s1.SecondaryCurrencyCode, ct.DataAreaID),2)
				  end)
			else (case
					when ct.CurrencyCode = s1.SecondaryCurrencyCode
					then round((cit.LineAmount) / cij.InvoiceAmount*cto.AmountCur,2)
					else round(dbo.fc_Cambio((cit.LineAmount) / cij.InvoiceAmount * cto.AmountCur,
												ct.TransDate, ct.CurrencyCode, s1.SecondaryCurrencyCode, ct.DataAreaID)
								,2)
				  end)
		 end)																														as [ValPartAbiertaMonSec],
		 
		--// Valores en Moneda Secundaria al Tipo de Cambio del Dia (Solo Impuesto)
		0																															as [ValPartLiquidMonSecTax],
		(case
			when ct.TransType in (00, 15)
			then 0
			else (case
					when ct.CurrencyCode = s1.SecondaryCurrencyCode
					then round((cit.TaxAmount) / cij.InvoiceAmount*cto.AmountCur,2)
					else round(dbo.fc_Cambio((cit.TaxAmount) / cij.InvoiceAmount * cto.AmountCur,
												ct.TransDate, ct.CurrencyCode, s1.SecondaryCurrencyCode, ct.DataAreaID)
								,2)
				  end)
		 end)																														as [ValPartAbiertaMonSecTax],
		 st.CUSTOMERREF																												as [CustomerRef],
         ''																											 				as [DiasRealesPago], -- (case when ct.DueDate > getdate() then ct.DueDate else convert(varchar(10), getdate(), 112) end)	 -	''
         --+ADD #68923 Agregar Campo a deuda por cobrador  
         st.DELIVERYADDRESS																											AS [DELIVERYADDRESS],
         st.DELIVERYNAME																											AS [DELIVERYNAME]
         ---ADD #68923 Agregar Campo a deuda por cobrador  

  from XLS_DIM_Seguridad  s1										-- Seguridad
 inner join CustTrans ct on      -- Transacciones de Clientes
		ct.DataAreaID = s1.DataAreaID and
		ct.DataAreaID = '010' and									-- No poner este filtro en el Where porque la consulta no termina (Todo un enigma)
		ct.BillOfExchangeStatus = 0 and
	--	ct.TransType > 0	and								-- RC - 2019/10/25 - Mejora de Performace	
		ct.TransType <> 9		
  inner join CustTransOpen cto on									-- Transacciones Abiertas			
		cto.DataAreaID = ct.DataAreaID and
		cto.AccountNum = ct.ACCOUNTNUM and								-- RC - 2019/10/25 - Mejora de Performace
		cto.RefRecID = ct.RecID
 left join CustInvoiceJour cij on									-- Si Cruza es porque el registro analizado es una factura
		cij.DataAreaID		= ct.DataAreaID and
		cij.InvoiceID		= ct.Invoice and
		cij.InvoiceAccount	= ct.AccountNum and
		cij.InvoiceDate		= ct.TransDate 
  left join CustInvoiceTrans cit on
		cit.DataAreaID = ct.DataAreaID and			
		cit.SalesID = cij.salesID and
		cit.InvoiceID = ct.Invoice and
		cit.InvoiceDate = ct.TRANSDATE and
		cit.NumberSequenceGroup = cij.NumberSequenceGroup
		--and ct.TransType != 0									-- RC - 2019/10/25 - Mejora de Performace		
		and ct.TransType > 0									-- RC - 2019/10/25 - Mejora de Performace	
 left join XLS_DIM_Preimpresos pre on
		pre.Area = ct.DataAreaID and
		pre.AxDocNro = ct.Invoice and									-- Nro Legal de AX   --'00000012'
		pre.PreImpAnuladoCod= 0	and										-- No Anulado
		pre.AxDocNroVia = 1		
	LEFT JOIN SALESTABLE st ON
		st.DATAAREAID = cij.DATAAREAID AND
		st.INVOICEACCOUNT = cij.INVOICEACCOUNT AND
		st.SALESID = cij.SALESID		
		-- 20200612 - Dejo de traer información histórica en una consulta NO OLAP!
	--	WHERE CONVERT(DATE, ct.TransDate) >= '2020-05-17'  
		