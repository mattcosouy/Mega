
declare @DATAAREAID varchar(4) = '010'

select *
	from XLS_DIM_Seguridad s													-- Seguridad
	inner join VendSettlement vs on												-- Tabla donde queda relacionada la deuda con el cobro
		vs.DataAreaID = s.DataAreaID
		and vs.DataAreaID = @DATAAREAID
	inner join VendTrans vt on													-- Cruzo la VendTrans con la VendSettlement para quedarme solo con las partidas cerradas (Factura)  		
   		vt.DataAreaID = vs.DataAreaID and
		vt.RecID = vs.TransRecID	
	left join VendInvoiceJour cij on
		cij.DataAreaID		= @DATAAREAID and
		cij.InvoiceID		= vt.Invoice and
		cij.LedgerVoucher	= vt.Voucher and	
		cij.InvoiceAccount	= vt.AccountNum and
		cij.InvoiceDate		= vt.TransDate
	inner join VendTable cu on													-- Maestro de Proveedores
		cu.DataAreaID = @DATAAREAID and
		cu.AccountNum = vt.AccountNum		
	-- Vuelvo a cruzar con nueva VendTrans para quedarme con los valores (Pago)
	left join VendSettlement vs1 on												-- Tabla donde queda relacionada la deuda con el cobro
		vs1.DataAreaID = @DATAAREAID and
		vs1.TransRecID = vs.OffsetRecID and
		vs1.OffsetRecID = vs.TransRecID 
	left join VendTrans vt1 on					
		vt1.DataAreaID = @DATAAREAID and
		vt1.RecID = vs1.TransRecID

	-- Tipos de Cambio de Voucher Origen --
	left join XLS_DIM_Cambio tcl_vt on											-- para llevar de MonCur a MonLoc
		tcl_vt.DataAreaID = @DATAAREAID and
		tcl_vt.Fecha  =  vt.TransDate and
		tcl_vt.TC_Mon = vt.CurrencyCode 
						 
	left join XLS_DIM_Cambio tcs_vt on											-- para llevar de MonLoc a MonSec
		tcs_vt.DataAreaID = @DATAAREAID and
		tcs_vt.Fecha  =  vt.TransDate and
		tcs_vt.TC_Mon = s.SecondaryCurrencyCode 	

	-- Tipos de Cambio de Liquidacion --
	left join XLS_DIM_Cambio tcl_vs1 on											-- para llevar de MonCur a MonLoc
		tcl_vs1.DataAreaID = @DATAAREAID and
		tcl_vs1.Fecha  =  vs1.TransDate and
		tcl_vs1.TC_Mon = vt1.CurrencyCode 
						 
	left join XLS_DIM_Cambio tcs_vs1 on											-- para llevar de MonLoc a MonSec
		tcs_vs1.DataAreaID = @DATAAREAID and
		tcs_vs1.Fecha  =  vs1.TransDate and
		tcs_vs1.TC_Mon = s.SecondaryCurrencyCode 	

	-- Perfil de Contabilizacion												-- Se actualiza a la noche o hagalo desde aqui --> exec sp_Actualizar '310', 'A' 		
	inner join XLS_DIM_Proveedores_PerfilContable ppc on
		ppc.DataAreaID = @DATAAREAID and
		ppc.VendAccountNum = vt.AccountNum and
		ppc.PostingProfile = vt.PostingProfile
	inner join XLS_DIM_PlanContable pc on
		pc.DataAreaID = @DATAAREAID and
		pc.AccountNum  = ppc.SumAccount
	---- 20190726 #88372 - Identificar inversiones de activos fijos
	--left join AssetTrans at on
	--	at.DATAAREAID   = vt.DATAAREAID
	--	and at.VOUCHER	= vs.OffsetTransVoucher 
	--	and at.BOOKId   = 'local'  -- modelo de local a la empresa, ojo en otros paises no 120 puede ser otro string
	where vt.DataAReaID = @DATAAREAID
