select count(*) --ct.TRANSDATE,ct.INVOICE,*
	  from XLS_DIM_Seguridad  s1										-- Seguridad
	  inner join CustTrans ct on										-- Transacciones de Clientes
		ct.DataAreaID = s1.DataAreaID and
		ct.DataAreaID = '010' and									-- No poner este filtro en el Where porque la consulta no termina (Todo un enigma)
		ct.BillOfExchangeStatus = 0 and
		ct.TransType <> 9												-- Se excluyen los ajustes al cambio	
		--AND ct.Voucher = 'SInCli_000339'
	  -- Recupera el numero de Preimpreso -- select * from XLS_DIM_Preimpresos
	  left join XLS_DIM_Preimpresos pre on
		pre.Area = ct.DataAreaID and
		pre.AxDocNro = ct.Invoice and									-- Nro Legal de AX   --'00000012'
		pre.PreImpAnuladoCod= 0	and										-- No Anulado
		pre.AxDocNroVia = 1												-- 1=Via 1

	  inner join CustTransOpen cto on									-- Transacciones Abiertas			
		cto.DataAreaID = ct.DataAreaID and
	--	cto.AccountNum = ct.ACCOUNTNUM and								-- RC - 2019/10/25 - Mejora de Performace
		cto.RefRecID = ct.RecID
	  left join CustInvoiceJour cij on									-- Si Cruza es porque el registro analizado es una factura
		cij.DataAreaID		= ct.DataAreaID and
		cij.InvoiceID		= ct.Invoice and
		cij.InvoiceAccount	= ct.AccountNum and
		cij.InvoiceDate		= ct.TransDate 

		-- +MR Ticket #64055-20170215 Modificar Reporte FINA_Cobranza Partidas Abiertas y Cobradas  
		LEFT JOIN SALESTABLE st ON
		st.DATAAREAID = cij.DATAAREAID AND
		st.INVOICEACCOUNT = cij.INVOICEACCOUNT AND
		st.SALESID = cij.SALESID					-- Recupera los PV que fueron facturados
		-- -MR Ticket #64055-20170215 Modificar Reporte FINA_Cobranza Partidas Abiertas y Cobradas 
		
	  -- Cruzo para llegar a la linea de la Factura
	  left join CustInvoiceTrans cit on
		cit.DataAreaID = cij.DataAreaID and			
		cit.SalesID = cij.salesID and
		cit.InvoiceID = cij.InvoiceID and
		cit.InvoiceDate = cij.InvoiceDate and
		cit.NumberSequenceGroup = cij.NumberSequenceGroup
		--and ct.TransType != 0									-- RC - 2019/10/25 - Mejora de Performace		
		and ct.TransType > 0									-- RC - 2019/10/25 - Mejora de Performace	
		
		-- 20200612 - Dejo de traer información histórica en una consulta NO OLAP!
		WHERE CONVERT(DATE, ct.TransDate) >= '2020-05-17' 