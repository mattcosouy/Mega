

--------------------------------------------------------------------------------------------------------------------------------------------
--
-- FUM:	SCa 20/09/2018
--	Se agrega posibilidad de generar archivos diferentes si dependiendo de si es TRADE o no (habitual)
--
-- FUM:	RC 28/11/2018
--	El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.
--  Mail de Jorge Cohn del 28/11/2018: "A todo el inventario de este almacén debe colocársele entonces como destino “ACCEAM” (Área Consolidadora CEAM)."
--
-- FUM:	RC 07/10/2021
-- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
--------------------------------------------------------------------------------------------------------------------------------------------
--*/
  
	/* EJEMPLO DE PLANILLA PARA CARGA DE FORECAST ENTREGADA POR J.COHN
	-------------------------------------------------------------------------------------------
	IdBase		Año		Mes	Producto	Lote		FechaVen	TipoExist	Cantidad	Destino
	-------------------------------------------------------------------------------------------
	AxaUruRoe	2006	6	1100501		06-002266	14/02/2009	DIS				3291
	AxaUruRoe	2006	6	1100501		06-002267	26/03/2009	DIS				4161
	AxaUruRoe	2006	6	1100501								TRA				1500
	AxaUruRoe	2006	6	1105402		06-001361	11/02/2009	DIS				   1
	-------------------------------------------------------------------------------------------
	IdBase		Identificador único de la base de datos de la compañía	
	Año			Año que se reporta
	Mes			Mes que se reporta
	Producto	Codigo del producto de la Empresa
	Lote		Nº de Lote
	FechaVen	Fecha de Vencimiento del lote,
	TipoExist	Tipo de Existencia (Ver Observaciones)
	Cantidad	Cantidad.							
								
	Observaciones:							
							
	El código de producto puede ser repetido para diferentes Tipos de Existencia y Lotes							
	El Tipo de Existencia debe ser uno de los siguientes: DIS:Disponible, RE:A reclamar por rechazo, VEN: Vencidos, TRA	En tránsito, PRO: En proceso					
	Las columnas Lote y FechaVen son obligatorias para TipoExist: DIS, REC y VEN							
	La columna Destino es opcional y es el código de la compañía de destino final del lote (Pais-Empresa)
	*/
  
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// Libere estas variables para hacer una prueba local
  ----------------------------------------------------------------------------------------------------------------------------------------------

  drop table #TEMP
  drop table #TABLA_ARTICULO   
  declare @AREA			nvarchar(04) set @AREA		= '120'
  declare @MESATRAS		smallint	 set @MESATRAS	= 1
  declare @FORMATO		nvarchar(30) set @FORMATO	= 'e-LogTxt'			-- Ver opciones en la declaracion del SP
  declare @ARTICULOS	nvarchar(99) set @ARTICULOS	= 'T0051000130'	
  declare @EsTrade		varchar(1)	= 1											-- 0=No es Trade	1=Es Trade
  
    
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// El inventario que se informa a la Corporacion son los articulos dados de alta durante esas fechas.														  
  ----------------------------------------------------------------------------------------------------------------------------------------------  
  -- Si se identifica que es Trade (solo si empresa es 120) se pone ID de BASE manualmente
  declare @xIdBase	varchar(20)
  set @EsTrade = ISNULL(@EsTrade,'0')

  set @xIdBase =   (select case when (@AREA='120' and @EsTrade='1') 
							then 'AX5URUMTR' else IdBase end
					from XLS_DIM_Seguridad
					where DataAreaID = @AREA)

  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// El inventario que se informa a la Corporacion es el saldo a un mes solicitado.														  
  --// Como esta consulta se basa en la XLS_DIM_Inventario que tiene saldo y transacciones mensuales aqui se consolida en funcion de este mes 
  --// indicado por parametro. En el caso que se omita o se pase negativo, se ajutara.														  
  ----------------------------------------------------------------------------------------------------------------------------------------------  
  declare @FECHA_FIN datetime
  set @MESATRAS = ABS(isnull((@MESATRAS), 0))* -1							-- Por Omision Mes Corriente. Como usara MMAct es por -1
  set @FECHA_FIN = (select distinct x.MMFin from xls_dim_tiempo x where x.MMAct =	@MESATRAS )
  -- En el caso de pedir el mes en curso , ajusta la fecha a hoy sin hora para que el proceso lo tome				
  set @FECHA_FIN = (case when @FECHA_FIN > getdate() then convert(varchar(10), getdate(), 112) else @FECHA_FIN end)
  declare  @ALMACENEXP varchar(30)
declare  @UBICACIONEXP varchar(30)
  set @ALMACENEXP = (case when ISNULL(@ALMACENEXP,'Ninguna') <> '' then ISNULL(@ALMACENEXP,'Ninguna') else 'Ninguna' end)
  set @UBICACIONEXP = (case when ISNULL(@UBICACIONEXP,'SinUso') <> '' then ISNULL(@UBICACIONEXP,'SinUso') else 'SinUso' end)

  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// Controla que el mes solicitado exista en la XLS_DIM_Inventario. Por el contrario detiene la ejecucion.
  --// La importancia de esto que no devuelve ningun valor y por ende no rompe el formato de la tabla dinamica.  Solo la detiene
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --IF(select min(t.Fecha) from XLS_DIM_Inventario t where t.DataAreaID = @AREA) > @FECHA_FIN
	--return 'ATENCION!!  EL MES SOLICITADO NO ESTA EN LA XLS_DIM_INVENTARIOS'-- Detiene la ejecucion del proceso

  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// Controla que el mes solicitado exista en la XLS_DIM_Costos. Por el contrario detiene la ejecucion.
  --// La importancia de esto que no devuelve ningun valor y por ende no rompe el formato de la tabla dinamica.  Solo la detiene
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --IF(select min(c.MMFin) from XLS_DIM_Costos c where c.DataAreaID = @AREA) > @FECHA_FIN
	--return 'ATENCION!!  EL MES SOLICITADO NO ESTA EN LA XLS_DIM_COSTOS'		-- Detiene la ejecucion del proceso    

  ------------------------------------------------------------------------------------------------------------------------------------------------
  -- DETALLE DE ARTICULOS
  -- Analiza los Articulos que se pasaron por parametros y los guarda como registros de una tabla para poder cruzar y restringir los datos 
  -- que se procesan
  ------------------------------------------------------------------------------------------------------------------------------------------------
  --drop table #TABLA_ARTICULO  
  /*
  declare @AREA			nvarchar(04)	set @AREA		= '010'  
  declare @ARTICULOS	nvarchar(99)	set @ARTICULOS	= '1254304180' --,6254302' --'50032,1106309092,1106303021'
  --*/

-----------------------------------------------------------------------------------------------------------------
-- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
-----------------------------------------------------------------------------------------------------------------
-- Crear nuevo campo "Destino" que contendrá el valor ACCEAM si el destino de la mercadería es CentroAmérica
--		ALTER TABLE XLS_DIM_Inventario ADD Destino Varchar(10) DEFAULT ''

--Lógica para llenar el nuevo campo Destino.
		/*update XLS_DIM_Inventario 
		set Destino = id.INVENTLOCATIONID 
		from XLS_DIM_Inventario x
		inner join purchline pl on 
		pl.DATAAREAID = x.DataAreaID
		and pl.PURCHID = x.TransRefID
		and pl.ITEMID = x.ItemID
		inner join inventdim id on
		id.DATAAREAID = x.DataAreaID
		and id.INVENTDIMID = pl.INVENTDIMID
		where x.dataareaid = '120' -- Solo aplica para Megalabs
		and substring(x.TransRefID, 1, 3) = ('PC_')-- Compras 
		and x.InventLocationId = 'TRANSITO'
		and id.INVENTLOCATIONID = 'MEGAPAN-01'

		update XLS_DIM_Inventario 
		set Destino =  id.INVENTLOCATIONID 
		from XLS_DIM_Inventario x
		inner join INVENTTRANS it on 
		it.DATAAREAID = x.DataAreaID
		and it.TRANSREFID = x.TransRefID
		and it.ITEMID = x.ItemID
		inner join inventdim id on
		id.DATAAREAID = x.DataAreaID
		and id.INVENTDIMID = it.INVENTDIMID
		where x.dataareaid = '120' -- Solo aplica para Megalabs
		and substring(x.TransRefID, 1, 3) = ('086') --  Diarios Transf 
		and x.InventLocationId = 'TRANSITO'
		and id.INVENTLOCATIONID = 'MEGAPAN-01'*/
-----------------------------------------------------------------------------------------------------------------
-- FIN Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
-----------------------------------------------------------------------------------------------------------------

  create table #TABLA_ARTICULO ([DataAreaID] nvarchar(04), [ArtCod] nvarchar(30))
  if isnull(@ARTICULOS,'') <> ''
	begin
	  while patindex('%,%',@ARTICULOS)>0
		  begin
			insert into #TABLA_ARTICULO select @AREA, substring(@ARTICULOS, 0, patindex('%,%', @ARTICULOS))
			set @ARTICULOS = RIGHT(@ARTICULOS, Len(@ARTICULOS) - patindex('%,%',@ARTICULOS))
		  end
	  if patindex('%,%',@ARTICULOS) = 0 and len(@ARTICULOS) > 0
	  begin
		insert into #TABLA_ARTICULO  select @AREA, @ARTICULOS
	  end

	  -- Elimina los registros que no son Grupos Reales y que al desarmar el string recibido por parametro se guardaron
	  delete #TABLA_ARTICULO
	  from #TABLA_ARTICULO tag
	  where not exists (select 1
						from InventTable it
						where it.DataAreaID = @AREA and
							it.ItemID  = tag.ArtCod 							
								)
	end								
  else
	begin
		-- Si no se definió ningun grupo se cargan todos.
		insert into #TABLA_ARTICULO
		select @AREA, it.ItemID
		from InventTable it
		where it.DataAreaID = @AREA
	end	
   CREATE INDEX [IX_TABLA_ARTICULO_01] ON #TABLA_ARTICULO ([DataAreaID], [ArtCod]) 
 
    --select * from #TABLA_ARTICULO													-- !! Bloquear esta linea, se usa solo para control sin parametros
    
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// Crea Base Temporal para guardar los datos y generar multiples salidas drop table #TEMP
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --drop table #TEMP
  Create Table #TEMP
  ( Paso								smallint,
	AreaCod								nvarchar(20),
	AreaDes								nvarchar(80),
	RPT_CatDes							nvarchar(40),
	RPT_Des								nvarchar(30),
	Fecha								datetime, 
	
	ArtCod								nvarchar(20),
	ArtDes								nvarchar(80),
	ArtTipo								nvarchar(10),
	ArtGruCod							nvarchar(30),
	ArtGruDes							nvarchar(80),
	ArtCtoGruCod						nvarchar(30),
	ArtUn								nvarchar(30),
	ArtUnComp							nvarchar(30),
	ArtConfig							nvarchar(30),
	
	--// Informacion para ver de forma homogenia los Articulos sustitutos al eliminar los Semielaborados
	ArtRefCod							nvarchar(20),
	ArtRefDes							nvarchar(80),
	
	--// Informacion referida al Lote, Vencimiento que se calcula al fin de mes solicitado.
	SitioCod							nvarchar(20),	
	AlmCod								nvarchar(20),
	LoteNro								nvarchar(20),
	LoteVto								datetime,
	SubLoteNro							nvarchar(20),
	TipoExistencia						nvarchar(03),				-- Esta campo es para e-Logistic
	Exportacion							nvarchar (01),				-- Esta campo es para e-Logistic	

	--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
	Val_Tipo							nvarchar(05),
	Cantidad							float,
	ValMonLoc							float,
	ValRepo								float,
	Destino								nvarchar(10)
  )
  CREATE INDEX [IX_TEMP_01] ON #TEMP ([AreaCod], [ArtCod])
  CREATE INDEX [IX_TEMP_02] ON #TEMP ([AreaCod], [RPT_Des]) 
  /*
  drop table #TEMP
  drop table #TABLA_ARTICULO 
  */
  
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --// Controla que el formato solicita exista como opcion.
  --// La importancia de esto que no devuelve ningun valor y por ende no rompe el formato de la tabla dinamica.  Solo la detiene
  ----------------------------------------------------------------------------------------------------------------------------------------------
  --if @FORMATO not in ('Gestion', 'e-LogCtrl', 'e-LogTxt')
  --  return 'ATENCION!!  EL FORMATO DE SALIDA NO ESTA DEFINIDO EN XLS_CORP_InventarioReposicionEXP' -- Detiene la ejecucion del proceso
  
  /*
  drop table #TEMP
  declare @AREA			nvarchar(04) set @AREA		= '010'
  declare @MESATRAS		smallint	 set @MESATRAS	= 1
  declare @FORMATO		nvarchar(30) set @FORMATO	= 'Gestion'			-- Ver opciones en la declaracion del SP
  declare @ARTICULOS	nvarchar(99) set @ARTICULOS	= null	
  --*/  
    
  declare @CURRENCYCODE				nvarchar(05) set @CURRENCYCODE			= (select CurrencyCode			from XLS_DIM_Seguridad where DataAreaID = @AREA) 
  declare @CORPORATECURRENCYCODE	nvarchar(05) set @CORPORATECURRENCYCODE = (select CorporateCurrencyCode	from XLS_DIM_Seguridad where DataAreaID = @AREA)
  declare @COMPANYNAME				nvarchar(30) set @COMPANYNAME			= (select CompanyName			from XLS_DIM_Seguridad where DataAreaID = @AREA)
  --20/09/2018 SCa - Se sustituye por @xIdBase
  --declare @IDBASE					nvarchar(30) set @IDBASE				= (select IdBase				from XLS_DIM_Seguridad where DataAreaID = @AREA)
  declare @DECCHAR					nvarchar(01) set @DECCHAR				= (select DecChar				from XLS_DIM_Seguridad where DataAreaID = @AREA) 
     
	  
		/*
		declare @AREA						nvarchar(05) set @AREA = '010'    
		declare @CURRENCYCODE				nvarchar(05) set @CURRENCYCODE			= (select CurrencyCode			from XLS_DIM_Seguridad where DataAreaID = @AREA) 
		declare @CORPORATECURRENCYCODE		nvarchar(05) set @CORPORATECURRENCYCODE = (select CorporateCurrencyCode	from XLS_DIM_Seguridad where DataAreaID = @AREA)
		declare @COMPANYNAME				nvarchar(30) set @COMPANYNAME			= (select CompanyName			from XLS_DIM_Seguridad where DataAreaID = @AREA)
		--20/09/2018 SCa - Se sustituye por @xIdBase
		--declare @IDBASE						nvarchar(30) set @IDBASE				= (select IdBase				from XLS_DIM_Seguridad where DataAreaID = @AREA)
		declare @DECCHAR					nvarchar(01) set @DECCHAR				= (select DecChar				from XLS_DIM_Seguridad where DataAreaID = @AREA) 		
		
		declare @MESATRAS smallint  set @MESATRAS = -1	
		declare @FECHA_FIN datetime
		set @MESATRAS = ABS(isnull((@MESATRAS), 0))* -1							-- Por Omision Mes Corriente. Como usara MMAct es por -1
		set @FECHA_FIN = (select distinct x.MMFin from xls_dim_tiempo x where x.MMAct =	@MESATRAS )
		-- En el caso de pedir el mes en curso , ajusta la fecha a hoy sin hora para que el proceso lo tome				
		set @FECHA_FIN = (case when @FECHA_FIN > getdate() then convert(varchar(10), getdate(), 112) else @FECHA_FIN end)
		--*/
		--------------------------------------------------------------------------------------------------------------------------------------
		--// FORMATO: e-Log (Proceso) - PASO 01 de 05 // Informacion del inventario para enviar a e-Logistic leida de la XLS_DIM_Inventario
		--// select * from #TEMP
		--------------------------------------------------------------------------------------------------------------------------------------
/*		insert into #TEMP
		( Paso, AreaCod, AreaDes, RPT_CatDes, RPT_Des, Fecha,
			ArtCod, ArtDes, ArtTipo, ArtGruCod, ArtGruDes, ArtCtoGruCod, ArtUn, ArtUnComp, ArtConfig,
			ArtRefCod, ArtRefDes, 														-- Articulos sustitutos al eliminar los Semielaborados
			AlmCod, LoteNro, LoteVto, SubLoteNro, TipoExistencia,Exportacion,			-- Vencimiento que se calcula al fin de mes solicitado.
			Cantidad, ValMonLoc, ValRepo												-- Cantidadades expresadas en la Un. de Inv y Valores
			, Destino																	-- ACCEAM cuando es el destino del tránsito es CEAM

			) */
		(select destino, TransRefID, *
/*
			1																													AS [Paso],
  			t.DataAreaID																										AS [AreaCod],  
			@COMPANYNAME																										AS [AreaDes],
			'Inventario'																										AS [RPT_CatDes],
			t.Reporte_Des																										AS [RPT_Des],
			@FECHA_FIN																											AS [Fecha], 

			--// Informacion del Articulo recuperado de XLS_DIM_Articulos
			a.ArtCod																											AS [ArtCod],
			a.ArtDes																											AS [ArtDes],
			a.ArtTipo																											AS [ArtTipo],
			a.ArtGrupoCod																										AS [ArtGruCod],
			a.ArtGrupoDes																										AS [ArtGruDes],
			a.CtoGrupoCod																										AS [ArtCtoGruCod],
			a.UnInve																											AS [ArtUn],
			a.UnComp																											AS [ArtUnComp],
			t.ConfigId																											AS [ArtConfig],
			
			--// Informacion para ver de forma homogenia los Articulos sustitutos al eliminar los Semielaborados
			a.ArtCod																											AS [ArtRefCod],
			a.ArtDes																											AS [ArtRefDes],	
			
			--// Informacion referida al Lote, Vencimiento que se calcula al fin de mes solicitado.
			t.InventLocationID																									AS [AlmCod],
			(case when t.Reporte_CatCod = 2 and t.DataAreaID != '310'			-- GN+CG Ajuste exclusivo para Peru 17/10/14
				then ''
				else isnull(t.InventBatchId,'')
			 end)																												AS [LoteNro],
			(case when t.Reporte_CatCod = 2 and t.DataAreaID != '310'			-- GN+CG Ajuste exclusivo para Peru 17/10/14
				then '19000101'
				else isnull(t.LoteVto,'19000101')
			 end)																												AS [LoteVto],
			 t.InventSubBatchID																									AS [SubLoteNro],
			 
			(case 
				when t.Reporte_CatCod = 2 then 'PRO'
				when (select pp.ShipGitWarehouse												-- Alm. es = al def. en LandedCost = 'TRA' 
						from PurchParameters pp
						where pp.DataAreaID = @AREA) = t.InventLocationID 
				then 'TRA'
				when  t.InventLocationID = 'EXT-TRAN' then 'TRA' -- # 95276 - Cambio definiciones Inventarios en Interface Axapta - Elog
				else dbo.fc_CorpArticuloVencido(a.ArtGrupoCod, isnull(t.LoteVto,'19000101'), @FECHA_FIN, dm.DispositionCode)	-- Depende del Vto del Art. 'VEN' o 'DIS'
			 end)																												AS TipoExistencia,
			 (case when @ALMACENEXP = 'Ninguna' then 0
				when @ALMACENEXP = 'Todas' then 1
				when t.InventLocationId = @ALMACENEXP then (case when @UBICACIONEXP = 'SinUso' then 1
															when t.WMSLocationId = @UBICACIONEXP then 1 else 0 end)
				else 0 end)																										AS Exportacion,

			--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
			t.PhysicalQty																									AS [Cantidad],
			t.PhysicalValue																								AS [ValMonLoc],
			t.PhysicalQty * dbo.fc_CostoUnitario ('120', t.ItemID, @FECHA_FIN, 'MonCorp', 4)								AS [ValRepo], 
			t.Destino																											AS [Destino] */
		from XLS_DIM_Inventario t
			inner join #TABLA_ARTICULO ta on
				ta.DataAreaID = t.DataAreaID  and
				ta.ArtCod = t.ItemID
			inner join XLS_DIM_Articulos a on										-- Valores de los Articulos
				a.DataAreaID = t.DataAreaID and
				a.ItemID = t.ItemID
			left join InventBatch inb on											-- Apertura por Lote, Vencimiento y Disponibilidad.
				inb.DataAreaID = t.DataAreaID and
				inb.InventBatchID = t.InventBatchID and
				inb.ItemID = t.ItemID 

			-- SubLote de Calidad
			left join InventSubBatch_MPH isb on
				isb.DataAreaID = t.DataAreaID and
				isb.InventSubBatchID = t.InventSubBatchID and
				isb.InventBatchID = t.InventBatchID and								--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
				isb.ItemID = t.ItemID
			-- Codigo de Disponibilidad del SubLote
			left join PdsDispositionMaster dm on							
				dm.DataAreaID = isb.DataAreaID and
				dm.DispositionCode = isb.PdsDispositionCode 

			left join XLS_DIM_Tiempo dt on											-- Formatos de Fecha
				dt.Fecha = @FECHA_FIN
		where t.DataAreaID = @AREA and
			t.Wip_Tipo =0 and														-- ENUM: ProdWipType_NA:: 0=Material, 1=Labor - Mano de Obra, 2=Costo Indirecto		  
			t.Fecha <= @FECHA_FIN and												-- Consolida toda la información, desde el saldo a fin de mes solicitado
			round(t.PhysicalQty,2) + round(t.PhysicalValue,2) != 0	and				-- Se evitan linea sin unidades ni valores
			t.InventSiteID not in ('SitioRet','RETENCION') and						-- CG - Las unidades del Sitio de Retención no deben informarse (visto con GN,Alejandro Huertas,Guzmán de la Vega, Milton Mirabal)Ticket # 60826
			--+ FUM 11/03/2019 RC - Sustituir el filtro de Artículos Trade, de forma de Incluir todos los artículos que se envían a Panamá y 
			--                      no solo los de los grupos de artículos TR, según los usuarios indicaron incialmente. Asimismo, 
			--						incluir el almacén de tránsito de Panamá.
			/* ( t.InventLocationId in ('MEGAPAN-01', 'EXT-TRAN') */ 		
			 ((@EsTrade='1' and a.ArtGrupoCod like '%TR') or (@EsTrade='0' and a.ArtGrupoCod not like '%TR') )
			  and t.InventLocationID = 'TRANSITO'
/*		group by
  			t.DataAreaID,
			t.Reporte_CatCod,
			t.Reporte_Des,
			a.ArtCod,
			a.ArtDes,
			a.ArtTipo,
			a.ArtGrupoCod,
			a.ArtGrupoDes,
			a.CtoGrupoCod,
			a.UnInve,
			a.UnComp,
			t.ConfigId,
			t.InventLocationID,
			t.InventBatchId,
			isnull(t.LoteVto,'19000101'),
			t.InventSubBatchID,
			t.WMSLocationId,
			dm.DispositionCode,
			t.Destino
		having sum(t.PhysicalQty)+ sum(t.PhysicalValue) != 0
*/		) 

/*
		--------------------------------------------------------------------------------------------------------------------------------------
		--// FORMATO: e-Log (Proceso) - PASO 02 de 05 // Los articulos que son "Art. Terminados en Proceso" tambien estan reflejados en el 
		--// inventario.  En este paso se netea todas aquellas Notificaciones Parciales porque se convertiran en sus elementos de forma
		--// proporcional en un paso posterior
		--------------------------------------------------------------------------------------------------------------------------------------
		insert into #TEMP
		( Paso, AreaCod, AreaDes, RPT_CatDes, RPT_Des, Fecha,
			ArtCod, ArtDes, ArtTipo, ArtGruCod, ArtGruDes, ArtCtoGruCod, ArtUn, ArtUnComp, ArtConfig,
			ArtRefCod, ArtRefDes, 														-- Articulos sustitutos al eliminar los Semielaborados
			AlmCod, LoteNro, LoteVto, TipoExistencia,Exportacion,						-- Vencimiento que se calcula al fin de mes solicitado.
			Cantidad, ValMonLoc, ValRepo												-- Cantidadades expresadas en la Un. de Inv y Valores
			, Destino																	-- ACCEAM cuando es el destino del tránsito es CEAM
			)  
		(select
			2																													AS [Paso],
  			t.AreaCod																											AS [AreaCod],  
			t.AreaDes																											AS [AreaDes],
			t.RPT_CatDes																										AS [RPT_CatDes],
			'Art.Term.en Proceso (N)'																							AS [RPT_Des],
			t.Fecha																												AS [Fecha], 

			--// Informacion del Articulo recuperado de XLS_DIM_Articulos
			t.ArtCod																											AS [ArtCod],
			t.ArtDes																											AS [ArtDes],                                                                           
			t.ArtTipo																											AS [ArtTipo],	
			t.ArtGruCod																											AS [ArtGruCod],	
			t.ArtGruDes																											AS [ArtGruDes],
			t.ArtCtoGruCod																										AS [ArtCtoGruCod],		
			t.ArtUn																												AS [ArtUn],
			t.ArtUnComp																											AS [ArtUnComp],			
			t.ArtConfig																											AS [ArtConfig],

			--// Informacion para ver de forma homogenia los Articulos sustitutos al eliminar los Semielaborados
			t.ArtRefCod																											AS [ArtRefCod],
			t.ArtRefDes																											AS [ArtRefDes],	

			--// Informacion referida al Lote, Vencimiento que se calcula al fin de mes solicitado.
			t.AlmCod																											AS [AlmCod],	
			t.LoteNro																											AS [LoteNro],
			t.LoteVto																											AS [LoteVto],	
			t.TipoExistencia																									AS [TipoExistencia],
			t.Exportacion																										AS Exportacion,


			--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
			t.Cantidad  * -1																									AS [Cantidad],
			t.ValMonLoc * -1																									AS [ValMonLoc],
			t.ValRepo   * -1																									AS [ValRepo],
			t.Destino																											AS [Destino]
		from #TEMP t
		where t.RPT_Des = 'Art.Term.en Proceso'
		)
		
		------------------------------------------------------------------------------------------------------------------------------------------
		--// FORMATO: e-Log (Proceso) - PASO 03 de 05
		--// NOTA: Basado en el paso 2/5, (lo que se neteó), se explica en sus elementos cambiandole el signo.
		--//	   Observe que la condicion del Where es Paso = 2.
		--//	   Esta parte es importante porque consume la MP (en proceso) de forma proporcional al Art. Notificado como Terminado a pesar que
		--//	   la OP aun esta abierta. 
		------------------------------------------------------------------------------------------------------------------------------------------
		/*
		declare @AREA						nvarchar(05) set @AREA = '010'    
		declare @CURRENCYCODE				nvarchar(05) set @CURRENCYCODE			= (select CurrencyCode			from XLS_DIM_Seguridad where DataAreaID = @AREA) 
		declare @CORPORATECURRENCYCODE		nvarchar(05) set @CORPORATECURRENCYCODE = (select CorporateCurrencyCode	from XLS_DIM_Seguridad where DataAreaID = @AREA)
		declare @MESATRAS smallint  set @MESATRAS = -1	
		declare @FECHA_FIN datetime
		set @MESATRAS = ABS(isnull((@MESATRAS), 0))* -1							-- Por Omision Mes Corriente. Como usara MMAct es por -1
		set @FECHA_FIN = (select distinct x.MMFin from xls_dim_tiempo x where x.MMAct =	@MESATRAS )
		-- En el caso de pedir el mes en curso , ajusta la fecha a hoy sin hora para que el proceso lo tome				
		set @FECHA_FIN = (case when @FECHA_FIN > getdate() then convert(varchar(10), getdate(), 112) else @FECHA_FIN end)
		--*/
		insert into #TEMP
		( Paso, AreaCod, AreaDes, RPT_CatDes, RPT_Des, Fecha,
			ArtCod, ArtDes, ArtTipo, ArtGruCod, ArtGruDes, ArtCtoGruCod, ArtUn, ArtUnComp, ArtConfig,
			ArtRefCod, ArtRefDes, 																-- Articulos sustitutos al eliminar los Semielaborados
			LoteNro, LoteVto, TipoExistencia,Exportacion,
			Cantidad, ValMonLoc, ValRepo														-- Cantidadades expresadas en la Un. de Inv y Valores
			, Destino																	-- ACCEAM cuando es el destino del tránsito es CEAM
			)     
		(select
			3																													AS [Paso],
  			t.AreaCod																											AS [AreaCod],  
			t.AreaDes																											AS [AreaDes],
			t.RPT_CatDes																										AS [RPT_CatDes],
			'Art.Term.en Proceso (D)'																							AS [RPT_Des],
			t.Fecha																												AS [Fecha], 
			
			--// Informacion del Articulo recuperado de XLS_DIM_Articulos
			a.ArtCod																											AS [ArtCod],
			a.ArtDes																											AS [ArtDes],                                                                           
			a.ArtTipo																											AS [ArtTipo],	
			a.ArtGrupoCod																										AS [ArtGruCod],	
			a.ArtGrupoDes																										AS [ArtGruDes],
			a.CtoGrupoCod																										AS [ArtCtoGruCod],		
			a.UnInve																											AS [ArtUn],
			a.UnComp																											AS [ArtUnComp],
			t.ArtConfig																											AS [ArtConfig],
				
			--// Informacion para ver de forma homogenia los Articulos sustitutos al eliminar los Semielaborados
			t.ArtCod																											AS [ArtRefCod],
			t.ArtDes																											AS [ArtRefDes],
			''																													AS [LoteNro],
			'19000101'																											AS [LoteVto],
			'PRO'																												AS [TipoExistencia],
			t.Exportacion																										AS Exportacion,

			--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
			--// Cantidad de Inventario del Semi * Cantidad Consumida por 1 Unidad
			sum(t.Cantidad * c.CtoRefQtyCon) * -1 																				AS [Cantidad],
			sum(dbo.fc_Cambio(t.Cantidad *
							  c.CtoRefQtyCon *
							  dbo.fc_CostoUnitario (t.AreaCod, a.ArtCod, t.Fecha, 'MonCorp', 4)
							  , t.Fecha,
				@CORPORATECURRENCYCODE,@CURRENCYCODE, t.AreaCod))	* -1														AS [ValMonLoc],
			
			--// Cantidad de Inventario del Semi * Cantidad Consumida por 1 Unidad * Cto Corp por 1 Unidad
			sum(t.Cantidad * 
				c.CtoRefQtyCon *
				dbo.fc_CostoUnitario (t.AreaCod, a.ArtCod, t.Fecha, 'MonCorp', 4)) * -1											AS [ValRepo],
			t.Destino																											AS [Destino]
		from #TEMP t
			inner join (select c.ItemID,
							c.CtoRefCod, 
							c.CtoCalcSN,
							c.ArtTipoRes,
							(case when c.ItemID = c.CtoRefCod
								then 1
								else sum(c.CtoRefQtyCon)
							 end) as CtoRefQtyCon
						from XLS_DIM_Costos c														-- Busco para cada Articulo sus Elementos
						where c.DataAreaID = @AREA and
								c.MMFin = @FECHA_FIN and											-- Actual para la fecha solicitada
								c.CostingType = 4 and												-- Costo Tipo 4=Reposicion		
								c.CtoRefTipoGru like '%MAT%'  										-- Solo los materiales						
						group by c.ItemID, c.CtoRefCod, c.CtoCalcSN, c.ArtTipoRes
							) c on
				c.ItemId = t.ArtCod 
			left join XLS_DIM_Articulos a on														-- Valores de los Articulos
				a.DataAreaID = t.AreaCod and
				a.ItemID = c.CtoRefCod		
		where t.Paso = 2
			and a.ArtCod != t.ArtCod	 															-- +GN 20150616 Ajustado en la revision con Rosario Ojeda
			--+ FUM 11/03/2019 RC - Sustituir el filtro de Artículos Trade, de forma de Incluir todos los artículos que se envían a Panamá y 
			--                      no solo los de los grupos de artículos TR, según los usuarios indicaron incialmente.
			and ((@EsTrade='1' /*and a.ArtGrupoCod like '%TR'*/) or (@EsTrade='0' and a.ArtGrupoCod not like '%TR'))
		group by
			t.AreaCod,
			t.AreaDes,
			t.RPT_CatDes,
			t.Fecha,
			a.ArtCod,
			a.ArtDes,
			a.ArtTipo,
			a.ArtGrupoCod,
			a.ArtGrupoDes,
			a.CtoGrupoCod,
			a.UnInve,
			a.UnComp,
			t.ArtConfig,
			t.ArtCod,
			t.ArtDes,
			t.Exportacion,
			t.Destino
			)

		------------------------------------------------------------------------------------------------------------------------------------------
		--// FORMATO: e-Log (Proceso) - PASO 04 de 05
		--// NOTA: Basado en el paso anterior, esta parte del scrip, invierte la mercaderia, cantidades y valores de los Articulos que deban 
		--//		transformarse en Droga.
		--//		Para tal fin se utiliza la funcion dbo.fc_CorpArticuloComoDroga(a.CtoGrupoCod) = 'Si'
		------------------------------------------------------------------------------------------------------------------------------------------	
		insert into #TEMP
		( Paso, AreaCod, AreaDes, RPT_CatDes, RPT_Des, Fecha,
			ArtCod, ArtDes, ArtTipo, ArtGruCod, ArtGruDes, ArtCtoGruCod, ArtUn, ArtUnComp, ArtConfig,
			ArtRefCod, ArtRefDes, 														-- Articulos sustitutos al eliminar los Semielaborados
			AlmCod, LoteNro, LoteVto, TipoExistencia,Exportacion,						-- Vencimiento que se calcula al fin de mes solicitado.
			Cantidad, ValMonLoc, ValRepo												-- Cantidadades expresadas en la Un. de Inv y Valores
			, Destino																	-- ACCEAM cuando es el destino del tránsito es CEAM
			)  
		(select
			4																													AS [Paso],
  			t.AreaCod																											AS [AreaCod],  
			t.AreaDes																											AS [AreaDes],
			t.RPT_CatDes																										AS [RPT_CatDes],
			'Ajuste a Mat. Prima N'																								AS [RPT_Des],
			t.Fecha																												AS [Fecha], 

			--// Informacion del Articulo recuperado de XLS_DIM_Articulos
			t.ArtCod																											AS [ArtCod],
			t.ArtDes																											AS [ArtDes],                                                                           
			t.ArtTipo																											AS [ArtTipo],	
			t.ArtGruCod																											AS [ArtGruCod],	
			t.ArtGruDes																											AS [ArtGruDes],
			t.ArtCtoGruCod																										AS [ArtCtoGruCod],		
			t.ArtUn																												AS [ArtUn],
			t.ArtUnComp																											AS [ArtUnComp],
			t.ArtConfig																											AS [ArtConfig],

			--// Informacion para ver de forma homogenia los Articulos sustitutos al eliminar los Semielaborados
			t.ArtRefCod																											AS [ArtRefCod],
			t.ArtRefDes																											AS [ArtRefDes],	

			--// Informacion referida al Lote, Vencimiento que se calcula al fin de mes solicitado.
			t.AlmCod																											AS [AlmCod],	
			t.LoteNro																											AS [LoteNro],
			t.LoteVto																											AS [LoteVto],	
			t.TipoExistencia																									AS [TipoExistencia],
			t.Exportacion																										AS Exportacion,

			--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
			t.Cantidad  * -1																									AS [Cantidad],
			t.ValMonLoc * -1																									AS [ValMonLoc],
			t.ValRepo   * -1																									AS [ValRepo],
			t.Destino																											AS [Destino]
		from #TEMP t
		where 
			dbo.fc_CorpArticuloComoDroga(t.ArtCtoGruCod) = 'Si' 					-- Articulos a convertir --> ArtSemielaborado
		)

		------------------------------------------------------------------------------------------------------------------------------------------
		--// FORMATO: e-Log (Proceso) - PASO 05 de 05
		--// NOTA: Basado en el paso 4/5, (lo que se neteó), se explica en sus elementos cambiandole el signo.
		--//	   Observe que la condicion del Where es Paso = 4
		--//	   En el caso que un Semi se explique con él mismo (en el caso de una compra), volverá aparecer en el inventario y lo que pueda 
		--//	   convertir lo convertirá a sus elementos.
		--//	   Hasta aqui se sigue sin analizar si es o no de interes MPH, accion que se realizará al finalizar.
		--//	   select * from #TEMP
		------------------------------------------------------------------------------------------------------------------------------------------
		/*
		declare @AREA						nvarchar(05) set @AREA = '010'    
		declare @CURRENCYCODE				nvarchar(05) set @CURRENCYCODE			= (select CurrencyCode			from XLS_DIM_Seguridad where DataAreaID = @AREA) 
		declare @CORPORATECURRENCYCODE		nvarchar(05) set @CORPORATECURRENCYCODE = (select CorporateCurrencyCode	from XLS_DIM_Seguridad where DataAreaID = @AREA)
		declare @MESATRAS smallint  set @MESATRAS = -1	
		declare @FECHA_FIN datetime
		set @MESATRAS = ABS(isnull((@MESATRAS), 0))* -1							-- Por Omision Mes Corriente. Como usara MMAct es por -1
		set @FECHA_FIN = (select distinct x.MMFin from xls_dim_tiempo x where x.MMAct =	@MESATRAS )
		-- En el caso de pedir el mes en curso , ajusta la fecha a hoy sin hora para que el proceso lo tome				
		set @FECHA_FIN = (case when @FECHA_FIN > getdate() then convert(varchar(10), getdate(), 112) else @FECHA_FIN end)
		--*/
		insert into #TEMP
		( Paso, AreaCod, AreaDes, RPT_CatDes, RPT_Des, Fecha,
			ArtCod, ArtDes, ArtTipo, ArtGruCod, ArtGruDes, ArtCtoGruCod, ArtUn, ArtUnComp, ArtConfig,
			ArtRefCod, ArtRefDes, 																-- Articulos sustitutos al eliminar los Semielaborados
			LoteNro, LoteVto, TipoExistencia,Exportacion,
			Cantidad, ValMonLoc, ValRepo														-- Cantidadades expresadas en la Un. de Inv y Valores
			, Destino																	-- ACCEAM cuando es el destino del tránsito es CEAM
			)     
		(select
			5																													AS [Paso],
  			t.AreaCod																											AS [AreaCod],  
			t.AreaDes																											AS [AreaDes],
			t.RPT_CatDes																										AS [RPT_CatDes],
			'Ajuste a Mat. Prima D'																								AS [RPT_Des],
			t.Fecha																												AS [Fecha], 
			
			--// Informacion del Articulo recuperado de XLS_DIM_Articulos
			a.ArtCod																											AS [ArtCod],
			a.ArtDes																											AS [ArtDes],                                                                           
			a.ArtTipo																											AS [ArtTipo],	
			a.ArtGrupoCod																										AS [ArtGruCod],	
			a.ArtGrupoDes																										AS [ArtGruDes],
			a.CtoGrupoCod																										AS [ArtCtoGruCod],		
			a.UnInve																											AS [ArtUn],
			a.UnComp																											AS [ArtUnComp],
			t.ArtConfig																											AS [ArtConfig],
				
			--// Informacion para ver de forma homogenia los Articulos sustitutos al eliminar los Semielaborados
			t.ArtCod																											AS [ArtRefCod],
			t.ArtDes																											AS [ArtRefDes],

			-- GN+CG Ajuste exclusivo para Peru 17/10/14
			(case when t.AreaCod = '310' then t.LoteNro else '' end)															AS [LoteNro],
			(case when t.AreaCod = '310' then t.LoteVto else '19000101' end)													AS [LoteVto],
			'PRO'																												AS [TipoExistencia],
			t.Exportacion																										AS Exportacion,			

			--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
			--// Cantidad de Inventario del Semi * Cantidad Consumida por 1 Unidad
			sum(t.Cantidad * c.CtoRefQtyCon) * -1 																				AS [Cantidad],
			sum(dbo.fc_Cambio(t.Cantidad *
							  c.CtoRefQtyCon *
							  dbo.fc_CostoUnitario (t.AreaCod, a.ArtCod, t.Fecha, 'MonCorp', 4)
							  , t.Fecha,
				@CORPORATECURRENCYCODE, @CURRENCYCODE, t.AreaCod))	* -1														AS [ValMonLoc],
			
			--// Cantidad de Inventario del Semi * Cantidad Consumida por 1 Unidad * Cto Corp por 1 Unidad
			sum(t.Cantidad *
				c.CtoRefQtyCon *
				dbo.fc_CostoUnitario (t.AreaCod, a.ArtCod, t.Fecha, 'MonCorp', 4)) * -1											AS [ValRepo],
				t.Destino																										AS [Destino]
		from #TEMP t
			inner join (select c.ItemID, c.CtoRefCod, (case when c.ItemID = c.CtoRefCod	
															then 1
															else sum(c.CtoRefQtyCon)
														end) as CtoRefQtyCon
						from XLS_DIM_Costos c														-- Busco para cada Articulo sus Elementos
						where c.DataAreaID = @AREA and
								c.MMFin = @FECHA_FIN and											-- Actual para la fecha solicitada
								c.CostingType = 4 and												-- Costo Tipo 4=Reposicion		
								c.CtoRefTipoGru like '%MAT%'  										-- Solo los materiales						
						group by c.ItemID, c.CtoRefCod
							) c on
				c.ItemId = t.ArtCod 
			left join XLS_DIM_Articulos a on														-- Valores de los Articulos
				a.DataAreaID = t.AreaCod and
				a.ItemID = c.CtoRefCod	and
				--+ FUM 11/03/2019 RC - Sustituir el filtro de Artículos Trade, de forma de Incluir todos los artículos que se envían a Panamá y 
				--                      no solo los de los grupos de artículos TR, según los usuarios indicaron incialmente.
				((@EsTrade='1' and a.ArtGrupoCod like '%TR') or (@EsTrade='0' and a.ArtGrupoCod not like '%TR'))
		where t.Paso = 4
		group by
			t.AreaCod,
			t.AreaDes,
			t.RPT_CatDes,
			t.Fecha,
			a.ArtCod,
			a.ArtDes,
			a.ArtTipo,
			a.ArtGrupoCod,
			a.ArtGrupoDes,
			a.CtoGrupoCod,
			a.UnInve,
			a.UnComp,			
			t.ArtConfig,
			t.ArtCod,
			t.ArtDes,
			t.Exportacion,
			(case when t.AreaCod = '310' then t.LoteNro else '' end),
			(case when t.AreaCod = '310' then t.LoteVto else '19000101' end),
			t.Destino
			)
		
		--------------------------------------------------------------------------------------------------------------------------------------
		--// FORMATO: e-Log (Muestra) - PASO 01 de 01 // Informacion del inventario para e-Logistic
		--------------------------------------------------------------------------------------------------------------------------------------
			(select
				dbo.fc_CorpArticuloDeInteres(x.ArtTipo, x.ArtCtoGruCod)						AS [Int_CorpSN],
				t.Fecha																		AS [Fecha], 
				x.RPT_CatDes																AS [RPT_CatDes],
				x.RPT_Des																	AS [RPT_Des],
				x.ArtTipo																	AS [Art_Tipo],
				x.ArtCtoGruCod																AS [ArtCtoGruCod],
				@xIdBase																	AS [IdBase],			-- Campo e-Log Nº 01
				t.AA																		AS [Año],				-- Campo e-Log Nº 02
				t.MM																		AS [Mes],				-- Campo e-Log Nº 03
				x.ArtCod																	AS [ArtCod],			-- Campo e-Log Nº 04
				x.ArtDes																	AS [ArtDes],			-- Solo para Control
				--+ FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.				
				x.AlmCod																	AS [AlmCod],			-- Solo para Control
				--- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.				
				x.LoteNro																	AS [Lote],				-- Campo e-Log Nº 05
				x.LoteVto																	AS [LoteVto],			-- Campo e-Log Nº 06
				x.TipoExistencia															AS [TipoExistencia],	-- Campo e-Log Nº 07
				--+ FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.
			/*	case x.AlmCod 
				when 'MEGAPAN-01' then 'ACCEAM'
				--+ FUM 11/03/2019 RC - Incluir el almacén de tránsito de Panamá
				when 'EXT-TRAN' then 'ACCEAM'
				--+ FUM 19/03/2019 - Incluir artículos Trade del almacén de tránsito general
				when 'TRANSITO' then (
				--+ FUM:	RC 07/10/2021 -- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
					case x.Destino 
					when 'MEGAPAN-01' then 'ACCEAM'
					else ''			
					end )
				else ''
				end		*/	x.Destino																AS [Destino],			-- Campo e-Log Nº 09
				--- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.				
				--- FUM:	RC 07/10/2021 -- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
				x.ArtUn																		AS [Un],				-- Solo para Control
				x.ArtRefCod																	AS [ArtRefCod],	
				x.ArtRefDes																	AS [ArtRefDes],
				x.Paso																		AS [Paso],
				sum(x.Cantidad)																AS [Cantidad],			-- Campo e-Log Nº 08
				sum(x.ValRepo)																AS [ValRepo],
				sum(x.Cantidad/u.Factor)													AS [CantEnUnComp],		-- Cantidad en Unidad de Compra GN en ColSCa con Sergio
				x.Exportacion																AS Exportacion				
			from #TEMP x
				inner join XLS_DIM_Tiempo t on																		-- Formato de Fecha
					t.Fecha = x.Fecha
				-- Tabla para convertir unidades 
				-- Revisado y Ajustado por AP y GN el 4/11/2014				-- Antes era dbo.fc_ConvertirUnidades(cit.DataAreaID, a.UnInve, cit.SalesUnit, sl.ItemID)
				left join XLS_DIM_Articulos_Unidades u on
					u.DataAreaID = @AREA and
					u.ItemID = x.ArtCod and					
					u.FromUnit = x.ArtUn and								-- Unidad Origen
					u.ToUnit = isnull((select ul.UndDestino
										from XLS_DIM_UnidadeLogistica ul
										where ul.DataAreaID = @AREA and
											ul.UndOrigen = x.ArtUn
										),x.ArtUnComp)						-- Unidad Destino										
					
			where 
				x.AreaCod = @AREA
				-- and dbo.fc_CorpArticuloDeInteres(x.ArtTipo, x.ArtCtoGruCod) = 'Si'			-- Solo articulos de Interes para MPH
				--   or x.ArtGruCod = 'ART3OS')	-- SC+ 22/12/2014 - OJO Con ésto!, si no se incluye el IntCorp da No y no se informan los ART3OS!!!
			group by
				t.Fecha,
				x.RPT_CatDes,				
				x.RPT_Des,
				x.ArtTipo,
				x.ArtCtoGruCod,
				t.AA,
				t.MM,
				x.ArtCod,
				x.ArtDes,
				x.AlmCod, --- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.	
				x.ArtGruCod, --+ FUM 19/03/2019 - Incluir artículos Trade del almacén de tránsito general 										
				x.LoteNro,
				x.LoteVto,
				x.TipoExistencia,
				x.ArtUn,
				x.ArtRefCod,
				x.ArtRefDes,
				x.Exportacion,
				x.Paso,
				x.Destino
			having SUM(x.Cantidad) != 0 
			)
		
		
			(select
				t.Fecha																		AS [Fecha], 
				x.ArtTipo																	AS [Art_Tipo],
				x.ArtCtoGruCod																AS [ArtCtoGruCod],				
				@xIdBase																	AS [IdBase],			-- Campo e-Log Nº 01
				t.AA																		AS [Año],				-- Campo e-Log Nº 02
				t.MM																		AS [Mes],				-- Campo e-Log Nº 03
				x.ArtCod																	AS [ArtCod],			-- Campo e-Log Nº 04
				x.ArtDes																	AS [ArtDes],			-- Solo para Control
				--+ FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.
				x.AlmCod																	AS [AlmCod],			-- Solo para Control
				--- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.				
				x.LoteNro																	AS [Lote],				-- Campo e-Log Nº 05
				x.LoteVto																	AS [LoteVto],			-- Campo e-Log Nº 06
				x.TipoExistencia															AS [TipoExistencia],	-- Campo e-Log Nº 07
				sum(x.Cantidad)																AS [Cantidad],			-- Campo e-Log Nº 08
				--+ FUM:	RC 07/10/2021 -- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
				case x.AlmCod 
				when 'MEGAPAN-01' then 'ACCEAM'
				--+ FUM 11/03/2019 RC - Incluir el almacén de tránsito de Panamá
				when 'EXT-TRAN' then 'ACCEAM'
				--+ FUM 19/03/2019 - Incluir artículos Trade del almacén de tránsito general
				when 'TRANSITO' then (
				--+ FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.
					case x.Destino 
					when 'MEGAPAN-01' then 'ACCEAM'
					else ''			
					end )
				else ''
				end																			AS [Destino],			-- Campo e-Log Nº 09
				--- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.				
				--- FUM:	RC 07/10/2021 -- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
				x.ArtUn																		AS [Un],				-- Solo para Control
				x.Exportacion																AS Exportacion,				
				
				-- Titulo (e-Log exige que se le envien los titulos en el TXT)
				'IdBase;Año;Mes;Producto;Lote;FechaVen;TipoExist;Cantidad;Destino;EXP'		AS [Titulo],

				-- Formato
				@xIdBase																			+ ';' +
				t.AA																				+ ';' +
				ltrim(convert(varchar(02), convert(smallint, t.MM)))								+ ';' +
				x.ArtCod																			+ ';' +
				x.LoteNro																			+ ';' +			-- Lote

				case when isnull(t1.AA,'') = '' and x.AreaCod = '010'
					then
						convert(varchar(10), dateadd(yy, 50, getdate()), 103)
					else
						isnull(t1.dd + '/' + t1.MM + '/' + t1.AA,'')
					
				end																					+ ';' +			-- Vto Lote (Provisorio)

				x.TipoExistencia																	+ ';' +			-- Tipo de Existencia

				replace(replace(ltrim(Str(sum(x.Cantidad/u.Factor),25,5)),'.',@DECCHAR),',',@DECCHAR)+ ';' +		-- Corp requiere (,) como separador
				--+ FUM:	RC 07/10/2021 -- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
				case x.AlmCod 
				when 'MEGAPAN-01' then 'ACCEAM'
				--+ FUM 11/03/2019 RC - Incluir el almacén de tránsito de Panamá
				when 'EXT-TRAN' then 'ACCEAM'
				--+ FUM 19/03/2019 - Incluir artículos Trade del almacén de tránsito general
				when 'TRANSITO' then (
				--+ FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.
					case x.Destino 
					when 'MEGAPAN-01' then 'ACCEAM'
					else ''			
					end )
				else ''
				end																					+ ';' +			-- Campo e-Log Nº 09
				--- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.	
				--- FUM:	RC 07/10/2021 -- Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous				
				x.Exportacion																		+ ';' 
																							AS [TXT]
			from #TEMP x
				inner join XLS_DIM_Tiempo t on																		-- Formato de Fecha
					t.Fecha = x.Fecha
				left join XLS_DIM_Tiempo t1 on
					t1.Fecha = x.LoteVto
				-- Tabla para convertir unidades
				-- Revisado y Ajustado por AP y GN el 4/11/2014				-- Antes era dbo.fc_ConvertirUnidades(cit.DataAreaID, a.UnInve, cit.SalesUnit, sl.ItemID)
				left join XLS_DIM_Articulos_Unidades u on
					u.DataAreaID = @AREA and
					u.ItemID = x.ArtCod and					
					u.FromUnit = x.ArtUn and								-- Unidad Origen
					u.ToUnit = isnull((select ul.UndDestino
										from XLS_DIM_UnidadeLogistica ul
										where ul.DataAreaID = @AREA and
											ul.UndOrigen = x.ArtUn
										),x.ArtUnComp)						-- Unidad Destino										
			where 
			x.AreaCod = @AREA and
			dbo.fc_CorpArticuloDeInteres(x.ArtTipo, x.ArtCtoGruCod) = 'Si'	-- Solo articulos de Interes para MPH
			--   or x.ArtGruCod = 'ART3OS')	-- SC+ 22/12/2014 - OJO Con ésto!, si no se incluye el IntCorp da No y no se informan los ART3OS!!!
			group by
				t.Fecha,
				x.AreaCod,
				x.ArtTipo,
				x.ArtCtoGruCod,
				t.DD,			
				t.AA,
				t.MM,
				x.ArtCod, 
				x.ArtDes,
				x.AlmCod, --- FUM 28/11/2018 RC - El campo destino en el TXT hacia e-Log, debe viajar con valor Fijo ACCEAM, si el almacén es MEGAPAN-01.	
				x.ArtGruCod, --+ FUM 19/03/2019 - Incluir artículos Trade del almacén de tránsito general 			
				x.LoteNro,
				x.LoteVto,
				x.TipoExistencia,
				x.Exportacion,
				x.ArtUn,
				t1.DD,
				t1.MM,
				t1.AA,
				x.Destino
			having SUM(x.Cantidad) != 0 
			)			
			*/