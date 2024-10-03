
  declare @AREA			nvarchar(04) set @AREA		= '120'
  declare @MESATRAS		smallint	 set @MESATRAS	= 1
--  declare @FORMATO		nvarchar(30) set @FORMATO	= 'Gestion'			-- Ver opciones en la declaracion del SP
  declare @ALMACENEXP		nvarchar(30)	= 'Ninguna'								-- Almacen de Productos de Exportacion
  declare @UBICACIONEXP		nvarchar(10)	= 'SinUso'									-- Ubicacion de Productos de Exportacion
  declare @ARTICULOS	nvarchar(99) set @ARTICULOS	= null	
  declare @EsTrade		varchar(1)	= null											-- 0=No es Trade	1=Es Trade
  --*/
    
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
  set @ALMACENEXP = (case when ISNULL(@ALMACENEXP,'Ninguna') <> '' then ISNULL(@ALMACENEXP,'Ninguna') else 'Ninguna' end)
  set @UBICACIONEXP = (case when ISNULL(@UBICACIONEXP,'SinUso') <> '' then ISNULL(@UBICACIONEXP,'SinUso') else 'SinUso' end)
   declare @CURRENCYCODE				nvarchar(05) set @CURRENCYCODE			= (select CurrencyCode			from XLS_DIM_Seguridad where DataAreaID = @AREA) 
  declare @CORPORATECURRENCYCODE	nvarchar(05) set @CORPORATECURRENCYCODE = (select CorporateCurrencyCode	from XLS_DIM_Seguridad where DataAreaID = @AREA)
  declare @COMPANYNAME				nvarchar(30) set @COMPANYNAME			= (select CompanyName			from XLS_DIM_Seguridad where DataAreaID = @AREA)
  --20/09/2018 SCa - Se sustituye por @xIdBase
  --declare @IDBASE					nvarchar(30) set @IDBASE				= (select IdBase				from XLS_DIM_Seguridad where DataAreaID = @AREA)
  declare @DECCHAR					nvarchar(01) set @DECCHAR				= (select DecChar				from XLS_DIM_Seguridad where DataAreaID = @AREA) 

/* Resolución Ticket #110191 - CARGA DE INVENTARIO EN TRADE - ERROR DE ASIGNACIÓN DE DESTINO - GPeyrous
-- Crear nuevo campo "Destino" que contendrá el valor ACCEAM si el destino de la mercadería es CentroAmérica
--		ALTER TABLE XLS_DIM_Inventario ADD Destino Varchar(10) DEFAULT ''

--Lógica para llenar el nuevo campo Destino.
		update XLS_DIM_Inventario 
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
		and id.INVENTLOCATIONID = 'MEGAPAN-01'
*/
select
   t.Destino ,
  			t.DataAreaID																										AS [AreaCod],  
			--@COMPANYNAME																										AS [AreaDes],
			t.Reporte_CatDes																									AS [RPT_CatDes],
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
			t.InventSiteID																										AS [SitioCod], --// Agregó GN x solicitud de JZ/RA para gestion Roemmers por Muestras de Retencion.			
			t.InventLocationID																									AS [AlmCod],
			t.InventBatchId																										AS [LoteNro],
			t.LoteVto																											AS [LoteVto],
			t.InventSubBatchID																									AS [SubLoteNro],

			--// Cantidadades expresadas en la unidad de inventario, Valores en moneda local y moneda corp.
			dbo.fc_ENUM_ProdWipType_NA(t.Wip_Tipo)																				AS [Val_Tipo],
			sum(t.PhysicalQty)																									AS [Cantidad],
			sum(t.PhysicalValue)																								AS [ValMonLoc],
			 (case when t.Wip_Tipo != 0
				then sum(t.PhysicalValue / (tc.TC_Val / 100))																	-- 20160810 CG - Cambio a División visto con GN
				--then sum(dbo.fc_Cambio(t.PhysicalValue, @FECHA_FIN, @CURRENCYCODE, @CORPORATECURRENCYCODE, @AREA))			-- noceda
				else sum(t.PhysicalQty * dbo.fc_CostoUnitario (@AREA, t.ItemID, @FECHA_FIN, 'MonCorp', 4))
			 end)																												AS [ValRepo],
			 case when t.Destino = 'MEGAPAN-01'
			 then 'ACCEAM'
			 else ''									
			 end																											as Destino
		from XLS_DIM_Inventario t													-- Esquema de Seguridad
			-- NOTA: No agregar la tabla #TABLA_ARTICULO porque la opcion de Gestion requiere los Gastos Indirectos de OP sin 
			-- finalizar y los consumos de recursos de OP sin finalizar. 
			-- Luego de los ajustes que se hicieron con Rosario Ojeda, surgio esto porque pase de left join XLS_DIM_Articulos 
			-- a inner haciendo que esa informacion se perdiera.  Cualquier cosa consultar con GN/PP que fue quien recibio
			-- el reclamo de Alvaro Martinez. 
			left join XLS_DIM_Articulos a on										-- Valores de los Articulos
				a.DataAreaID = t.DataAreaID and
				a.ItemID = t.ItemID
			left join InventBatch inb on											-- Apertura por Lote, Vencimiento 
				inb.DataAreaID = t.DataAreaID and
				inb.InventBatchID = t.InventBatchID and
				inb.ItemID = t.ItemID		
			left join XLS_DIM_Tiempo dt on											-- Formatos de Fecha
				dt.Fecha = @FECHA_FIN
			left join XLS_DIM_Cambio tc on											-- Utilice en el calculo --> (tc.TC_Val/100)		Multiplicar para llevar MonOper a MonLoc --> TC_MonCur_MonLoc
				tc.DataAreaID = @AREA and
				tc.Fecha  =  @FECHA_FIN and
				tc.MonLoc =  @CURRENCYCODE and										-- Moneda Local de la empresa
				tc.TC_Mon =  @CORPORATECURRENCYCODE									-- Moneda de la Operacion	
		where t.DataAreaID = @AREA and 
		t.destino is not null and
			t.Fecha <= @FECHA_FIN and												-- Consolida toda la información, desde el saldo a fin de mes solicitado
			round(t.PhysicalQty,2) + round(t.PhysicalValue,2) != 0					-- Se evitan linea sin unidades ni valores
		group by
  			t.DataAreaID,
			t.Reporte_CatDes,
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
			t.InventSiteID,
			t.InventLocationID,
			t.InventBatchId,
			t.LoteVto,
			t.InventSubBatchID,
			dbo.fc_ENUM_ProdWipType_NA(t.Wip_Tipo),
			t.Wip_Tipo,
			t.Destino
		having sum(t.PhysicalQty)+ sum(t.PhysicalValue) != 0
/*  	  
select * from XLS_DIM_Inventario x
 where x.dataareaid = '120'
 --and  x.InventLocationId = 'TRANSITO'
and x.Destino = 'MEGAPAN-01'
and round(x.PhysicalQty,2) + round(x.PhysicalValue,2) != 0
*/