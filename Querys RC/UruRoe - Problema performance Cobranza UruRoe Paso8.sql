--select * from  XLS_DIM_Tiempo 


		  	SELECT  --aca el distinct rompre 010 pero corrige 050
			xls.[Area]																													as [DataAreaID],
			xls.[ActualizadoAl]													 														as [ActualizadoAl],
			
			--// Fecha de la Transacción //-- 
			xls.[OpeFecha]																												as [OpeFecha],
			/*f1.AM*/  
			concat(year(xls.OpeFecha),'-',right('0'+convert(varchar(02),month(xls.OpeFecha)),2))										as [OpeAM],						
			xls.[DocLiq ]																												as [DocLiq ],
			xls.[DocVouchOrig]																											as [DocVouchOrig],
			(case when left(xls.[DocVouchOrig],5)='CoRec' then 'CoRec' else 'Otros' end)												as [DocVouchOrigRes],

			-- Dimensiones Financieras --
			xls.[DocVouchLiq ]																											as [DocVouchLiq ],
			xls.[DocDiarioLiq]																											as [DocDiarioLiq],

			--// Datos del Cliente --
			xls.[CliCod]																												as [CliCod],

			c.NAME																														as [CliDes],
			c.CUSTGROUP																													as [CliGrupoCod],
			cg.NAME																														as [CliGrupoDes],
			c.DIMENSION5_																												as [CliCanal],		
			c.CUSTCLASSIFICATIONID																										as [CliCalifCod],
			c.SEGMENTID																													as [CliSegmentoCod],
			c.CUSTPORTFOLIOID_MPH																										as [CliCarteraCod],
/*
			c.[CliDes]																													as [CliDes],
			c.[CliGruCod]																												as [CliGrupoCod],
			c.[CliGruDes]																												as [CliGrupoDes],
			c.[DimCanal]																												as [CliCanal],		
			c.[CliGruClasifCod]																											as [CliCalifCod],
			c.[CliSegmentoCod]																											as [CliSegmentoCod],
			c.[CliCarteraCod]																											as [CliCarteraCod],
*/
			--// Información Derivada de las lineas de la Factura
			xls.[ArtCod]																												as [ArtCod],
			isnull(a.ITEMNAME,'')																										as [ArtDes],
			(case when isnull(CHARINDEX('MIG', [DocVouchLiq ]),0) != 0
				then right(xls.[DocLiq ],	(case when isnull(CHARINDEX('-', xls.[DocLiq ]),0) != 0
												then len(xls.[DocLiq ])	- CHARINDEX('-', xls.[DocLiq ])			
												else 0
											 end)
							)
				else isnull(a.DIMENSION6_,''+xls.[DocLinea])
			end)																														as [ArtLinea],
			isnull(a.MTKPORTFOLIOID_MPH,'')																								as [ArtCarteraCod],

			--// OK Total del Voucher para proporcionar en MonLoc (QUEDA PARA CONTROL PORQUE FUE PRORRATEADO)
			/*
			(select sum(xls1.[ValPartLiquidMonLoc] + xls1.[ValPartAbiertaMonLoc] + xls1.[ValPartLiquidMonLocTax] + xls1.[ValPartAbiertaMonLocTax])
				from XLS_FIN_CobranzaPartidasTodas xls1
				where xls1.Area = xls.Area and 
					xls1.OpeTipo = xls.OpeTipo and
					xls1.[DocVouchOrig] = xls.[DocVouchOrig]
					)																													as [DocVouchLiq_ValTotalMonLoc],	-- Total para proporcionar
			*/
			
			--// OK Total del Voucher para proporcionar en MonSec (QUEDA PARA CONTROL PORQUE FUE PRORRATEADO)
			/*
			(select sum(xls1.[ValPartLiquidMonSec] + xls1.[ValPartAbiertaMonSec] +  xls1.[ValPartLiquidMonSecTax] + xls1.[ValPartAbiertaMonSecTax])
				from XLS_FIN_CobranzaPartidasTodas xls1
				where xls1.Area = xls.Area and
					xls1.OpeTipo = xls.OpeTipo and
					xls1.[DocVouchOrig] = xls.[DocVouchOrig] 
					)																													as [DocVouchLiq_ValTotalMonSec],	-- Total para proporcionar
			*/		
			--// Valores en Moneda Local (QUEDA PARA CONTROL PORQUE FUE PRORRATEADO)
			------------------------------------------------------------------------------------------------------------------------------
			--xls.[ValPartLiquidMonLoc]	+ xls.[ValPartAbiertaMonLoc]																	as [ValTotalMonLocSoloVta],			-- Sin Impuesto
			--xls.[ValPartLiquidMonLocTax]+ xls.[ValPartAbiertaMonLocTax]																	as [ValTotalMonLocSoloTax],			-- Solo Impuesto
			--xls.[ValPartLiquidMonLoc]	+ xls.[ValPartAbiertaMonLoc] + xls.[ValPartLiquidMonLocTax]	+ xls.[ValPartAbiertaMonLocTax]		as [ValTotalMonLoc],				-- Total MonLoc
			
			--// Valores en Moneda Secundaria (QUEDA PARA CONTROL PORQUE FUE PRORRATEADO)
			------------------------------------------------------------------------------------------------------------------------------
			--xls.[ValPartLiquidMonSec]	+ xls.[ValPartAbiertaMonSec]																	as [ValTotalMonSecSoloVta],			-- Sin Impuesto
			--xls.[ValPartLiquidMonSecTax]+ xls.[ValPartAbiertaMonSecTax]																as [ValTotalMonSecSoloTax],			-- Solo Impuesto
			--xls.[ValPartLiquidMonSec]	+ xls.[ValPartAbiertaMonSec] + xls.[ValPartLiquidMonSecTax] + xls.[ValPartAbiertaMonSecTax]		as [ValTotalMonSec],				-- Total MonSec

			--// Proporcionar el Valor del Medio de Pago entre cada operacion Articulo/Linea (Moneda Local)
			------------------------------------------------------------------------------------------------------------------------------
			(-- MedioValMonLocSoloVta = SI(DocVouchLiq_ValTotalMonLoc = 0; 0 ;(ValTotalMonLocSoloVta / DocVouchLiq_ValTotalMonLoc) * MedioValTotalMon)
			case
				when isnull(mv.DocNro,'') = '' then xls.[ValPartLiquidMonLoc] + xls.[ValPartAbiertaMonLoc]
				when (select sum(xls1.[ValPartLiquidMonLoc] + xls1.[ValPartAbiertaMonLoc] + xls1.[ValPartLiquidMonLocTax] + xls1.[ValPartAbiertaMonLocTax])
						from XLS_FIN_CobranzaPartidasTodas xls1
						where xls1.Area = xls.Area and 
							xls1.OpeTipo = xls.OpeTipo and
							xls1.[DocVouchOrig] = xls.[DocVouchOrig]
						) = 0 then 0
				else
				(
					(xls.[ValPartLiquidMonLoc] + xls.[ValPartAbiertaMonLoc])
					/
					(select sum(xls1.[ValPartLiquidMonLoc] + xls1.[ValPartAbiertaMonLoc] + xls1.[ValPartLiquidMonLocTax] + xls1.[ValPartAbiertaMonLocTax])
					 from XLS_FIN_CobranzaPartidasTodas xls1
					 where xls1.Area = xls.Area and 
						xls1.OpeTipo = xls.OpeTipo and
						xls1.[DocVouchOrig] = xls.[DocVouchOrig]
					)
					* (mv.ValorMonLoc * -1)
				)
			end
			)																															as [MedioValMonLocSoloVta],

			(-- MedioValMonLocSoloTax = SI(DocVouchLiq_ValTotalMonLoc= 0 ; 0 ;(ValTotalMonLocSoloTax / DocVouchLiq_ValTotalMonLoc) * MedioValTotalMon)
			case
				when isnull(mv.DocNro,'') = '' then xls.[ValPartLiquidMonLocTax] + xls.[ValPartAbiertaMonLocTax]		
				when (select sum(xls1.[ValPartLiquidMonLoc] + xls1.[ValPartAbiertaMonLoc] + xls1.[ValPartLiquidMonLocTax] + xls1.[ValPartAbiertaMonLocTax])
						from XLS_FIN_CobranzaPartidasTodas xls1
						where xls1.Area = xls.Area and 
							xls1.OpeTipo = xls.OpeTipo and
							xls1.[DocVouchOrig] = xls.[DocVouchOrig]
						) = 0 then 0
				else
				( 
					(xls.[ValPartLiquidMonLocTax]+ xls.[ValPartAbiertaMonLocTax])
					/
					(select sum(xls1.[ValPartLiquidMonLoc] + xls1.[ValPartAbiertaMonLoc] + xls1.[ValPartLiquidMonLocTax] + xls1.[ValPartAbiertaMonLocTax])
					 from XLS_FIN_CobranzaPartidasTodas xls1
					 where xls1.Area = xls.Area and 
						xls1.OpeTipo = xls.OpeTipo and
						xls1.[DocVouchOrig] = xls.[DocVouchOrig]
					)
					* (mv.ValorMonLoc * -1)
				)
			end
			)																															as [MedioValMonLocSoloTax],

			--// Proporcionar el Valor del Medio de Pago entre cada operacion Articulo/Linea (Moneda Secundaria)
			------------------------------------------------------------------------------------------------------------------------------
			(-- MedioValMonSecSoloVta = SI(DocVouchLiq_ValTotalMonSec = 0; 0 ;(ValTotalMonSecSoloVta / DocVouchLiq_ValTotalMonSec) * MedioValTotalMon)
			case
				when isnull(mv.DocNro,'') = '' then xls.[ValPartLiquidMonSec] + xls.[ValPartAbiertaMonSec]
				when (select sum(xls1.[ValPartLiquidMonSec] + xls1.[ValPartAbiertaMonSec] + xls1.[ValPartLiquidMonSecTax] + xls1.[ValPartAbiertaMonSecTax])
						from XLS_FIN_CobranzaPartidasTodas xls1
						where xls1.Area = xls.Area and 
							xls1.OpeTipo = xls.OpeTipo and
							xls1.[DocVouchOrig] = xls.[DocVouchOrig]
						) = 0 then 0
				else
				(
					(xls.[ValPartLiquidMonSec] + xls.[ValPartAbiertaMonSec])
					/
					(select sum(xls1.[ValPartLiquidMonSec] + xls1.[ValPartAbiertaMonSec] + xls1.[ValPartLiquidMonSecTax] + xls1.[ValPartAbiertaMonSecTax])
					 from XLS_FIN_CobranzaPartidasTodas xls1
					 where xls1.Area = xls.Area and 
						xls1.OpeTipo = xls.OpeTipo and
						xls1.[DocVouchOrig] = xls.[DocVouchOrig]
					)
					* (mv.ValorMonSec * -1)
				)
			end
			)																															as [MedioValMonSecSoloVta],

			(-- MedioValMonSeccSoloTax = SI(DocVouchLiq_ValTotalMonSec= 0 ; 0 ;(ValTotalMonSecSoloTax / DocVouchLiq_ValTotalMonSec) * MedioValTotalMon)
			case
				when isnull(mv.DocNro,'') = '' then xls.[ValPartLiquidMonSecTax] + xls.[ValPartAbiertaMonSecTax]		
				when (select sum(xls1.[ValPartLiquidMonSec] + xls1.[ValPartAbiertaMonSec] + xls1.[ValPartLiquidMonSecTax] + xls1.[ValPartAbiertaMonSecTax])
						from XLS_FIN_CobranzaPartidasTodas xls1
						where xls1.Area = xls.Area and 
							xls1.OpeTipo = xls.OpeTipo and
							xls1.[DocVouchOrig] = xls.[DocVouchOrig]
						) = 0 then 0
				else
				( 
					(xls.[ValPartLiquidMonSecTax]+ xls.[ValPartAbiertaMonSecTax])
					/
					(select sum(xls1.[ValPartLiquidMonSec] + xls1.[ValPartAbiertaMonSec] + xls1.[ValPartLiquidMonSecTax] + xls1.[ValPartAbiertaMonSecTax])
					 from XLS_FIN_CobranzaPartidasTodas xls1
					 where xls1.Area = xls.Area and 
						xls1.OpeTipo = xls.OpeTipo and
						xls1.[DocVouchOrig] = xls.[DocVouchOrig]
					)
					* (mv.ValorMonSec * -1)
				)
			end
			)																															as [MedioValMonSecSoloTax],
			------------------------------------------------------------------------------------------------------------------------------
			-- DATOS AGREGADOS RELACIONADOS CON LOS MEDIOS DE PAGO
			------------------------------------------------------------------------------------------------------------------------------			
			mv.DocNro																													as [DocNro],
			(case when isnull(mv.DocNro,'') = '' then 0				else mv.PasoCod end)												as [PasoCod],		
			(case when isnull(mv.DocNro,'') = '' then 'Diario AX'	else mv.PasoDes end)												as [PasoDes],
			(case when isnull(mv.DocNro,'') = '' then DocVouchOrig	else mv.DiaAsiento	end)											as [DiAsiento],
			(case when isnull(mv.DocNro,'') = '' then 'No'			else mv.DocSiNo end)												as [DocSiNo],
			(case when isnull(mv.DocNro,'') = '' then 'Diario AX'	else mv.DocStatusDes end)											as [DocStatusDes],
			isnull(mv.[Cobrado?], 'Si')																									as [DocCobrado?],
			(case when isnull(mv.DocNro,'') = '' then 'Diario AX'	else mv.DocTipo end)												as [DocTipo],
			(case when isnull(mv.DocNro,'') = '' then xls.[OpeFecha]		else mv.AnaFecha		end)								as [AnaFecha],
			/*f2.AM*/ 
			concat(year(mv.AnaFecha),'-',right('0'+convert(varchar(02),month(mv.AnaFecha)),2)) 											as [AnaAM],
			(case when isnull(mv.DocNro,'') = '' then  (case when xls.[VtoAnalisis] = '9-Cerrado' 
															then '0-Cobrado'
															else xls.[VtoAnalisis]
														end)
												 else mv.AnaVencimiento
 			 end)																														as [AnaVencimiento],
			(case when isnull(mv.DocNro,'') = '' then  xls.[VtoFechaEnt]	else mv.AnaFecha		end)								as [AnaVto]
--select xls.*	-- count(*) 		
		  from XLS_FIN_CobranzaPartidasTodas xls
			-- Informacion de Clientes y Articulos
			inner join Custtable c on								-- Clientes: Datos Complementarios
				c.DataAreaID = xls.[Area] and
				c.AccountNum = xls.[CliCod]
			inner join CUSTGROUP cg on 
				cg.DATAAREAID = c.DATAAREAID and
				cg.CUSTGROUP = c.CUSTGROUP
    		left join INVENTTABLE a on								-- Articulos: Datos Complementarios
				a.DataAreaID = xls.[Area] and
				a.ItemID =  xls.[ArtCod] 
			left join XLS_FIN_MediosDePagoPorVoucher mv on					-- Esta Tabla es solo para recuperar valores prorrateados
				mv.[DataAreaID] = xls.Area and
				mv.[DiaAsiento] = xls.DocVouchOrig
			-- Conversor de Fechas --
/*			left join XLS_DIM_Tiempo f1 on									-- Fecha de la Transaccion. Formato Fechas derivadas.
				f1.Fecha = xls.[OpeFecha]
				and f1.[MMAct] > -12										-- Muestra la cobranza de los ultimos @MESES  
			left join XLS_DIM_Tiempo f2 on									-- Fecha de Vencimiento. Formato Fechas derivadas.
				f2.Fecha = (case when isnull(mv.DocNro,'') = ''
								then xls.[OpeFecha]
								else mv.[AnaFecha]
							end) 
*/
		  where xls.Area = '010'	and
-- FUM RC #99428 - PANEL COBRANZA: incluir Grupo creado "Clientes" (urgente para cierre de mes) -- 28/07/2020 12:00Solicitante: DIANA MAMCHUR <dmamchur@uy.roemmers.com>
			(xls.[OpeTipo] = 'Cobro' or c.CUSTCLASSIFICATIONID /*c.CliGruClasifCod*/ = 'CLIENTES' ) 
			and xls.[DocCancelado] = 0										-- El documento no debe estar cancelado para ser mostrado en esta salida. 
			and DATEDIFF(MONTH, xls.[OpeFecha], getdate()) <= 12
		--	and dbo.fc_FechaActual(xls.[OpeFecha],001) > -12										-- Muestra la cobranza de los ultimos @MESES
			and xls.[ValPartLiquidMonOrig] + xls.[ValPartAbiertaMonOrig] + xls.[ValPartLiquidMonOrigTax] + xls.[ValPartAbiertaMonOrigTax] != 0 