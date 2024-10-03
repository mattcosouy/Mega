
--CompromisosTodos '010','_Prevision', 'PR0501,CM0101','PR0501', 1

Declare
	@AREA			varchar(04) = null,										-- Empresa de Ejecución (QUITAR EL OPCIONAL = NULL!!!)
	@MODELO_PSP		varchar(10) = null,										-- Modelo de PSP (QUITAR EL OPCIONAL = NULL!!!)
 @ALMACEN_GRUPO		varchar(500) = 'PR0501,CM0101',				-- Opcion para agrupar almacenes. Si el almacen existe se especifica sino Otros. No debe filtrar datos, solo agrupar.
 @ALMACEN_GESTION	varchar(30)	 = 'PR0501',				-- Gestion Directa (solo 1 se debe definir un unico almacen)
 @ConVMI			varchar(01)  = 1,				-- Opcional por Roemmers UY (para indicar si se muestra o no InvVMI)	0=No	1=Sí
 @Salida		varchar(05)  = null
--*/
  set nocount on

  set @AREA			= isnull(@AREA,'010')									-- QUITAR ESTE OPCIONAL SOLO PARA PRUEBA !!!
  set @MODELO_PSP	= isnull(@MODELO_PSP,'_Prevision')								-- QUITAR ESTE OPCIONAL SOLO PARA PRUEBA !!!  

  -- Si no se recibe @ConVMI se asume "No"
  set @ConVMI = isnull(@ConVMI, 0)

  -- Si no se recibe @Salida se asume 'EXCEL'
  set @Salida = isnull(@Salida, 'EXCEL')

  ----------------------------------------------------------------------------------------------------------------------------------------
  --// Crea la Tabla Temporal
  --------------------------- 
  --// Nota: La definicion que esta debajo es para crear una tabla temporal como la que utiliza AX. Como esto se ejecuta por fuera de Ax
  --//		 se toma la definicion pero no se hace uso de la original. Si quisiera revisar la definicion la tabla original de Ax se llama
  --//		 inventSumDateTrans
  --// declare @AREA nvarchar(04)		set @AREA		= '100' 
  --// declare @MODELO_PSP nvarchar(10)	set @MODELO_PSP = 'E-Logistic'
  --// drop table #TEMP  
  ----------------------------------------------------------------------------------------------------------------------------------------
/* LIBERE ESTAS VARIABLE PARA EJECUTAR DE FORMA LOCAL
	drop table #TEMP  
	declare @AREA				nvarchar(04)	set @AREA			= '010' 
	declare @MODELO_PSP			nvarchar(10)	set @MODELO_PSP		= '_Prevision'
	declare @ALMACEN_GRUPO		varchar(500)	set @ALMACEN_GRUPO	= 'PR0501,PRM501,PRV501,PRReserva'	-- Opcion para agrupar almacenes. Si el almacen existe se especifica sino Otros. No debe filtrar datos, solo agrupar.
	declare @ALMACEN_GESTION	varchar(30)		set @ALMACEN_GESTION= 'PR0501'							-- Gestion Directa (solo 1 se debe definir un unico almacen)
--*/
  
  
    --drop table #TEMP
  Create Table #TEMP												-- En Ax es inventSumDateTrans
  ( -- Campos Creados por MPH para gestion de la consutla
	Step								nvarchar(20),				-- Guarda una referencia de cada paso de ejecucion para control
	Fecha								datetime,					-- Fecha a la que refiere el inventario.
	FechaHs								datetime,					-- Fecha Hora en que se hizo el proceso para saber el acumulado corriente.
	
	-- Campos utilizados en el codigo de Ax
  	DataAreaID							nvarchar(04),
  	Direction							int default 0,				-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision
  	TransType							int default 0,				-- InventTrans. Ver Descripciones en el Select debajo. Es muy extenso.
  	StatusIssue							int default 0,				-- InventTrans. Ver Descripciones en el Select debajo. Es muy extenso.
  	StatusReceipt						int default 0,				-- InventTrans. Ver Descripciones en el Select debajo. Es muy extenso.
  	Status_EnumAx						nvarchar(20)	default '',	-- Enum de StatusIssue y StatusReceip juntos. 
	Status_MPH							nvarchar(20)	default '',	-- Status MPH para facilitar la gestion.

  	TransRefId							nvarchar(20)	default '',	-- InventTrans. 
  	InventTransID						nvarchar(20)	default '',	-- InventTrans.
	ShipID								nvarchar(20)	default '',	-- InventTrans.
	DateExpected						datetime,					-- InventTrans.
	ItemID								nvarchar(20),				-- Articulo
	InventSiteID						nvarchar(10),				-- Sitio
	InventLocationId					nvarchar(30)	default '',	-- Almacen
	WMSLocationId						nvarchar(10)	default '',	-- Ubicacion
	WMSPalletId							nvarchar(18)	default '',	-- Pallet
	InventContainerID					nvarchar(20)	default '',	-- Bulto
	InventLegalNumID					nvarchar(20)	default '',	-- DUA	
	InventSerialId						nvarchar(20)	default '',	-- Serial
	ConfigId							nvarchar(30)	default '',	-- Dimension de Articulo Configuración
	InventSizeId						nvarchar(30)	default '',	-- Dimension de Articulo Tamaño
	InventColorId						nvarchar(30)	default '',	-- Dimension de Articulo Color
	InventBatchId						nvarchar(20)	default '',	-- Lote Numero
	ExpDate								datetime,					-- Lote Vencimiento
	MarcaEmpaque						nvarchar(5)		default '', -- Marca del empaque (PackingTradeManufacturer_MPH)
	LoteConsumido						nvarchar(2)		default '', -- Lote consumido (FinishedConsumption_MPH)
	FechaFinConsumo						datetime,					-- Fecha de Fin del Consumo
	InventSubBatchId					nvarchar(20)	default '',	-- Sub Lote de Calidad Numero	
	PdsDispositionCode					nvarchar(10),				-- Lote Codigo de Disponibilidad.
	DatePhysical						datetime,					-- Fecha Fisica (Si es menor a hoy y el StatusIssue o StatusReceipt = 1, sera fecha del dia -1)
	PdsVendBatchId						nvarchar(100)	default '',	-- Proveedor Lote Numero

	CompTipo							nvarchar(20)	default '',	-- Se utiliza el mismo enum TransType. Inicialmente detecta solo ventas.
	CompCod								nvarchar(100)	default '',	-- Codigo de Cliente/Proveedor con quien se toma el compromiso
	CompDes								nvarchar(80)	default '',	-- Descripcion de Cliente/Proveeodor con quien se tomó el compromiso
	CompTxt								nvarchar(99)	default '',	-- Informacion referencial del compromiso
	CompDiasVto							integer			default 0,	-- Solo en el bloque de Ventas se calcula los dias de vetas exigidos por el cliente.
	CompCreadoElHs						datetime,					-- Compromiso Creado El.	Cuando se creo la OP	(G.Crocamo) 28/2/2015
	CompCreadoPor						nvarchar(15)	default '', -- Compromiso Creado Por.	Quien Creo la OP		(GCrocamo)	29/2/2015
	
	TxtAction							nvarchar(99)	default '',	-- Accion a tomar
	Qty									numeric(28, 12) default 0,	-- Cantidad Fisica
	Value								numeric(38, 12) default 0,	-- Cantidad Fisica
	WMSOrderRejected_MPH				integer			default 0	-- Si la linea del PV fue rechazada de almacenes por falta de stock
  )
  --DROP INDEX [IX_DIM_VentaAxapta_01] ON [dbo].[XLS_DIM_VentaAxapta]
  CREATE INDEX [IX_TEMP_01] ON [dbo].#TEMP (DataAreaID,TransType)
  CREATE INDEX [IX_TEMP_02] ON [dbo].#TEMP (DataAreaID,TransType,ItemID)
  
  -- Como la fecha es un parametro opcional, en el caso de no venir se informa a hoy
  declare @FECHAHS		datetime set @FECHAHS	= getdate()
  declare @FECHA		datetime set @FECHA		= convert(datetime, convert(varchar(10), @FECHAHS, 112))
  declare @FECHA_INI	datetime set @FECHA_INI = (select MMIni from XLS_DIM_Tiempo where Fecha = @FECHA)
  declare @FECHA_FIN	datetime set @FECHA_FIN = (select MMFin from XLS_DIM_Tiempo where Fecha = @FECHA)
  declare @MMObj		float	 set @MMObj		= (select MMObj from XLS_DIM_Tiempo where Fecha = @FECHA) 
  --select @FECHAHS, @FECHA, @FECHA_INI, @FECHA_FIN, @MMObj, (1-@MMObj)

  ---------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 1.0
  --// Nota: Definie la 1º parte del Disponible determinada por todas las operaciones cerradas financieramente. En Ax es "Comprado" y "Vendido" 
  --//		 Ver en el Where el Criterio de Seleccion.
  ---------------------------------------------------------------------------------------------------------------------------------------------
  
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, Status_EnumAx, Status_MPH, 
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical,PdsVendBatchId, 
	Qty
  )
	
  select
  	'PASO Nº 1.0'																	as [Step],				-- Paso para control  
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa
	
	0																				as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision
	-1																				as [TransType],			-- TransType - Se Creo un estado -1 para identificar "Resumen"
	'Comprado+(-Vendido)'															as [Status_EnumAx],		-- Estado de la Recepcion o Emision
	'1. Disponible'																	as [Status_MPH],		-- Estado Mega Pharma. Se consolida Comprado + (- Vendido)
	
	@FECHA																			as [DateExpected],		-- Como son transacciones cerradas y se consolida, la Fecha Expectativa de Bodega es hoy.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	(case when itr.DatePhysical <= @FECHA then @FECHA else itr.DatePhysical end)	as [DatePhysical],		-- Como son transacciones cerradas y se consolida, la Fecha Fisicia de Bodega es hoy
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero

	sum(itr.Qty)																	as [Qty]				-- Cantidad
  from InventTrans itr																						-- Transacciones de Inventario
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID AND
		ib.ItemID = itr.ItemID 
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID		
  where 
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se consideran todas las transacciones cuyo estado es: StatusIssue = 1 = Vendido o el estado es StatusReceipt = 1 = Comprado
	--// Ambas operacion en su consolidacion reflejan la primera parte del disponible. 
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------
	itr.ITEMID = '1297301 ' and
	itr.DataAreaID = @AREA and
	itr.StatusIssue + itr.StatusReceipt = 1 and																-- Transacciones Cerradas
	itr.Qty != 0 and
	exists (select 1 from xls_DIM_Articulos a 																-- Solo Articulos con Inventario
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si')
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	(case when itr.DatePhysical <= @FECHA then @FECHA else itr.DatePhysical end),							-- Fecha de la transaccion acumulada a hoy
	ib.PdsVendBatchId																						-- Proveedor Lote Numero
	
  having sum(Qty) != 0
 /* 
  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 1.1
  --// Nota: Complementa la consulta anterior excluyendo los movimientos que tengan concluido su movimiento "Fisico" y "Financiero" que en Ax
  --//		 es "Comprado" y "Vendido".
  --//		 Ver en el Where el Criterio de Seleccion.
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
 	Direction, TransType, StatusIssue, StatusReceipt, Status_EnumAx, Status_MPH, 
	TransRefId, InventTransID,
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical,PdsVendBatchId, 
	TxtAction, 
	Qty
	)

  select
  	'PASO Nº 1.1'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	
	
	itr.Direction																	as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType																	as [TransType],			-- TransType - El enum se explica al finalizar
	itr.StatusIssue																	as [StatusIssue],
	itr.StatusReceipt																as [StatusReceipt],
	(case itr.StatusIssue																					-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt																-- Estados de la Recepcion
						when 002 then 'Recibido    '														-- Si esta en el inventario
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 002 then 'Deducido    '																		-- No esta en el inventario
		when 003 then 'Seleccionado'																		-- Esta en el inventario
		when 004 then 'Fisica Reser'																		-- Esta en el inventario
		when 005 then 'Pedido Reser'																		-- Esta en el inventario
		when 006 then 'En Pedido   '																		-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																			as [Status_EnumAx],		-- Estado de la Recepcion o Emision,	
	'1. Disponible'																	as [Status_MPH],		-- Estado Mega Pharma. 
	
	itr.TransRefId																	as [TransRefId],		-- Referencia de la transaccion??
	itr.InventTransID																as [InvnentTransID],	-- Referencia de la transaccion??
	
	itr.DatePhysical																as [DateExpected],		-- Fecha Expectativa de Bodega.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical																as [DatePhysical],		-- Fecha Fisica de la transaccion
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero

	-- Acciones Sugeridas
	(case 
		when itr.TransType = 0 and itr.StatusIssue   = 2 then 'Modulo Envios - Salió c/Remito y Falta Facturar!!!'
		when itr.TransType = 3 and itr.StatusReceipt = 2 then 'Modulo Proveedores - Entro c/Remito y Falta Factura!!!'
		else ''
	 end)																			as [TxtAction],			-- Accion Sugerida	

	sum(itr.Qty)																	as [Qty]				-- Cantidad
  from InventTrans itr																						-- Transacciones de Inventario
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID AND
		ib.ItemID = itr.ItemID
	left join ProdTable pr on
		pr.DataAreaID = itr.DataAreaID and
		pr.ProdID = itr.TransRefId
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID		
  where
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se consideran todas las transacciones cuyo estado aun no esta cerrado definitivamente (analizado en el paso anterior) y su 
	--// y su estado es "Recibido" y "Deducido".  Ambas operacion en su consolidacion reflejan la segunda parte del disponible porque aunque no
	--// este tomalmente cerrada (financieramente) la transaccion la mercaderia o ya entro o ya salio afectando el disponible.
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------  
	itr.ITEMID = '1297301 ' and
	itr.DataAreaID = @AREA and	
	itr.StatusIssue + itr.StatusReceipt != 1 and															-- Transacciones NO Cerradas
	itr.StatusIssue + itr.StatusReceipt  = 2 and  															-- Transacciones Recibidas o Deducidas
	exists (select 1 from xls_DIM_Articulos a																-- Solo Articulos con Inventario
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si') 	
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.Direction,																							-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision
	itr.TransType,																							-- Tipo de Transaccion
	itr.StatusIssue,																						-- Estado de Emision
	itr.StatusReceipt,																						-- Estado de Recepcion
	itr.TransRefId,
	itr.InventTransID,
	itr.DateExpected,
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad	
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical,																						-- Fecha Fisica
	ib.PdsVendBatchId,																						-- Proveedor Lote Numero
	itr.InventTransID,	
	isnull(pr.RemainInventPhysical,0)
  having sum(Qty) != 0

  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 2.0
  --// Nota: Analiza Mercaderia en Transito. 
  --//		 Ver en el Where el Criterio de Seleccion.
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, Status_EnumAx, Status_MPH, 
	TransRefId, InventTransID,
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical, PdsVendBatchId,
	TxtAction,
	Qty
	)

  select
  	'PASO Nº 2.0'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	

	itr.Direction																	as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType																	as [TransType],			-- TransType - El enum se explica al finalizar
	(case itr.StatusIssue																					-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt																-- Estados de la Recepcion
						when 002 then 'Recibido    '
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 002 then 'Deducido    '																		-- No esta en el inventario
		when 003 then 'Seleccionado'																		-- Esta en el inventario
		when 004 then 'Fisica Reser'																		-- Esta en el inventario
		when 005 then 'Pedido Reser'																		-- Esta en el inventario
		when 006 then 'En Pedido   '																		-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																			as [Status_EnumAx],		-- Estado de la Recepcion o Emision,		
	'2. En Transito'																as [Status_MPH],		-- Estado Mega Pharma. 

	upper(itr.ShipID)																as [TransRefId],		-- Referencia de la transaccion??
	itr.InventTransID																as [InvnentTransID],	-- Referencia de la transaccion??	
		
	itr.DateExpected																as [DateExpected],		-- Fecha Expectativa de Bodega.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical																as [DatePhysical],		-- Fecha Fisica de la transaccion
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero
	
	(case when  itr.StatusReceipt = 3
		then 'Modulo Embarques - Recepcionar embarque Nº ' + upper(itr.ShipID)
		else ''
	 end)																			as [TxtAction],			-- Accion Sugerida	
		
	sum(itr.Qty)																	as [Qty]				-- Cantidad
  from InventTrans itr
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID and
		ib.ItemID = itr.ItemID 
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID		
  where
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se debe excluir las situaciones analizadas con anterioridad. Por lo cual las operaciones deben ser No cerradas y no deben 
	--// haber sido "Recibidas" o "Deducidas" porque estas se analizaron en el paso anterior. 
	--// Aqui se incluyen entonces, solo las que tengan asignada una carpeta de Importacion y que no sean operaciones de Venta, Compra, Prod que
	--// se analizan en pasos posteriores cada una de estas.
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------  
	itr.ITEMID = '1297301 ' and	
	itr.DataAreaID = @AREA and		
	itr.StatusIssue + itr.StatusReceipt != 1 and															-- Transacciones NO Cerradas
	itr.StatusIssue + itr.StatusReceipt != 2 and  															-- Transacciones NO Recibidas o Deducidas
	itr.ShipID <> '' and																					-- Que tenga carpeta de Importación							
	itr.TransType not in (0,2,3,8) and
	exists (select 1 from xls_DIM_Articulos a																-- Solo Articulos con Inventario	
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si')
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.Direction,																							-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType,																							-- Tipo de Transaccion
	itr.StatusIssue,																						-- Estado de Emision
	itr.StatusReceipt,																						-- Estado de Recepcion
	itr.ShipID,
	itr.InventTransID,	
	itr.DateExpected,
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad	
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical,																						-- Fecha Fisica
	ib.PdsVendBatchId,																						-- Proveedor Lote Numero
	-- Acciones Sugeridas
	(case when  itr.StatusReceipt = 3
		then 'Modulo Embarques - Recepcionar embarque Nº ' + upper(itr.ShipID)
		else ''
	 end)
  having sum(Qty) != 0

  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 03
  --// Nota: Analiza Compromisos de Compras
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, Status_EnumAx, Status_MPH, 
	TransRefId, InventTransID, ShipID,
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical, PdsVendBatchId,
	TxtAction,
	Qty
	)
  select
  	'PASO Nº 3.0'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	
	
	itr.Direction																	as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType																	as [TransType],			-- TransType - El enum se explica al finalizar
	(case itr.StatusIssue																					-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt																-- Estados de la Recepcion
						when 002 then 'Recibido    '
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 002 then 'Deducido    '																		-- No esta en el inventario
		when 003 then 'Seleccionado'																		-- Esta en el inventario
		when 004 then 'Fisica Reser'																		-- Esta en el inventario
		when 005 then 'Pedido Reser'																		-- Esta en el inventario
		when 006 then 'En Pedido   '																		-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																			as [Status_EnumAx],		-- Estado de la Recepcion o Emision,		
	'3. Compras'																	as [Status_MPH],		-- Estado Mega Pharma. 
	
	itr.TransRefId																	as [TransRefId],		-- Referencia de la transaccion??
	itr.InventTransID																as [InvnentTransID],	-- Referencia de la transaccion??	
	(case when itr.ShipID <> '' then upper(itr.ShipID) else '' end)					as [ShipID],			-- Nro de Embarque??
	
	itr.DateExpected																as [DateExpected],		-- Fecha Expectativa de Bodega.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical																as [DatePhysical],		-- Fecha Fisica de la transaccion
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero

	(case when  itr.StatusReceipt = 3
		then 'Modulo Compras - Ingrese Remito o Factura'
		else ''
	 end)																			as [TxtAction],			-- Accion Sugerida	
		
	sum(itr.Qty)																	as [Qty]				-- Cantidad
  from InventTrans itr
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID and
		ib.ItemID = itr.ItemID 
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID		
  where
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se debe excluir las situaciones analizadas con anterioridad. Por lo cual las operaciones deben ser No cerradas y no deben 
	--// haber sido "Recibidas" o "Deducidas" porque estas se analizaron en el paso anterior. 
	--// Aqui se incluyen entonces, solo las que se refieran a transacciones de "Compras"
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------  
	itr.ITEMID = '1297301 ' and	
	itr.DataAreaID = @AREA and		
	itr.StatusIssue + itr.StatusReceipt != 1 and															-- Transacciones NO Cerradas
	itr.StatusIssue + itr.StatusReceipt != 2 and  															-- Transacciones NO Recibidas o Deducidas	
	itr.TransType = 3 and																					-- Solo Transacciones de "Compras"
	exists (select 1 from xls_DIM_Articulos a																-- Solo Articulos con Inventario	
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si')
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.Direction,																							-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType,																							-- Tipo de Transaccion
	itr.StatusIssue,																						-- Estado de Emision
	itr.StatusReceipt,																						-- Estado de Recepcion
	itr.TransRefId,
	itr.InventTransID,	
	(case when itr.ShipID <> '' then upper(itr.ShipID) else '' end),
	itr.DateExpected,
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad	
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical,																						-- Fecha Fisica
	ib.PdsVendBatchId																						-- Proveedor Lote Numero
  having sum(Qty) != 0

  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 04
  --// Nota: Analiza Ordenes de Produccion y Lineas de Producción
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, itr.StatusIssue, itr.StatusReceipt, Status_EnumAx, Status_MPH, 
	TransRefId, InventTransID, 
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical,PdsVendBatchId, 
	TxtAction,
	Qty
	)
  select
  	'PASO Nº 4.0'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	

	itr.Direction																	as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType																	as [TransType],			-- TransType - El enum se explica al finalizar
	itr.StatusIssue																	as [StatusIssue],		-- Estado de Emision
	itr.StatusReceipt																as [StatusReceipt],		-- Estado de Recepcion
		
	(case itr.StatusIssue																					-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt																-- Estados de la Recepcion
						when 002 then 'Recibido    '
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 002 then 'Deducido    '																		-- No esta en el inventario
		when 003 then 'Seleccionado'																		-- Esta en el inventario
		when 004 then 'Fisica Reser'																		-- Esta en el inventario
		when 005 then 'Pedido Reser'																		-- Esta en el inventario
		when 006 then 'En Pedido   '																		-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																			as [Status_EnumAx],		-- Estado de la Recepcion o Emision,		
	'4. Producción '																as [Status_MPH],		-- Estado Mega Pharma. 
	
	itr.TransRefId																	as [TransRefId],		-- Referencia de la transaccion??
	itr.InventTransID																as [InvnentTransID],	-- Referencia de la transaccion??	
	
	itr.DateExpected																as [DateExpected],		-- Fecha Expectativa de Bodega.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical																as [DatePhysical],		-- Fecha Fisica de la transaccion
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero
	
	(case
		when itr.StatusReceipt = 3 then 'Modulo Prod. - Notifique como terminada las unidades'
		else ''
	 end)																			as [TxtAction],			-- Accion Sugerida	

	sum(itr.Qty)																	as [Qty]				-- Cantidad
  from InventTrans itr																						-- Transacciones de Inventario
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID and
		ib.ItemID = itr.ItemID
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID
  where
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se debe excluir las situaciones analizadas con anterioridad. Por lo cual las operaciones deben ser No cerradas y no deben 
	--// haber sido "Recibidas" o "Deducidas" porque estas se analizaron en el paso anterior. 
	--// Aqui se incluyen entonces, solo las que se refieran a transacciones de "Produccion" sean el resultado de la OMF como los consumos para
	--// la fabricacion.
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------    
	itr.ITEMID = '1297301 ' and
	itr.DataAreaID = @AREA and		
	itr.StatusIssue + itr.StatusReceipt != 1 and															-- Transacciones NO Cerradas
	itr.StatusIssue + itr.StatusReceipt != 2 and  															-- Transacciones NO Recibidas o Deducidas	
	itr.TransType in (2,8,9,10) and																			-- Solo Transacciones de "Produccion"
	exists (select 1 from xls_DIM_Articulos a																-- Solo Articulos con Inventario	
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si')
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.Direction,																							-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType,																							-- Tipo de Transaccion
	itr.StatusIssue,																						-- Estado de Emision
	itr.StatusReceipt,																						-- Estado de Recepcion
	itr.TransRefId,
	itr.InventTransID,	
	itr.DateExpected,
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad	
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical,																						-- Fecha Fisica
	ib.PdsVendBatchId																						-- Proveedor Lote Numero
  having sum(Qty) != 0

  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 05
  --// Nota: Analiza Pedidos de Venta
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, Status_EnumAx, Status_MPH, 
	TransRefId, InventTransID,  
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical, PdsVendBatchId,
	TxtAction,
	Qty, value,
	WMSOrderRejected_MPH
	)

  select
  	'PASO Nº 5.0'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	

	itr.Direction																	as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType																	as [TransType],			-- TransType - El enum se explica al finalizar
	(case itr.StatusIssue																					-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt																-- Estados de la Recepcion
						when 002 then 'Recibido    '
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 002 then 'Deducido    '																		-- No esta en el inventario
		when 003 then 'Seleccionado'																		-- Esta en el inventario
		when 004 then 'Fisica Reser'																		-- Esta en el inventario
		when 005 then 'Pedido Reser'																		-- Esta en el inventario
		when 006 then 'En Pedido   '																		-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																			as [Status_EnumAx],		-- Estado de la Recepcion o Emision,		
	'5. Ventas'																		as [Status_MPH],		-- Estado Mega Pharma. 
	
	itr.TransRefId																	as [TransRefId],		-- Referencia de la transaccion??
	itr.InventTransID																as [InvnentTransID],	-- Referencia de la transaccion??	
	
	itr.DateExpected																as [DateExpected],		-- Fecha Expectativa de Bodega.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical																as [DatePhysical],		-- Fecha Fisica de la transaccion
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero
	
	-- Acciones Sugeridas
	(case
		when  itr.StatusIssue = 3	then 'Modulo Envios - Facturar!!!'
		when  itr.StatusReceipt = 3 then 'Modulo Clientes - Finalizar Devolución!!!'
		else ''
	 end)																			as [TxtAction],			-- Accion Sugerida

	sum(itr.Qty)																	as [Qty],				-- Cantidad
 	sum(itr.Qty * (case when sl.SalesQty = 0
 						then 0 
 						else (sl.LineAmount/sl.SalesQty)
 					end) * -1
 		)																			as [Value],				-- Valor de la linea de venta por la parte que aun queda pendiente (Se calcula como la No Venta. GN)	
	sl.WMSOrderRejected_MPH															as [WMSOrderRejected_MPH]
  from InventTrans itr																						-- Transacciones de Inventario
	left join salesLine  sl on
		sl.DataAreaID = itr.DataAreaID and
		sl.InventTransId = itr.InventTransId and
		sl.ItemID =	itr.ItemID and
		sl.SalesID = itr.TransRefId
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID and
		ib.ItemID = itr.ItemID 	
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID	
  where
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se debe excluir las situaciones analizadas con anterioridad. Por lo cual las operaciones deben ser No cerradas y no deben 
	--// haber sido "Recibidas" o "Deducidas" porque estas se analizaron en el paso anterior. 
	--// Aqui se incluyen entonces, solo las que se refieran a transacciones de "Ventas".
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------    
	itr.ITEMID = '1297301 ' and
	itr.DataAreaID = @AREA and		
	itr.StatusIssue + itr.StatusReceipt != 1 and															-- Transacciones NO Cerradas
	itr.StatusIssue + itr.StatusReceipt != 2 and  															-- Transacciones NO Recibidas o Deducidas	
	itr.TransType = 0 and																					-- Solo Transacciones de "Ventas"
	exists (select 1 from xls_DIM_Articulos a																-- Solo Articulos con Inventario	
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si')
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.Direction,																							-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType,																							-- Tipo de Transaccion
	itr.StatusIssue,																						-- Estado de Emision
	itr.StatusReceipt,																						-- Estado de Recepcion
	itr.TransRefId,
	itr.InventTransID,	
	itr.DateExpected,
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad	
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical,																						-- Fecha Fisica
	ib.PdsVendBatchId,																						-- Proveedor Lote Numero
	sl.WMSOrderRejected_MPH	
  having sum(Qty) != 0
  
  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 06
  --// Nota: Venta Proyectada segun Forecast
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, Status_EnumAx, Status_MPH, 
	TransRefId,   
	DateExpected, ItemID, InventSiteID, InventLocationId,
	CompCod, CompDes, CompTxt, 
	Qty
	)

  select
  	'PASO Nº 6.0'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	fs.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	

	2																				as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	24																				as [TransType],			-- TransType - El enum se explica al finalizar
	'Presupuesto'																	as [Status_EnumAx],		-- Estado de la Recepcion o Emision,
	'6. Ventas PSP'																	as [Status_MPH],		-- Estado Mega Pharma. 
	
	fs.ModelID																		as [TransRefId],		-- Referencia de la transaccion??  
	case fs.PROJFORECASTINVOICEDATE
	when '' then fs.STARTDATE
	else fs.PROJFORECASTINVOICEDATE end												as [DateExpected],		-- Fecha Expectativa de Bodega. Modificado CG 20161026
	--fs.StartDate																	as [DateExpected],		-- Fecha Expectativa de Bodega. Modificado CG 20161026
	it.ItemID																		as [ItemID],			-- Articulo	
	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen	
 	
	fs.CustAccountID																as [CompCod],			-- Codigo de Cliente/Proveedor con quien se toma el compromiso
	''																				as [CompDes],			-- Descripcion de Cliente/Proveeodor con quien se tomó el compromiso
	'Unidades PSP'																	as [CompTxt],			-- Informacion referencial del compromiso
 	
	fs.SalesQTY * -1 *
		dbo.fc_ConvertirUnidades(fs.DataAreaID, it.UnVtas,it.UnInve, it.ItemID) 	as [Qty]				-- Cantidad

  from forecastSales fs 
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = fs.DataAreaID and
		id.InventDimID = fs.InventDimID
	inner join XLS_DIM_Articulos it	on																		-- Recupera informacion complementaria del Articulo
		it.DataAreaID = fs.DataAreaID and
		it.ItemID = fs.ItemID and
		exists (select 1 from xls_DIM_Articulos a															-- Solo Articulos con Inventario	
				where a.DataAreaID = fs.DataAreaID and a.ItemID = it.ItemID and a.InvSN = 'Si')
  where	fs.DataAreaID = @AREA and
  		exists (select fm.SubModelID																		-- Solo los SubModelos indicado por Parametro.
				from ForecastModel fm
				where fm.DataAreaID = fs.DataAreaID and
					fm.SubModelID = fs.ModelID and
					fm.ModelID = @MODELO_PSP					
					)	and
	fs.ITEMID = '1297301 ' 					

  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 07
  --// Nota: Analiza Otro tipo de Operacones no especificadas ateriormente
  -------------------------------------------------------------------------------------------------------------------------------------------
  insert into #TEMP
  ( Step, Fecha, FechaHs, DataAreaID,
	Direction, TransType, Status_EnumAx, Status_MPH, 
	TransRefId, InventTransID, 
	DateExpected, ItemID, InventSiteID, InventLocationId,
	InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical, PdsVendBatchId,
	TxtAction,
	Qty
	)

  select
  	'PASO Nº 7.0'																	as [Step],				-- Paso para control
  	@FECHA																			as [Fecha],				-- Dia de Proceso
  	@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
	itr.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	

	itr.Direction																	as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType																	as [TransType],			-- TransType - El enum se explica al finalizar
	(case itr.StatusIssue																					-- Estados de la Emision							
		when 000 then (case itr.StatusReceipt																-- Estados de la Recepcion
						when 002 then 'Recibido    '
						when 003 then 'Registrado  '
						when 004 then 'Recepcionado'
						when 005 then 'Pedido      '
						when 006 then 'Presupuesto '
					end)
		when 002 then 'Deducido    '																		-- No esta en el inventario
		when 003 then 'Seleccionado'																		-- Esta en el inventario
		when 004 then 'Fisica Reser'																		-- Esta en el inventario
		when 005 then 'Pedido Reser'																		-- Esta en el inventario
		when 006 then 'En Pedido   '																		-- Esta en el inventario
		when 007 then 'Presupuesto '										
	 end)																			as [Status_EnumAx],		-- Estado de la Recepcion o Emision,		
	'7. Otras'																		as [Status_MPH],		-- Estado Mega Pharma. 
	
	itr.TransRefId																	as [TransRefId],		-- Referencia de la transaccion??
	itr.InventTransID																as [InvnentTransID],	-- Referencia de la transaccion??	
	
	itr.DateExpected																as [DateExpected],		-- Fecha Expectativa de Bodega.
	itr.ItemID																		as [ItemID],			-- Articulo	
 	id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 	id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
	ib.InventBatchID																as [InventBatchID],		-- Lote Nro
	ib.ExpDate																		as [ExpDate],			-- Lote Vto
-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
	case ib.PackingTradeManufacturer_MPH
		when 1 then 'MPH'
		when 2 then 'MLB'
		when 3 then 'VERDE'
		when 4 then 'NRZ'
		when 5 then 'NRZ1'
		else ''
	end																				as [MarcaEmpaque],		-- Marca del Empaque
	case ib.FinishedConsumption_MPH
		when 1 then 'SI'
		else 'NO'
	end																				as [LoteConsumido],		-- Lote Consumido
	ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
	isb.InventSubBatchId															as [InventSubBatchID],	-- Sub Lote de Calidad		
	isb.PdsDispositionCode															as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical																as [DatePhysical],		-- Fecha Fisica de la transaccion
	ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero
	-- Acciones Sugeridas
	'Modulo Diarios de Inventario - Finalizar o Eliminar Diario de ' + 
		(case JournalType
			when 0 then 'Movimiento'
			when 1 then 'Perd/Ganan'
			when 2 then 'Transferir'
			when 3 then 'LMATs'
			when 4 then 'Recuento'
			when 5 then 'Proyecto'
			when 6 then 'Recuento Etiqueta'
			when 7 then 'Activo Fijo'
			when 8 then 'Mov. Zona Franca'
		 end) + ' Nro '+	ijt.JournalID											as [TxtAction],			-- Accion Sugerida	
	
	sum(itr.Qty)																	as [Qty]				-- Cantidad
  from InventTrans itr																						-- Transacciones de Inventario
	inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
		id.DataAreaID = itr.DataAreaID and
		id.InventDimID = itr.InventDimID
	left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
		ib.DataAreaID = id.DataAreaID and
		ib.InventBatchID = id.InventBatchID and
		ib.ItemID = itr.ItemID 
	left join InventJournalTable ijt on																		-- Busca el nombre del diario
		ijt.DataAreaID = itr.DataAreaID and
		ijt.JournalID  = itr.TransRefId
	left join InventSubBatch_MPH isb on
		isb.DataAreaID = id.DataAreaID and
		isb.InventSubBatchID = id.InventSubBatchID and
		isb.InventBatchID = ib.InventBatchID and									--'<-- ACA: Relacion agregada por A.Parodi que descuadro el Inv. vs. Conta' 
		isb.ItemID = itr.ItemID		
  where
	----------------------------------------------------------------------------------------------------------------------------------------------  
	--// IMPORTANTE!! Criterio de Seleccion: 
	--// En este paso se debe excluir las situaciones analizadas con anterioridad. Por lo cual las operaciones deben ser No cerradas y no deben 
	--// haber sido "Recibidas" o "Deducidas" porque estas se analizaron en el paso anterior. 
	--// Aqui se incluyen entonces, solo las que se refieran a transacciones de "Ventas".
	--// Ademas solo se consideran los articulos que en su configuración se identifica que llevan Inventario
	----------------------------------------------------------------------------------------------------------------------------------------------    
	itr.ITEMID = '1297301 ' and
	itr.DataAreaID = @AREA and
	itr.StatusIssue + itr.StatusReceipt != 1 and															-- Transacciones NO Cerradas
	itr.StatusIssue + itr.StatusReceipt != 2 and  															-- Transacciones NO Recibidas o Deducidas	
	itr.TransType not in  (0,2,3, 8,9,10) and 																-- Otras no analizadas anteriormente
	itr.ShipID = '' and																						-- Que tenga carpeta de Importación								
	isnull(ijt.Posted,0) != 1 and   -- 2018-11-19 - RC --> Para que incluya las trns de los Ped Transf
	--ijt.Posted != 1 and																					-- Diarios no contabilizados			--<+> GN 22-01-2015 POR PANLET VISTO CON RC DIARIO CONTABILIZADO CON LINEAS PENDIENTES <->		
	exists (select 1 from xls_DIM_Articulos a																-- Solo Articulos con Inventario
			where a.DataAreaID = itr.DataAreaID and a.ItemID = itr.ItemID and a.InvSN = 'Si')
  group by
	itr.DataAreaID,																							-- Codigo de Empresa
	itr.Direction,																							-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
	itr.TransType,																							-- Tipo de Transaccion
	itr.StatusIssue,																						-- Estado de Emision
	itr.StatusReceipt,																						-- Estado de Recepcion
	itr.TransRefId,
	itr.InventTransID,	
	itr.DateExpected,
	itr.ItemID,																								-- Articulo	
 	id.InventSiteID,																						-- Dimension de Inventario. Sitio
 	id.InventLocationID,																					-- Dimension de Inventario. Almacen
	ib.InventBatchID,																						-- Lote Nro
	ib.ExpDate,																								-- Lote Vto
	ib.PackingTradeManufacturer_MPH,																		-- Marca de Empaque
	ib.FinishedConsumption_MPH,																				-- Lote Consumido
	ib.FinishedConsumptionDate_MPH,																			-- Fecha Fin Consumo
	isb.InventSubBatchId,																					-- Sub Lote de Calidad	
	isb.PdsDispositionCode,																					-- Lote Codigo de Estado de Disponibilidad
	itr.DatePhysical,																						-- Fecha Fisica
	ib.PdsVendBatchId,																						-- Proveedor Lote Numero
	ijt.JournalType,
	ijt.JournalID
  having sum(Qty) != 0

  -- Identifica los articulos que tiene al menos un compromiso de Ventas.
  update #TEMP 
  set
	CompTipo = 'Ventas'
  from #TEMP t
  where t.DataAreaID = @AREA and
	exists (select 1
			from #TEMP T1
			where t1.DataAreaID = t.DataAreaID and
				t1.ItemID = t.ItemID and
				isnull(t1.InventLocationID,'') = isnull(@ALMACEN_GESTION,isnull(t.InventLocationID,'')) and
				t1.TransType = 0
				)
 
  --// Completa con informacion de los compromisos de Ventas.
  update #TEMP 
  set
	CompCod		= isnull(st.CustAccount,'') + ' - ' + isnull(ct3.Name,''),
	CompDes		= isnull(c.PedGruDes,''),
	CompTxt		= isnull(sl.ShippingRouteID_MPH,'')+' '+isnull(sl.CustomerRef,''), 
	CompDiasVto = isnull(csd0.SellableDays, isnull(csd1.SellableDays,isnull(csd2.SellableDays,0)))			-- Tabla/Grupo/Todo
  from #TEMP t
	inner join SalesLine sl on																				-- Cruza por Linea de Venta para Ruta
		sl.DataAreaID = t.DataAreaID and
		sl.InventTransID = t.InventTransID
	left join SalesTable st on																				-- Cabecera del Pedido de Venta
		st.DataAreaID = sl.DataAreaID and
		st.SalesID = sl.SalesID
	-- Informacion complementaria del pedido
	left join XLS_DIM_Conjuntos c on
		c.DataAreaID = st.DataAreaID and
		c.SalesPoolID = st.SalesPoolID 			
	left join CustTable ct3 on																				-- Recupera los datos del Cliente Destino Final
		ct3.DataAreaID = st.DataAreaID and
		ct3.AccountNum = st.CustAccount																		--st.CustFinalDestinationAccou40002 -- Cambio GN el 05/01 para mejorar su uso		

	-- Esta parte permite recuperar los dias de ventas requeridos para la mercaderia segun configuracion Tabla/Grupo/Todo
	inner join InventTable it on
		it.DataAreaID = sl.DataAreaID and
		it.ItemID = sl.ItemID
	left join  PdsCustSellableDays csd0 on
		csd0.DataAreaID			= st.DataAreaID 
		and csd0.ITEMCODE		= 0									-- 0=Tabla, 1=Grupo, 2=Todo
		and csd0.ITEMRELATION	= sl.ItemID
		and csd0.CUSTACCOUNT	= st.CustAccount
		and csd0.INVENTDIMID	= 'AllBlank'
	left join  PdsCustSellableDays csd1 on
		csd1.DataAreaID			= st.DataAreaID 
		and csd1.ITEMCODE		= 1									-- 0=Tabla, 1=Grupo, 2=Todo
		and csd1.ITEMRELATION	= it.ItemGroupID
		and csd1.CUSTACCOUNT	= st.CustAccount
		and csd1.INVENTDIMID	= 'AllBlank'
	left join  PdsCustSellableDays csd2 on
		csd2.DataAreaID			= st.DataAreaID 
		and csd2.ITEMCODE		= 2									-- 0=Tabla, 1=Grupo, 2=Todo
		and csd2.ITEMRELATION	= ''
		and csd2.CUSTACCOUNT	= st.CustAccount
		and csd2.INVENTDIMID	= 'AllBlank'	

  where t.DataAreaID = @AREA
	and t.TransType = 0
	
  -- Analiza el % de cumplimiento de los Pedidos de Venta para sugerir su cierre si supera el 90%
  update #TEMP set
	TxtAction = 'Línea de Vta. cumplida en un ' + str(cast(round(((sl.QtyOrdered-sl.RemainInventPhysical) / sl.QtyOrdered) * 100, 2) as numeric(8,2)),10,2)+'%'
  from #TEMP t
  inner join SalesLine sl on																				-- Cruza por Linea de Venta
	sl.DataAreaID = t.DataAreaID and
	sl.InventTransID = t.InventTransID
  left join SalesTable st on																				-- Cabecera del Pedido de Venta
	st.DataAreaID = sl.DataAreaID and
	st.SalesID = sl.SalesID
  where
	t.DataAreaID = @AREA and
	t.TransType = 0 and																						-- Ventas
	t.StatusIssue + t.StatusReceipt != 1 and																-- Transacciones NO Cerradas
	t.StatusIssue + t.StatusReceipt != 2 and  																-- Transacciones NO Recibidas o Deducidas
	t.TxtAction = '' and																					-- No debe tener otra accion previa		
	sl.RemainInventPhysical != 0 and
	round(((sl.QtyOrdered-sl.RemainInventPhysical) / sl.QtyOrdered) * 100, 2) >= 90							-- Linea cumplida en un 90%

  -- Analiza el % de cumplimiento de los Pedidos de Compras para sugerir su cierre si supera el 90%
  update #TEMP set
	TxtAction = 'Línea de Compra cumplida en un ' + str(cast(round(((pl.QtyOrdered-pl.RemainInventPhysical) / pl.QtyOrdered) * 100, 2) as numeric(8,2)),10,2)+'%'
  from #TEMP t
  inner join PurchLine pl on																				-- Cruza por Linea de Compra
	pl.DataAreaID = t.DataAreaID and
	pl.InventTransID = t.InventTransID
  left join PurchTable pt on																				-- Cabecera del Pedido de Compra
	pt.DataAreaID = pl.DataAreaID and
	pt.PurchID = pl.PurchID
  where 
	t.DataAreaID = @AREA and
	t.TransType = 3 and																						-- Compras
	t.StatusIssue + t.StatusReceipt != 1 and																-- Transacciones NO Cerradas
	t.StatusIssue + t.StatusReceipt != 2 and  																-- Transacciones NO Recibidas o Deducidas
	t.TxtAction = '' and																					-- No debe tener otra accion previa		
	pl.RemainInventPhysical != 0 and
	round(((pl.QtyOrdered-pl.RemainInventPhysical) / pl.QtyOrdered) * 100, 2) >= 90							-- Linea cumplida en un 90%
	
  -- Completa informacion de las OP -- GN 28/2 - Datos de la OP. G.Crocamo.
  update #TEMP set
	CompCreadoElHs = CreatedDateTime,																		-- Compromiso Creado El.	Cuando se creo la OP	(G.Crocamo) 28/2/2015
	CompCreadoPor = CreatedBy																				-- Compromiso Creado Por.	Quien Creo la OP		(GCrocamo)	29/2/2015					
  from #TEMP t
  inner join ProdTable pt on
	pt.DataAreaID = t.DataAreaID and
	pt.ProdID = t.TransRefId
  where 
	t.DataAreaID = @AREA and
	t.TransType in (2,8,9,10) 																				-- Solo Transacciones de "Produccion" como se definio en el PASO 4

  -- Analiza el % de cumplimiento de las OMF para sugerir su cierre si supera el 90%
  update #TEMP set
	TxtAction = (case when round(((select sum(t1.Qty)
									from #TEMP T1	
									where t1.DataAreaID = t.DataAreaID and
										t1.TransRefId = t.TransRefID and
										t1.StatusIssue + t1.StatusReceipt  = 2 and							-- Disponibles																		
										t1.TransType = 2													-- Produccion
										) / pt.QtyStUp) * 100
								,2) > 90
						then 'OMF cumplida en un ' + 
								str(cast(round(((select sum(t1.Qty)
													from #TEMP t1	
													where t1.DataAreaID = t.DataAreaID and
														t1.TransRefId = t.TransRefID and
														t1.StatusIssue + t1.StatusReceipt  = 2 and			-- Disponibles
														t1.TransType = 2									-- Produccion
														
													) / pt.QtyStUp) * 100
										,2) as numeric(28,6))
									,10,2)+'%'	
						else ''
				 end)
  from #TEMP t
  inner join ProdTable pt on
	pt.DataAreaID = t.DataAreaID and
	pt.ProdID = t.TransRefId
  where 
	t.DataAreaID = @AREA and
	t.TransType = 2 and																						-- Produccion
	t.StatusReceipt != 3 and																				-- Excluye las pendientes de Notificar
	pt.QtyStUp	!= 0

  -------------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 08
  --// Nota: Agrega registros VMI
  -------------------------------------------------------------------------------------------------------------------------------------------
	IF @ConVMI = 1		-- Muestra VMI solo si se recibe parámetro en 1
	BEGIN
	  insert into #TEMP
	  ( Step, Fecha, FechaHs, DataAreaID,
		Direction, TransType, Status_EnumAx, Status_MPH, 
		TransRefId, InventTransID, 
		DateExpected, ItemID, InventSiteID, InventLocationId,
		InventBatchId, ExpDate, MarcaEmpaque, LoteConsumido, FechaFinConsumo, InventSubBatchId, PdsDispositionCode, DatePhysical, PdsVendBatchId,
		TxtAction,
		Qty
		)

	  select
  		'PASO Nº 8.0'																	as [Step],				-- Paso para control
  		@FECHA																			as [Fecha],				-- Dia de Proceso
  		@FECHAHS																		as [FechaHs],			-- Dia y Hora de Proceso 
		vmi.DataAreaID																	as [DataAreaID],		-- Codigo de Empresa	

		0																				as [Direction],			-- InventTrans. 0= Ninguno, 1 Recepcion, 2 Emision	
		999																				as [TransType],			-- TransType - El enum se explica al finalizar
		'Inv. VMI'																		as [Status_EnumAx],		-- Estado de la Recepcion o Emision,		
		'8. VMI'																		as [Status_MPH],		-- Estado Mega Pharma. 
	
		''																				as [TransRefId],		-- Referencia de la transaccion??
		''																				as [InvnentTransID],	-- Referencia de la transaccion??	
	
		''																				as [DateExpected],		-- Fecha Expectativa de Bodega.
		vmi.ItemID																		as [ItemID],			-- Articulo	
 		id.InventSiteID																	as [InventSiteID],		-- Dimension de Inventario. Sitio
 		id.InventLocationID																as [InventLocationID],	-- Dimension de Inventario. Almacen
 	
		vmi.InventBatchIDExt															as [InventBatchID],		-- Lote Nro
--MOD RC 2021-05-07 - Ticket #91618 - CORRECCION VENCIMIENTO LOTE EN PANEL INVENTARIO COMPROMISO TODOS - G.Crócamo.
		vmi.INVENTBATCHEXPDATEEXT														as [ExpDate],			-- Lote Vto						
--		ib.ExpDate																		as [ExpDate],			-- Lote Vto
--MOD RC 2021-05-07 - Ticket #91618 - CORRECCION VENCIMIENTO LOTE EN PANEL INVENTARIO COMPROMISO TODOS - G.Crócamo.
	-- 30/04/2019	SCa+	-- Se agrega Marca de Empaque
-- MOD 2021-01-11 - RC - Ampliación valores Marca de empaque- Ticket 103257 :: UY-Megalabs - ABIERTO COMO URGENTE - MARCA DE EMPAQUE - , VERDE=3, NRZ=4, NRZ1=5
		case ib.PackingTradeManufacturer_MPH
			when 1 then 'MPH'
			when 2 then 'MLB'
			when 3 then 'VERDE'
			when 4 then 'NRZ'
			when 5 then 'NRZ1'
			else ''
		end																				as [MarcaEmpaque],		-- Marca del Empaque
		case ib.FinishedConsumption_MPH
			when 1 then 'SI'
			else 'NO'
		end																				as [LoteConsumido],		-- Lote Consumido
		ib.FinishedConsumptionDate_MPH													as [FechaFinConsumo],	-- Fecha Fin Consumo
	-- 30/04/2019	SCa-	-- Se agrega Marca de Empaque
		'SubLoteVMI'																	as [InventSubBatchID],	-- Sub Lote de Calidad		
		vmi.InventBatchStatusExt														as [PdsDispositionCode],-- Lote Codigo de Estado de Disponibilidad
		getDate()																		as [DatePhysical],		-- Fecha Fisica de la transaccion
		ib.PdsVendBatchId																as [PdsVendBatchId],	-- Proveedor Lote Numero
		-- Acciones Sugeridas
		'Inventario VMI'																as [TxtAction],			-- Accion Sugerida	
		vmi.Qty																			as [Qty]				-- Cantidad
		from XLS_DIM_Seguridad s
		inner join InventVMI_MPH vmi on
			vmi.DataAreaID = s.DataAreaID
		inner join InventDim id on																				-- Apertura por las Dimensiones de Inventario
			id.DataAreaID = vmi.DataAreaID and
			id.InventDimID = vmi.InventDimID
		left join InventBatch ib on																				-- Apertura por Lote, Vencimiento y Disponibilidad.
			ib.DataAreaID = id.DataAreaID and
			ib.InventBatchID = id.InventBatchID and
			ib.ItemID = vmi.ItemID 
	END

  ----------------------------------------------------------------------------------------------------------------------------------------
  --// PASO Nº 10
  --// Nota: Muestra el resultado del proceso
  ----------------------------------------------------------------------------------------------------------------------------------------

		/*  Crear la tabla en la base DESTINO antes de ejecución de proceso.
		CREATE TABLE [dbo].[XLS_INV_CompromisosTodos](
			[Reg] [int] NOT NULL,
			[Paso] [nvarchar](20) NULL,
			[FechaHs] [datetime] NULL,
			[Area] [nvarchar](4) NULL,
			[Empresa] [nvarchar](4) NULL,
			[TrnTipo] [varchar](9) NULL,
			[TrnOrigen] [varchar](30) NOT NULL,
			[TrnEstadoAx] [nvarchar](20) NULL,
			[TrnEstadoMPH] [nvarchar](20) NULL,
			[TrnRefNro] [nvarchar](20) NULL,
			[TrnRefFecha] [datetime] NULL,
			[TrnRefAA] [varchar](4) NULL,
			[TrnRefAM] [varchar](7) NULL,
			[TrnRefMML] [varchar](20) NULL,
			[TrnRefBBMov] [smallint] NULL,
			[TrnRefTTMov] [smallint] NULL,
			[TrnDem] [int] NULL,
			[TrnDemStatus] [varchar](11) NULL,
			[ArtCod] [nvarchar](20) NULL,
			[ArtDes] [nvarchar](80) NOT NULL,
			[ArtTipo] [varchar](8) NULL,
			[ArtGrupoCod] [nvarchar](30) NOT NULL,
			[ArtGrupoDes] [nvarchar](80) NULL,
			[ArtUn] [nvarchar](30) NOT NULL,
			[ArtCarteraCod] [nvarchar](20) NOT NULL,
			[DimLinea] [nvarchar](30) NOT NULL,
			[DimLineaGru] [nvarchar](10) NOT NULL,
			[ArtSubMarcaCod] [nvarchar](30) NOT NULL,
			[PlanifGrupoCod] [nvarchar](30) NOT NULL,
			[Cobertura] [nvarchar](10) NOT NULL,
			[InvSitio] [nvarchar](10) NULL,
			[InvAlmaCod] [nvarchar](30) NOT NULL,
			[InvAlmaDes] [nvarchar](80) NOT NULL,
			[InvAlmaTipo] [varchar](10) NULL,
			[InvAlmaCtrl] [nvarchar](30) NOT NULL,
			[InvLugar] [nvarchar](10) NULL,
			[InvPallet] [nvarchar](18) NULL,
			[InvBulto] [nvarchar](20) NULL,
			[LoteNro] [nvarchar](20) NOT NULL,
			[LoteVto] [datetime] NULL,
			[LoteVtoMM] [int] NULL,
			[LoteVtoRes] [varchar](13) NOT NULL,
			[MarcaEmpaque] [nvarchar](3) NULL,
			[LoteConsumido] [nvarchar](2) NULL,
			[FechaFinConsumo] [datetime] NULL,
			[SubLoteCal] [nvarchar](20) NULL,
			[LoteNroDCod] [varchar](7) NOT NULL,
			[LoteNroDDes] [nvarchar](10) NULL,
			[CompTipo] [nvarchar](20) NULL,
			[CompCod] [nvarchar](100) NULL,
			[CompDes] [nvarchar](80) NULL,
			[CompTxt] [nvarchar](99) NULL,
			[CompDiasVto] [int] NULL,
			[CompCreadoElHs] [datetime] NULL,
			[CompCreadoEl] [datetime] NULL,
			[CompCreadoPor] [nvarchar](15) NULL,
			[Cantidad] [numeric](28, 12) NULL,
			[Valor] [numeric](28, 12) NULL,
			[AccionSN] [varchar](2) NOT NULL,
			[AccionDes] [nvarchar](99) NULL,
			[CompAlmacen] [varchar](68) NULL,
			[CantDisApto] [numeric](28, 12) NULL,
			[CantDisNoApto] [numeric](28, 12) NULL,
			[CantPrev] [numeric](28, 12) NULL,
			[CantVenta] [numeric](28, 12) NULL,
			[EnQuiebreArt] [varchar](2) NOT NULL,
			[ProveedorLoteNro] [nvarchar](100) NOT NULL,
			[ArtFcstGpoPlanificador] [nvarchar](10) NOT NULL,
			[ReferenciaCliente] [nvarchar](80) NULL,
			[OP_Tipo] [varchar](6) NOT NULL,
			[Proveedor] [nvarchar](80) NULL,
			[IdDiarioRecep] [nvarchar](10) NULL
		) ON [PRIMARY]
		GO
		--*/
/*
		DELETE FROM [192.168.201.7].[Tracking].[DBO].XLS_INV_CompromisosTodos
		WHERE [Area] = @AREA
		
		INSERT INTO [192.168.201.7].[Tracking].[DBO].XLS_INV_CompromisosTodos(Reg, Paso, FechaHs, Area, Empresa, TrnTipo, TrnOrigen, TrnEstadoAx, TrnEstadoMPH, TrnRefNro, TrnRefFecha, TrnRefAA, TrnRefAM, TrnRefMML, TrnRefBBMov, TrnRefTTMov, TrnDem, TrnDemStatus, ArtCod, ArtDes, ArtTipo, ArtGrupoCod, ArtGrupoDes, ArtUn, ArtCarteraCod, DimLinea, DimLineaGru, ArtSubMarcaCod, PlanifGrupoCod, Cobertura, InvSitio, InvAlmaCod, InvAlmaDes, InvAlmaTipo, InvAlmaCtrl, InvLugar, InvPallet, InvBulto, LoteNro, LoteVto, LoteVtoMM, LoteVtoRes, MarcaEmpaque, LoteConsumido, FechaFinConsumo, SubLoteCal, LoteNroDCod, LoteNroDDes, CompTipo, CompCod, CompDes, CompTxt, CompDiasVto, CompCreadoElHs, CompCreadoEl, CompCreadoPor, Cantidad, Valor, AccionSN, AccionDes, CompAlmacen, CantDisApto, CantDisNoApto, CantPrev, CantVenta, EnQuiebreArt, ProveedorLoteNro, ArtFcstGpoPlanificador, ReferenciaCliente, OP_Tipo, Proveedor, IdDiarioRecep)
*/

*/
  IF @Salida = 'BD'
	Begin

		select 
			(case when t.TransType = -1 then 0 else 1 end)																				as [Reg],
  			t.Step																														as [Paso],
  			@FECHAHS																	   												as [FechaHs],
  			t.DataAreaID																												as [Area],
  			t.DataAreaID																												AS [Empresa],
			(case t.Direction
				when 000 then 'Ninguno'
				when 001 then 'Recepcion'
				when 002 then 'Emision'
				end)																														as [TrnTipo],
			(case t.TransType
				when 000 then 'Ped. de Ventas'
				when 002 then 'Produccion'
				when 003 then 'Ped. de Compras'
				when 004 then 'Transaccion'
				when 005 then 'Perdidas/Ganancias'
				when 006 then 'Transferir'
				when 007 then 'Cierre de Inv. Media Ponderada'
				when 008 then 'Línea de Producción'
				when 009 then 'Linea de LMAT'
				when 010 then 'LMAT'
				when 011 then 'Pedido de Salida'
				when 012 then 'Proyectos'
				when 013 then 'Recuento'
				when 014 then 'Transporte de pallet'
				when 015 then 'Orden de Cuarentena'
				when 016 then 'DEL_Obsoleto'
				when 020 then 'Activo Fijo'
				when 021 then 'Envio de Pedido de Transf.'
				when 022 then 'Recepcion de Pedido de Transf.'
				when 023 then 'Baja de Pedido de Transf.'
				when 024 then 'Presupuesto'
				when 025 then 'Pedido de Calidad'
				when 100 then 'Produccion conjunta o derivada'
				else 'Resumen'
			end)																														as [TrnOrigen],

			-- Se consolidan los estatus para facilitar la visualizacion.  Cuando itr.StatusIssue es 0 es porque corresponde a una
			-- recepcion y viceversa. Igualmente se dejan ambos codigos para poder filtrar por codigo y evitar hacerlo por la descripcion
			-- que se ajusto para que la visualizacion sea homogenea.
			-- Estos estados son los estandar de Ax.

			-- Estado AX Estandar
			t.Status_EnumAx																												as [TrnEstadoAx],
			-- Estados MPH para facilitar la lectura.
			t.status_MPH																												as [TrnEstadoMPH],
			t.TransRefId																			 									as [TrnRefNro],
			t.DateExpected																												as [TrnRefFecha],
			f.AA																														as [TrnRefAA],
			f.AM																														as [TrnRefAM],
			f.MMSigla																													as [TrnRefMML],
			f.BBMov																														as [TrnRefBBMov],
			f.TTMov																														as [TrnRefTTMov],	

			-- Monitor de Gestion de la Bodega "Fechas de Cumplimiento" --
 			datediff(dd, t.Fecha, t.DateExpected)																						as [TrnDem],
 			(case 
 				when t.TransType = -1												then '0-Realizado' 
 				when datediff(dd, t.Fecha, t.DateExpected) > 15						then '4-Normal   '
 				when datediff(dd, t.Fecha, t.DateExpected) between 10 and 15		then '3-Atención '
 				when datediff(dd, t.Fecha, t.DateExpected) between 00 and 09		then '2-Crítico  '
 				when datediff(dd, t.Fecha, t.DateExpected) < 0						then '1-Vencido  '
 				end)																														as [TrnDemStatus],

			-- Informacion referida al Articulo	
			t.ItemID																													as [ArtCod],
			a.ArtDes																													as [ArtDes],
			a.ArtTipo																													as [ArtTipo],
			a.ArtGrupoCod																												as [ArtGrupoCod],
			a.ArtGrupoDes																												as [ArtGrupoDes],
			a.UnInve																													as [ArtUn],
			a.ArtCarteraCod																												as [ArtCarteraCod],
			a.DimLinea																													as [DimLinea],
			a.DimLineaGru																												as [DimLineaGru],
			a.ArtSubMarcaCod																											as [ArtSubMarcaCod],
			a.CompGrupoCod																												as [PlanifGrupoCod],
			a.InvCobCod																													as [Cobertura],

 			-- Dimensiones de Inventario	
 			t.InventSiteID																												as [InvSitio],
 			isnull(t.InventLocationID,'')																								as [InvAlmaCod],
 			isnull(il.Name,'')																											as [InvAlmaDes],
 			(case il.InventLocationType when 0 then 'Normal' when 1 then 'Cuarentena' when 2 then 'Transito' end)						as [InvAlmaTipo],
 			(case when isnull(CHARINDEX(t.InventLocationID, @ALMACEN_GRUPO),0) != 0
 				then isnull(t.InventLocationID,'') else ' OTROS'
 				end)																														as [InvAlmaCtrl],
 			t.wmsLocationID																												as [InvLugar],
 			t.wmsPalletID																												as [InvPallet],
 			t.InventContainerID																											as [InvBulto],
 
			-- Lote - Vencimiento
			isnull(t.InventBatchID, 'Apto')																								AS [LoteNro],
			(case when t.ExpDate is null or t.ExpDate = '19000101'
				then dateadd(dd, t.CompDiasVto, t.Fecha) else t.ExpDate
				end)																														AS [LoteVto], 	 
			datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
										then dateadd(dd, t.CompDiasVto, t.Fecha)
										else t.ExpDate 
									end)
					)																													AS [LoteVtoMM],
			(case	when datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
													then dateadd(dd, t.CompDiasVto, t.Fecha)
													else t.ExpDate 
												end)
								) >= 20																	then	'Entre 20 y  +'
					when datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
													then dateadd(dd, t.CompDiasVto, t.Fecha)
													else t.ExpDate 
												end)
								) >= 12																	then	'Entre 12 y 19'
					when datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
													then dateadd(dd, t.CompDiasVto, t.Fecha)
													else t.ExpDate 
												end)
								) >= 00																	then	'Entre 00 y 11'
					else																						' Vencido'
				end)																														AS [LoteVtoRes],
			t.MarcaEmpaque																												AS [MarcaEmpaque],
			t.LoteConsumido																												AS [LoteConsumido],
			t.FechaFinConsumo																											AS [FechaFinConsumo],
			t.InventSubBatchId																											AS [SubLoteCal],

			-- Codigo de Disponibilidad
			-- 03/09/2019 SCa+	Esto es por VMI, se condiciona el 'Apto'
			(case when t.InventSubBatchId is null or isnull(dm.Status,1) != 0	then 'Apto' else 'No Apto' end)							AS [LoteNroDCod],
			(case when isnull(dm.Status,1) = 0 then dm.DispositionCode else 'Apto' end)													AS [LoteNroDDes],
			-- 03/09/2019 SCa-	Esto es por VMI, se condiciona el 'Apto'

			-- Informacion derivada del Compromiso. 
			(case when t.CompTipo = '' then 'Otros' else t.CompTipo end)																as [CompTipo],
			t.CompCod																													as [CompCod],	
			t.CompDes																													as [CompDes],		
			t.CompTxt																													as [CompTxt],
			t.CompDiasVto																												as [CompDiasVto],
			t.CompCreadoElHs																											as [CompCreadoElHs],
			convert(datetime,  convert(varchar(10), t.CompCreadoElHs, 112))																as [CompCreadoEl],
			t.CompCreadoPor																												as [CompCreadoPor],

			-- Cantidad Comprometida. FCS anteriores pone 0 para no acumular como otros comopromiso
			(case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)							as [Cantidad],

			-- Valor Comprometida. (solo de Venta o si eventualmente el FCS tuviera valor
			(case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Value end)						as [Valor],

			-- Accion Sugerida por procesos pendientes
			(case t.TxtAction when '' then 'No' else 'Si' end)																			as [AccionSN],
  			t.TxtAction																													as [AccionDes],

			(case 
				when  isnull(t.InventLocationID,'') = @ALMACEN_GESTION  and					-- Que coincida con el Almacen pasado
						t.CompTipo = 'Ventas' and											-- Que sea de venta
						left(t.Status_MPH,1) in ('1','5') and								-- Que sea Disponible o Ventas
						(case when t.InventSubBatchId is null 
								or dm.Status != 0	then 'Apto' else 'No Apto' end) = 'Apto'	-- Que sea APTO
				then 'Gestion de Vtas. en '+ @ALMACEN_GESTION +' (Solo Prod. APTO)'
				else 'Otros'
				end)																														as [CompAlmacen],

			------------------------------------------------------------------------------------------------------------------------------	 
			-- Solo Cantidades - Campos para Analisis - Ardamdo de Plan de G. Crocamo ----------------------------------------------------
			------------------------------------------------------------------------------------------------------------------------------
			-- Cantidad Disponible
			(case when t.[Status_MPH] = '1. Disponible' and dm.Status != 0 then t.Qty else 0 end)										as [CantDisApto],
			(case when t.[Status_MPH] = '1. Disponible' and dm.Status  = 0 then t.Qty else 0 end)										as [CantDisNoApto],

			-- Cantidad Prevista
			(case t.[Status_MPH]
				when '2. En Transito'	then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '3. Compras' 		then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '4. Producción '	then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '6. Ventas PSP'	then 0
				when '7. Otras'			then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				end)																														as [CantPrev],
			-- Cantidad de Venta
			(case t.[Status_MPH]
				when '5. Ventas'		then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '6. Ventas PSP'	then 0
				end)																														as [CantVenta],

			-- Articulos en Quiebre: Se identificara como EnQuiebre? = 'Si'  ajustado por GN 15-06-22
			(case  when t.WMSOrderRejected_MPH = 1 then 'Si' else 'No' end)																as [EnQuiebreArt],
			isnull(t.PdsVendBatchId,'')																									as [ProveedorLoteNro],	-- Proveedor Lote Numero
			isnull(a.ArtFcstGpoPlanificador,'')																							as [ArtFcstGpoPlanificador],  -- Grupo Planificador
			-- 2019-01-28 - RC - Incorporar el nuevo campo referencia cliente para el caso de los Pedidos de Transferencia. 
			-- Necesidad generada por el proyecto MT. Mail de DGarcía. 
			(case t.transtype								
				when 021 then (select CUSTOMERREF from INVENTTRANSFERTABLE
								where DATAAREAID = t.DataAreaID
								and TRANSFERID = t.TransRefId)
				when 022 then (select CUSTOMERREF from INVENTTRANSFERTABLE
								where DATAAREAID = t.DataAreaID
								and TRANSFERID = t.TransRefId)
				else ''
			end)																														AS [ReferenciaCliente],
			(case 
					when a.ArtTipo		= 'LMAT'		then 'Fason'	
					when a.InvModCod	= 'FORMFACON'	then 'Fason'
					else 'Propia'
					end)																													AS [OP_Tipo],
			-- ADD 20191126 MR #71159 - Registro de proveedor en el plan de planificación
			vt.NAME																														AS Proveedor,
			-- ADD 20191126 MR #71159 - Registro de proveedor en el plan de planificación
			-- ADD+ 20200710 RC #98985 - Dificultad para identificar diarios de recepción
			isnull((select top 1 w.JOURNALID from  WMSJOURNALTRANS w 
				where t.dataareaid = w.DATAAREAID
				and t.InventTransID = w.INVENTTRANSID
				and t.TransRefId = w.INVENTTRANSREFID
				and t.Status_EnumAx = 'Registrado'
				group by w.JOURNALID), '')																								AS IdDiarioRecep
			-- ADD- 20200710 RC #98985 - Dificultad para identificar diarios de recepción
		from #TEMP t
		inner join XLS_DIM_Articulos a on													-- Valores de los Articulos
		a.DataAreaID = t.DataAreaID and
		a.ItemID = t.ItemID
		left join InventLocation il on													-- Cruce con Almacenes. Puede no tener asignado almacen.
		il.DataAreaID = t.DataAreaID and
		il.InventLocationId = t.InventLocationId
		left join PdsDispositionMaster dm on												-- Disponibilidad
		dm.DataAreaID = t.DataAreaID and
		dm.DispositionCode = t.PdsDispositionCode  
		inner join XLS_DIM_Tiempo f on
		f.Fecha = (case when t.DateExpected < t.Fecha
					then t.Fecha
					else t.DateExpected
					end)
		left join VendTable vt on
			vt.ACCOUNTNUM = a.ProvPrinCod
			and vt.DATAAREAID = a.DataAreaID
		where t.DataAreaID = @AREA
	end
  ELSE	-- 'EXCEL'
	Begin
		select
			(case when t.TransType = -1 then 0 else 1 end)																				as [Reg],
  			t.Step																														as [Paso],
  			@FECHAHS																													as [FechaHs],
  			t.DataAreaID																												as [Area],
  			t.DataAreaID																												AS [Empresa],
			(case t.Direction
				when 000 then 'Ninguno'
				when 001 then 'Recepcion'
				when 002 then 'Emision'
				end)																														as [TrnTipo],
			(case t.TransType
				when 000 then 'Ped. de Ventas'
				when 002 then 'Produccion'
				when 003 then 'Ped. de Compras'
				when 004 then 'Transaccion'
				when 005 then 'Perdidas/Ganancias'
				when 006 then 'Transferir'
				when 007 then 'Cierre de Inv. Media Ponderada'
				when 008 then 'Línea de Producción'
				when 009 then 'Linea de LMAT'
				when 010 then 'LMAT'
				when 011 then 'Pedido de Salida'
				when 012 then 'Proyectos'
				when 013 then 'Recuento'
				when 014 then 'Transporte de pallet'
				when 015 then 'Orden de Cuarentena'
				when 016 then 'DEL_Obsoleto'
				when 020 then 'Activo Fijo'
				when 021 then 'Envio de Pedido de Transf.'
				when 022 then 'Recepcion de Pedido de Transf.'
				when 023 then 'Baja de Pedido de Transf.'
				when 024 then 'Presupuesto'
				when 025 then 'Pedido de Calidad'
				when 100 then 'Produccion conjunta o derivada'
				else 'Resumen'
			end)																														as [TrnOrigen],

			-- Se consolidan los estatus para facilitar la visualizacion.  Cuando itr.StatusIssue es 0 es porque corresponde a una
			-- recepcion y viceversa. Igualmente se dejan ambos codigos para poder filtrar por codigo y evitar hacerlo por la descripcion
			-- que se ajusto para que la visualizacion sea homogenea.
			-- Estos estados son los estandar de Ax.

			-- Estado AX Estandar
			t.Status_EnumAx																												as [TrnEstadoAx],
			-- Estados MPH para facilitar la lectura.
			t.status_MPH																												as [TrnEstadoMPH],
			t.TransRefId																			 									as [TrnRefNro],
			t.DateExpected																												as [TrnRefFecha],
			f.AA																														as [TrnRefAA],
			f.AM																														as [TrnRefAM],
			f.MMSigla																													as [TrnRefMML],
			f.BBMov																														as [TrnRefBBMov],
			f.TTMov																														as [TrnRefTTMov],	

			-- Monitor de Gestion de la Bodega "Fechas de Cumplimiento" --
 			datediff(dd, t.Fecha, t.DateExpected)																						as [TrnDem],
 			(case 
 				when t.TransType = -1												then '0-Realizado' 
 				when datediff(dd, t.Fecha, t.DateExpected) > 15						then '4-Normal   '
 				when datediff(dd, t.Fecha, t.DateExpected) between 10 and 15		then '3-Atención '
 				when datediff(dd, t.Fecha, t.DateExpected) between 00 and 09		then '2-Crítico  '
 				when datediff(dd, t.Fecha, t.DateExpected) < 0						then '1-Vencido  '
 				end)																														as [TrnDemStatus],

			-- Informacion referida al Articulo	
			t.ItemID																													as [ArtCod],
			a.ArtDes																													as [ArtDes],
			a.ArtTipo																													as [ArtTipo],
			a.ArtGrupoCod																												as [ArtGrupoCod],
			a.ArtGrupoDes																												as [ArtGrupoDes],
			a.UnInve																													as [ArtUn],
			a.ArtCarteraCod																												as [ArtCarteraCod],
			a.DimLinea																													as [DimLinea],
			a.DimLineaGru																												as [DimLineaGru],
			a.ArtSubMarcaCod																											as [ArtSubMarcaCod],
			a.CompGrupoCod																												as [PlanifGrupoCod],
			a.InvCobCod																													as [Cobertura],

 			-- Dimensiones de Inventario	
 			t.InventSiteID																												as [InvSitio],
 			isnull(t.InventLocationID,'')																								as [InvAlmaCod],
 			isnull(il.Name,'')																											as [InvAlmaDes],
 			(case il.InventLocationType when 0 then 'Normal' when 1 then 'Cuarentena' when 2 then 'Transito' end)						as [InvAlmaTipo],
 			(case when isnull(CHARINDEX(t.InventLocationID, @ALMACEN_GRUPO),0) != 0
 				then isnull(t.InventLocationID,'') else ' OTROS'
 				end)																														as [InvAlmaCtrl],
 			t.wmsLocationID																												as [InvLugar],
 			t.wmsPalletID																												as [InvPallet],
 			t.InventContainerID																											as [InvBulto],
 
			-- Lote - Vencimiento
			isnull(t.InventBatchID, 'Apto')																								AS [LoteNro],
			(case when t.ExpDate is null or t.ExpDate = '19000101'
				then dateadd(dd, t.CompDiasVto, t.Fecha) else t.ExpDate
				end)																														AS [LoteVto], 	 
			datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
										then dateadd(dd, t.CompDiasVto, t.Fecha)
										else t.ExpDate 
									end)
					)																													AS [LoteVtoMM],
			(case	when datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
													then dateadd(dd, t.CompDiasVto, t.Fecha)
													else t.ExpDate 
												end)
								) >= 20																	then	'Entre 20 y  +'
					when datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
													then dateadd(dd, t.CompDiasVto, t.Fecha)
													else t.ExpDate 
												end)
								) >= 12																	then	'Entre 12 y 19'
					when datediff(mm, t.Fecha, (case when t.ExpDate is null or t.ExpDate = '19000101'
													then dateadd(dd, t.CompDiasVto, t.Fecha)
													else t.ExpDate 
												end)
								) >= 00																	then	'Entre 00 y 11'
					else																						' Vencido'
				end)																														AS [LoteVtoRes],
			t.MarcaEmpaque																												AS [MarcaEmpaque],
			t.LoteConsumido																												AS [LoteConsumido],
			t.FechaFinConsumo																											AS [FechaFinConsumo],
			t.InventSubBatchId																											AS [SubLoteCal],

			-- Codigo de Disponibilidad
			-- 03/09/2019 SCa+	Esto es por VMI, se condiciona el 'Apto'
			(case when t.InventSubBatchId is null or isnull(dm.Status,1) != 0	then 'Apto' else 'No Apto' end)							AS [LoteNroDCod],
			(case when isnull(dm.Status,1) = 0 then dm.DispositionCode else 'Apto' end)													AS [LoteNroDDes],
			-- 03/09/2019 SCa-	Esto es por VMI, se condiciona el 'Apto'

			-- Informacion derivada del Compromiso. 
			(case when t.CompTipo = '' then 'Otros' else t.CompTipo end)																as [CompTipo],
			t.CompCod																													as [CompCod],	
			t.CompDes																													as [CompDes],		
			t.CompTxt																													as [CompTxt],
			t.CompDiasVto																												as [CompDiasVto],
			t.CompCreadoElHs																											as [CompCreadoElHs],
			convert(datetime,  convert(varchar(10), t.CompCreadoElHs, 112))																as [CompCreadoEl],
			t.CompCreadoPor																												as [CompCreadoPor],

			-- Cantidad Comprometida. FCS anteriores pone 0 para no acumular como otros comopromiso
			(case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)							as [Cantidad],

			-- Valor Comprometida. (solo de Venta o si eventualmente el FCS tuviera valor
			(case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Value end)						as [Valor],

			-- Accion Sugerida por procesos pendientes
			(case t.TxtAction when '' then 'No' else 'Si' end)																			as [AccionSN],
  			t.TxtAction																													as [AccionDes],

			(case 
				when  isnull(t.InventLocationID,'') = @ALMACEN_GESTION  and					-- Que coincida con el Almacen pasado
						t.CompTipo = 'Ventas' and											-- Que sea de venta
						left(t.Status_MPH,1) in ('1','5') and								-- Que sea Disponible o Ventas
						(case when t.InventSubBatchId is null 
								or dm.Status != 0	then 'Apto' else 'No Apto' end) = 'Apto'	-- Que sea APTO
				then 'Gestion de Vtas. en '+ @ALMACEN_GESTION +' (Solo Prod. APTO)'
				else 'Otros'
				end)																														as [CompAlmacen],

			------------------------------------------------------------------------------------------------------------------------------	 
			-- Solo Cantidades - Campos para Analisis - Ardamdo de Plan de G. Crocamo ----------------------------------------------------
			------------------------------------------------------------------------------------------------------------------------------
			-- Cantidad Disponible
			(case when t.[Status_MPH] = '1. Disponible' and dm.Status != 0 then t.Qty else 0 end)										as [CantDisApto],
			(case when t.[Status_MPH] = '1. Disponible' and dm.Status  = 0 then t.Qty else 0 end)										as [CantDisNoApto],

			-- Cantidad Prevista
			(case t.[Status_MPH]
				when '2. En Transito'	then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '3. Compras' 		then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '4. Producción '	then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '6. Ventas PSP'	then 0
				when '7. Otras'			then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				end)																														as [CantPrev],
			-- Cantidad de Venta
			(case t.[Status_MPH]
				when '5. Ventas'		then (case when t.[Status_MPH] = '6. Ventas PSP' and t.DateExpected < @FECHA_INI then 0  else t.Qty end)
				when '6. Ventas PSP'	then 0
				end)																														as [CantVenta],

			-- Articulos en Quiebre: Se identificara como EnQuiebre? = 'Si'  ajustado por GN 15-06-22
			(case  when t.WMSOrderRejected_MPH = 1 then 'Si' else 'No' end)																as [EnQuiebreArt],
			isnull(t.PdsVendBatchId,'')																									as [ProveedorLoteNro],	-- Proveedor Lote Numero
			isnull(a.ArtFcstGpoPlanificador,'')																							as [ArtFcstGpoPlanificador],  -- Grupo Planificador
			-- 2019-01-28 - RC - Incorporar el nuevo campo referencia cliente para el caso de los Pedidos de Transferencia. 
			-- Necesidad generada por el proyecto MT. Mail de DGarcía. 
			(case t.transtype								
				when 021 then (select CUSTOMERREF from INVENTTRANSFERTABLE
								where DATAAREAID = t.DataAreaID
								and TRANSFERID = t.TransRefId)
				when 022 then (select CUSTOMERREF from INVENTTRANSFERTABLE
								where DATAAREAID = t.DataAreaID
								and TRANSFERID = t.TransRefId)
				else ''
			end)																														AS [ReferenciaCliente],
			(case 
					when a.ArtTipo		= 'LMAT'		then 'Fason'	
					when a.InvModCod	= 'FORMFACON'	then 'Fason'
					else 'Propia'
					end)																													AS [OP_Tipo],
			-- ADD 20191126 MR #71159 - Registro de proveedor en el plan de planificación
			vt.NAME																														AS Proveedor,
			-- ADD 20191126 MR #71159 - Registro de proveedor en el plan de planificación
			-- ADD+ 20200710 RC #98985 - Dificultad para identificar diarios de recepción
			isnull((select top 1 w.JOURNALID from  WMSJOURNALTRANS w 
				where t.dataareaid = w.DATAAREAID
				and t.InventTransID = w.INVENTTRANSID
				and t.TransRefId = w.INVENTTRANSREFID
				and t.Status_EnumAx = 'Registrado'
				group by w.JOURNALID), '')																								AS IdDiarioRecep
		from #TEMP t
		inner join XLS_DIM_Articulos a on													-- Valores de los Articulos
		a.DataAreaID = t.DataAreaID and
		a.ItemID = t.ItemID
		left join InventLocation il on													-- Cruce con Almacenes. Puede no tener asignado almacen.
		il.DataAreaID = t.DataAreaID and
		il.InventLocationId = t.InventLocationId
		left join PdsDispositionMaster dm on												-- Disponibilidad
		dm.DataAreaID = t.DataAreaID and
		dm.DispositionCode = t.PdsDispositionCode  
		inner join XLS_DIM_Tiempo f on
		f.Fecha = (case when t.DateExpected < t.Fecha
					then t.Fecha
					else t.DateExpected
					end)
		left join VendTable vt on
			vt.ACCOUNTNUM = a.ProvPrinCod
			and vt.DATAAREAID = a.DataAreaID
		where t.DataAreaID = @AREA
	end

	