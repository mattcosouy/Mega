
declare
 @AREA			varchar(04) = '080',											-- Empresa de Ejecución
 @TOPEMES		smallint		= null,									-- Meses previos a cerrar. Siempre incluye el mes actual. (opcional)
 @TIPOACCION	nvarchar(10)	= null									-- A=Actualiza, M=Muestra

   set @TOPEMES		= abs(isnull(@TOPEMES, 0))
  set @TIPOACCION	= isnull(@TIPOACCION, 'AM')

  	  declare @FECHAHS	datetime set @FECHAHS	=  convert(date,'2021-05-31')
	  declare @FECHA	datetime set @FECHA		= convert(datetime, convert(varchar(10), @FECHAHS, 112))
  
	  -- Esta consulta muestra el stock a una fecha. Iterará calculando el stock a fin de mes para los ultimos 3 meses --
	  declare @ITERAMES smallint set @ITERAMES = 0
    
		  select
			'Inventario',													-- Reporte Categoria
			'Inventario Físico',											-- Reporte Descripcion
			'PASO Nº 01/01',												-- Paso para control en caso de diferencias	  
			@FECHA,
			insu.DataAreaID,												-- Requerido en SQL
			insu.ItemId,													-- Especifico en Ax
			'',																-- Contenido en #InventDimFields
			indi.InventLocationId,											-- Contenido en #InventDimFields
			indi.InventBatchId,												-- Contenido en #InventDimFields
			'',
			indi.InventSerialId, 											-- Contenido en #InventDimFields
			indi.ConfigId, 													-- Contenido en #InventDimFields
			indi.InventSizeId,												-- Contenido en #InventDimFields
			indi.InventColorId, 											-- Contenido en #InventDimFields
			indi.WMSLocationId,												-- Contenido en #InventDimFields
			indi.WMSPalletId,												-- Contenido en #InventDimFields
			'',																-- Contenido en #InventDimFields
			'',																-- Contenido en #InventDimFields
			indi.InventDimId,												-- Contenido en #InventDimFields
			1,																-- Enum InventSumDateType::Base (0=Adjustment, 1=Base, 2=Final)
			sum(insu.PostedQty),											-- Especifico en Ax 
			sum(insu.Received),												-- Especifico en Ax 
			sum(insu.Deducted),												-- Especifico en Ax 
			sum(insu.Picked),												-- Especifico en Ax 
			sum(insu.Registered),											-- Especifico en Ax 
			sum(insu.PostedValue)											-- Especifico en Ax	
		  from InventSum insu
			inner join InventDim indi on
				indi.DataAreaID = insu.DataAreaID and
				indi.InventDimID = insu.InventDimID
		  where insu.DataAReaID = @AREA 
			and insu.Closed = 0 and insu.itemid = '26085' and INVENTLOCATIONID = 'CuPT' 
		  group by 
			insu.DataAreaID,
			insu.ItemId,
			indi.InventLocationId,
			indi.InventBatchId,
			indi.InventSerialId,
			indi.ConfigId, 
			indi.InventSizeId, 
			indi.InventColorId, 
			indi.WMSLocationId, 
			indi.WMSPalletId, 
			indi.InventDimId
			having sum(insu.PostedQty) > 0


 select *  from XLS_DIM_InventarioHastFechaCAIC_AX4 
 where ArtCod =  '26085' and INVENTLOCATIONID = 'CuPT' 