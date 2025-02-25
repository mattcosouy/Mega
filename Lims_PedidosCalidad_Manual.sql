USE [Ax2k9MPHPRO]
GO
/****** Object:  StoredProcedure [dbo].[sp_LIMS_PedidosCalidad_Manual]    Script Date: 3/2/2025 17:06:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_LIMS_PedidosCalidad_Manual]
as

  set nocount on

declare
  @AREA			varchar(04)  = '120',				-- Empresa de Ejecución				
  @TIPO_ACCION	nvarchar(01) = 'A',					-- A=Actualiza, M=Muestra, E=Error C=Confirmado R=Reproceso
 /* @LASTUPDATE	dateTime		= null,				-- Fecha de ultima ejecucion. Por null toma getdate */
  @xCLAVEID		nvarchar(60)	= null,				-- Identificacion para Sincronismo en respuesta o si necesita REPROCESAR PQ
  @xERROR		nvarchar(30)	= null,				-- Código de Error devuelto por el WS (se graba en tabla de control en la respuesta)
  @xERRESC		nvarchar(2000)	= null,				-- Detalle de Error devuelto por el WS (se graba en tabla de control en la respuesta)
--
  --@GPOPRUEBAS	nvarchar(30)	= 'LIMS',			-- Grupos de pruebas a seleccionar (GpoLIMS)
  --@GRUPOART		nvarchar(100)	= 'PT,SEMI',	-- Grupos de Artículos a informar (ej. 'PT,MP,...')
  --@TipoProd		nvarchar(05)	= 'PT'				-- Debe venir PT o MP
--
  @GPOPRUEBAS	nvarchar(30)	= 'LIMS',			-- Grupos de pruebas a seleccionar (GpoLIMS)
  @GRUPOART		nvarchar(100)	= 'MP,ACOND,LIMP,NOVAL,SEGHIG,INSPRO',	-- Grupos de Artículos a informar (ej. 'PT,MP,...')
  @TipoProd		nvarchar(05)	= 'MP'				-- Debe venir PT o MP
----
  --@GPOPRUEBAS	nvarchar(30)	= 'LIMSSEMI',			-- Grupos de pruebas a seleccionar (GpoLIMS)
  --@GRUPOART		nvarchar(100)	= 'SEMI',	-- Grupos de Artículos a informar (ej. 'PT,MP,...')
  --@TipoProd		nvarchar(05)	= 'SEMI'				-- Debe venir PT o MP
--
  --@GPOPRUEBAS	nvarchar(30)	= 'LIMSSEMICUAR',			-- Grupos de pruebas a seleccionar (GpoLIMS)
  --@GRUPOART		nvarchar(100)	= 'SEMI',	-- Grupos de Artículos a informar (ej. 'PT,MP,...')
  --@TipoProd		nvarchar(05)	= 'SEMI'				-- Debe venir PT o MP


  declare @FORMATO	nvarchar(30)		set @FORMATO	= 'PQAX_LIMS'
  declare @GTM		int					set @GTM		= (select GTM from XLS_DIM_Seguridad where DataAreaID = @AREA)
  declare @AHORA	datetime			set @AHORA		= getutcdate() 

  set @GPOPRUEBAS	= isnull(@GPOPRUEBAS,'LIMS')						-- Verificar cual será el grupo por defecto!
  set @GRUPOART		= isnull(@GRUPOART,'')								-- SCa+ 05/03/2022 - Si viene NULL van todos menos MP
--  set @LASTUPDATE	= isnull(@LASTUPDATE,dateAdd(dd, -7, getdate()))	-- Mantener 5 dias hacia atras para garantizar que se envíen casos que faltaron datos
  set @TipoProd		= isnull(@TipoProd,'PT')


 -- -- + #138646 + 139670 -> 2023-11 RCarbajal y JPerez .. forzamos el grupo de articulos segun se definio con los usuarios LRuybal y ALucero
 --
  if (@GPOPRUEBAS = 'LIMS' AND @TipoProd = 'PT')
	begin
		set @GRUPOART = 'PT,SEMI'
	end
  if (@GPOPRUEBAS = 'LIMS' AND @TipoProd = 'MP')
	begin
		set @GRUPOART = 'MP,ACOND,LIMP,NOVAL,SEGHIG,INSPRO'
	end
  if (@GPOPRUEBAS = 'LIMSSEMI' AND @TipoProd = 'PT')
	begin
		set @GRUPOART = 'SEMI'
	end
  if (@GPOPRUEBAS = 'LIMSSEMICUAR' AND @TipoProd = 'PT')
	begin
		set @GRUPOART = 'SEMI'
	end
  --
  -- - #138646 + 139670 -> 2023-11


  ---- 17/4/2023 RCarbajal y JPerez .. forzamos que se envien los Lotes pendientes tantas veces como sean necesarias
  --set @LASTUPDATE	= '1900-01-01'
  

  declare @xPQNro		nvarchar(40)
  declare @xPQValElHs	nvarchar(15)
  declare @xPQValPorCod	nvarchar(20)


-- Inicio el desgloce de los multiples documentos.	
drop table if exists #TabGpoArt
create table #TabGpoArt ([GpoArtId] nvarchar(30))  -- scamara
if @GRUPOART <> ''
begin
  while patindex('%,%',@GRUPOART)>0
	  begin
		insert into #TabGpoArt select ltrim(rtrim(substring(@GRUPOART, 0, patindex('%,%', @GRUPOART))))
		set @GRUPOART = RIGHT(@GRUPOART, Len(@GRUPOART) - patindex('%,%',@GRUPOART))
	  end
  if patindex('%,%',@GRUPOART) = 0 and len(@GRUPOART) > 0
  begin
	insert into #TabGpoArt  select ltrim(rtrim(@GRUPOART))
  end
end								
--SELECT * FROM #TabGpoArt

drop table if exists #PQs
create table #PQs ([PQ_Nro] nvarchar(15))  -- JP
insert into #PQs 
	select pqs.pq_nro
	/* 
	,pq.PQ_StatusCod, pq.PQ_GrupoTestCod, pq.ArtGrupoCod
	,pq.ArtCod, pq.ArtDes, pq.ArtLoteNro, pq.ArtSubLoteNro
	--, pq.* --*/
	from (  
		SELECT 'PQ_00095191' pq_nro -- 156245 
		--union SELECT 'PQ_00095019' pq_nro 
		--union SELECT 'PQ_00095020' pq_nro 
		--union SELECT 'PQ_00095024' pq_nro 
	) pqs
	inner join XLS_DIM_PedidosDeCalidad pq
	on pq.PQ_Nro = pqs.PQ_Nro
	WHERE pq.DataAreaID = '120' --@AREA  
		--and pq.PQ_CreEl >= dateAdd(mm, -3, @LASTUPDATE)	-- Creado en los últimos 3 meses (VALIDAR SI APLICAR O NO ESTA CONDICION O CUAL)
		and pq.PQ_StatusCod = 0								-- Abierto
		and pq.PQ_GrupoTestCod = @GPOPRUEBAS				-- verificar nombre del campo
		and (pq.ArtGrupoCod in (select GpoArtId from #TabGpoArt))
		--AND pq.ArtGrupoCod = @TipoProd
--select * from #PQs



if isnull(CHARINDEX('A', @TIPO_ACCION),0) != 0 
	begin
		-- ELIMINA REGISTROS SIN PROCESAR DE LA TABLA DE CONTROL
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		delete s
		--select top 10 * 
		from XLS_EDI_AXQuality_To_External_Sync s
		inner join #PQs pqs on s.ClaveID like pqs.PQ_Nro + '%'


		-- Valida si reabrieron PQ para volver a enviar (hablado el 27/08/2021 EEt + DPa)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE CursorUpd CURSOR FOR 
		SELECT pq.[PQ_Nro], replace(replace(replace(convert(nvarchar(30), [PQ_ValElHs], 120),'-',''),':',''),' ','-'), [PQ_ValPorCod]
		FROM XLS_DIM_PedidosDeCalidad pq
		inner join #PQs pqs on pq.PQ_Nro = pqs.PQ_Nro
		WHERE pq.DataAreaID = @AREA  
			--and pq.PQ_CreEl >= dateAdd(mm, -3, @LASTUPDATE)	-- Creado en los últimos 3 meses (VALIDAR SI APLICAR O NO ESTA CONDICION O CUAL)
			and pq.PQ_StatusCod = 0								-- Abierto
			and pq.PQ_GrupoTestCod = @GPOPRUEBAS				-- verificar nombre del campo
			and (pq.ArtGrupoCod in (select GpoArtId from #TabGpoArt))
		AND pq.ArtGrupoCod = @TipoProd
			--and isnull(PQ_ValElHs,'1900-01-01') <> '1900-01-01' -- Pedidos que ya fueron validados y reabrieron

		FOR UPDATE -- 23/07/22 SCa+	- Se debe eliminar referencia a LIMS anterior
		OPEN CursorUpd
		FETCH NEXT FROM CursorUpd INTO @xPQNro, @xPQValElHs, @xPQValPorCod
		WHILE @@FETCH_STATUS = 0 --and @Orden <> 10
			BEGIN
				update XLS_EDI_AXQuality_To_External_Sync
				set ClaveId = ClaveId + ' (r' + @xPQValElHs + ')' 
				where
					DataAreaID = @Area and				-- Empresa
					ClaveID = @xPQNro	and				-- Clave
					Pro_TipoSync = @FORMATO	and			-- ID de Control de Sincronizmo --> Tipo de Formato
					Pro_Accion = 'C'					-- que esté en Confirmado
				
				-- 23/07/22 SCa+	Se elimina referencia estado LIMS anteriores.
				update InventQualityOrderTable
				set LIMSInspectionLotId_MPH = ''
				  , LIMSDocumentStatus_MPH = ''
				where QualityOrderID = @xPQNro
	
				FETCH NEXT FROM CursorUpd INTO @xPQNro, @xPQValElHs, @xPQValPorCod
			END
		CLOSE CursorUpd
		DEALLOCATE CursorUpd

		-- Valida si hay que reenviar en Error
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE CursorErrUpd CURSOR FOR 
		SELECT pq.[PQ_Nro], replace(replace(replace(convert(nvarchar(30), getUTCDate(), 120),'-',''),':',''),' ','-')
		FROM XLS_DIM_PedidosDeCalidad pq
		inner join #PQs pqs on pq.PQ_Nro = pqs.PQ_Nro
		WHERE pq.DataAreaID = @AREA  
			--and pq.PQ_CreEl >= @LASTUPDATE						-- Verificar en los últimos 14 dias	
			and pq.PQ_StatusCod = 0								-- Abierto
			and pq.PQ_GrupoTestCod = @GPOPRUEBAS				-- verificar nombre del campo
			and (pq.ArtGrupoCod in (select GpoArtId from #TabGpoArt))

		OPEN CursorErrUpd
		FETCH NEXT FROM CursorErrUpd INTO @xPQNro, @xPQValElHs
		WHILE @@FETCH_STATUS = 0 --and @Orden <> 10
			BEGIN

				update XLS_EDI_AXQuality_To_External_Sync
				set ClaveId = ClaveId + ' (e' + @xPQValElHs + ')' 
				where
					DataAreaID = @Area and				-- Empresa
					ClaveID = @xPQNro	and				-- Clave
					Pro_TipoSync = @FORMATO	and			-- ID de Control de Sincronizmo --> Tipo de Formato
					Pro_Accion = 'E'					-- que esté en Confirmado

				-- 11/02/23 SCa+	Se elimina referencia estado LIMS anteriores.
				update InventQualityOrderTable
				set LIMSInspectionLotId_MPH = ''
				  , LIMSDocumentStatus_MPH = ''
				where QualityOrderID = @xPQNro

				FETCH NEXT FROM CursorErrUpd INTO @xPQNro, @xPQValElHs
			END
		CLOSE CursorErrUpd
		DEALLOCATE CursorErrUpd

		-- Se agrega ésta sentencia por si se quiere reprocesar un PQ específico...
		-- NO ES POR REAPERTURA, solo por enviar nuevamente el PQ
		IF isnull(@xCLAVEID,'') <> ''
			BEGIN
				update XLS_EDI_AXQuality_To_External_Sync
				set ClaveId = ClaveId + ' (q' + @xPQValElHs + ')' 
				where
					DataAreaID	= @Area and				-- Empresa
					ClaveID		= @xCLAVEID	and			-- Clave
					Pro_TipoSync= @FORMATO	and			-- ID de Control de Sincronizmo --> Tipo de Formato
					Pro_Accion	= 'C'					-- que esté en Confirmado

					-- 23/07/22 SCa+	Se elimina referencia estado LIMS anteriores.
					update InventQualityOrderTable
					set LIMSInspectionLotId_MPH = ''
					  , LIMSDocumentStatus_MPH = ''
					where QualityOrderID = @xCLAVEID

				-- 14/07/2022 no tiene sentido este fetch, ya cerro el cursor!
				--FETCH NEXT FROM CursorUpd INTO @xPQNro, @xPQValElHs, @xPQValPorCod
			END

		-- **************************************************************************************************************************************************
		-- INSERT NUEVOS REGISTROS A PROCESAR DE LA TABLA DE CONTROL
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		insert into XLS_EDI_AXQuality_To_External_Sync
			(DataAreaID, Pro_TipoSync, Pro_Accion, Pro_FechaHora, ClaveID, ClaveFechaHora, Referencia, Informacion)
		select distinct
			pq.DataAreaID,
			@FORMATO,
			'A',
			@AHORA,
			pq.PQ_Nro,								-- CLAVE DE REGISTRO ENVIADO
			dateadd(hh, @GTM, pq.PQ_CreEl),			-- Fecha de REGISTRO de la CLAVE en AX
			pq.PQ_Invent_RefID,						--modificar esta linea para poner información de referencia! 
			'Pedido ' + pq.PQ_Nro + ' tipo ' + @TipoProd + ' [' +pq.ArtGrupoCod+ '], ' 
					  + case isnull(pq.PQ_Contenedores,'') when '' then '0' else pq.PQ_Contenedores end 
					  + '- Grupo ' + @GPOPRUEBAS +' Tipo Ref. [' + pq.PQ_TipoDes + ']'

		FROM XLS_DIM_PedidosDeCalidad pq
		inner join #PQs pqs on pq.PQ_Nro = pqs.PQ_Nro
		WHERE pq.DataAreaID = @AREA  
		  and pq.PQ_GrupoTestCod = @GPOPRUEBAS		-- verificar nombre del campo
		  and pq.PQ_StatusCod = 0					-- Abierto
--		  and (pq.PQ_CreEl >= dateAdd(mi, -30, @LASTUPDATE)			-- dateAdd(dd, -3, getdate()) 
--		   OR (isnull(PQ_ValElHs,'1900-01-01') <> '1900-01-01' and LIMS_LoteId = ''))		-- Pedidos que ya fueron validados y reabrieron
		  -- SCa+ 05/03/2022 - Si no se recibe MP en @GRUPOART, van todos los grupos de artículo.
		  and (pq.ArtGrupoCod in (select GpoArtId from #TabGpoArt))
		  -- Solo si es MP y tiene contenedores o es PT
--		  and ((isnull(PQ_Contenedores,'0') <> '0' and PQ_Contenedores <> '') or @TipoProd = 'PT')
		  -- 23/07/22 SCa+	- Solo si no tiene referencia LIMS
		  --and isnull(pq.LIMS_LoteID,'') = ''
		  -- 17/11/22 SCa+	- Se esta recibiendo "Sin Valor" cuando el WS dió Error
--		  and (isnull(pq.LIMS_LoteID,'') in ('','0','Sin Valor'))
		  -- Se asegura que no esta registrado con anterioridad
		  --and not exists (select 1											
				--		  from XLS_EDI_AXQuality_To_External_Sync syn
				--		  where
				--			syn.DataAreaID = pq.DataAreaID and				-- Empresa
				--			syn.ClaveID = pq.PQ_Nro	and						-- Clave
				--			syn.Pro_TipoSync = @FORMATO	and					-- ID de Control de Sincronizmo --> Tipo de Formato
				--			syn.Pro_Accion in ('C','B')						-- que no esté en Bloqueado o Confirmado
				--			)
	end

if isnull(CHARINDEX('A', @TIPO_ACCION),0) != 0 or
   isnull(CHARINDEX('M', @TIPO_ACCION),0) != 0 
	begin

		-- SELECCIONA DATOS DE REGISTROS INSERTADOS EN TABLA DE CONTROL
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT
			 pq.PQ_Nro															as [PQ],
			 pq.ArtLoteNro														as [NumeroLote], 
			 pq.ArtSubLoteNro													as [SubLote], 
			 pq.ArtCod															as [CodigoArt],  
			 --CONVERT(date, ib.PDSVENDEXPIRYDATE, 103)							as [FechaCadProv],
			 Convert(CHAR(8),ib.PDSVENDEXPIRYDATE,112)							as [FechaCadProv],
			 pq.ArtLoteProv														as [NumeroLoteProv],
			 pq.PQ_DispAbierta													as [Estado],
			 pq.PQ_TipoDes														as [TipoReferencia],
			 --ltrim(str(PQ_Cant,20,2))											as [Cantidad],
			 ltrim(str(pq.ArtCantRecibida,20,2))									as [Cantidad],
			 ltrim(str(0,20,2))													as [CantidadLib],
			 case isnull(pq.PQ_Contenedores,'') 
				when '' then '0' else pq.PQ_Contenedores 
			 end																as [Contenedores],
			 '19000101'															as [FechaLib],
			 pq.PQ_Invent_RefId													as [PQ_Referencia],
			 pq.PQ_TipoCod														as [Referencia],
			 pq.LIMS_LoteId														as [LIMS_LoteId],
			 pq.LIMS_EstadoCod													as [LIMS_EstadoCod],
			 pq.LIMS_EstadoDes													as [LIMS_EstadoDes]
			 , syn.Pro_Accion, syn.Pro_FechaHora, syn.Env_FechaHora
			 , syn.Informacion

	FROM XLS_EDI_AXQuality_To_External_Sync syn
	inner join #PQs pqs on syn.ClaveID like pqs.PQ_Nro + '%'
	inner join XLS_DIM_PedidosDeCalidad pq ON
			pq.PQ_Nro = pqs.PQ_Nro
		--FROM XLS_EDI_AXQuality_To_External_Sync syn
		--inner join XLS_DIM_PedidosDeCalidad pq ON
		--	pq.DataAreaId = syn.DataAreaID and
		--	pq.PQ_Nro = syn.ClaveID /* and
		--	syn.Pro_Accion = 'A' */
		INNER JOIN XLS_DIM_Seguridad s ON
			s.DataAreaId = pq.DataAreaId
		INNER JOIN   InventDim id on
 			pq.DataAreaId  = id.DataAreaId and
			pq.InventDimID = id.InventDimId
		INNER JOIN inventBatch ib ON
 			ib.DataAreaId = id.DataAreaId and
 			ib.ItemId = pq.ArtCod and 
			ib.inventBatchId = id.inventbatchId
		INNER JOIN inventSubBatch_MPH isb ON
			isb.inventBatchId = ib.inventBatchId and
			isb.inventSubBatchId = id.inventSubBatchId and
			isb.ItemId = ib.itemId
		WHERE s.DataAreaID = @AREA
--		  and ((isnull(PQ_Contenedores,'0') <> '0' and PQ_Contenedores <> '') or @TipoProd = 'PT')

		-- dejar esto hasta aclarar porque no llegan a LIMS
		update
			XLS_EDI_AXQuality_To_External_Sync
		set	
			Pro_Accion = 'B',					-- Se Insertó y va a llamar al WS con estos registros... La confirmación / error cambia ese estado
			Env_FechaHora	= @AHORA,
			Pro_Observacion	= 'Bloqueado por envío a LIMS...'
		from XLS_EDI_AXQuality_To_External_Sync itos
		where
			itos.DataAreaID = @AREA and
			itos.Pro_TipoSync = @FORMATO and
			(itos.ClaveID = @xCLAVEID or isnull(@xCLAVEID,'') = '') and		-- si no se pasó @xClaveID se actualiza todo!
			itos.Pro_Accion = 'A'

	end

