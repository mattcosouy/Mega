*********************************************************************************************************************************
USE [AxChiPhiOLAP]
GO

/****** Object:  StoredProcedure [dbo].[SP_Auditoria_PBI_count]    Script Date: 25/10/2023 9:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Germán olate>
-- Create date: <29/09/2022>
-- Description:	<Inserta >
-- =============================================
ALTER PROCEDURE [dbo].[SP_Auditoria_PBI_count]
	
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------------------------------------------------------------
 --or no truncar con Log diario ??????
truncate table  [AxChiPhiOLAP].[dbo].[Auditoria_PBI_count] 

DECLARE @query varchar(500)
DECLARE @tabla varchar(500)
DECLARE @resultado INT

--****Cursor
DECLARE @Description AS nvarchar(400)
DECLARE ProdInfo CURSOR FOR 

SELECT concat ('select (',concat('select count(1) ', 'FROM [AxChiPhiOLAP].[dbo].', SO.NAME ),')', ' - (', concat('select count(1) ', 'FROM [azure olap].[AxChiPhiOLAP].[dbo].', SO.NAME ), ')' ) as resultado
			FROM sys.objects SO INNER JOIN sys.columns SC ON SO.OBJECT_ID = SC.OBJECT_ID
			WHERE SO.TYPE = 'U'
			and  SO.NAME like '%PBI_%'
			--********* que tengan el campo fechasync
			and SC.NAME = 'fechasync'
			--******PBI que no estan en Azure Olap
			and  SO.NAME not in ('PBI_DeudaFinMesAnteriores','PBI_eLog_Articulos', 'PBI_eLog_Compras', 'PBI_eLog_CostoReposicion','PBI_eLog_Inventario'
			,'PBI_eLog_Ventas', 'PBI_Indice_Tracking','PBI_VentaFacturadaTodo_agregaDocumentosManuales', 'PBI_VentaFacturadaTodo_delete'
			--*** generó error 7/10/2022 golate
		
		--** golate eliminadas 26/10/2022
		--	, 'PBI_InventarioIngresado0610', 'PBI_VentaFacturadaTodoOLD_eliminar',--	,'PBI_ComprasFacturas0610' eliminada
			
			)
						
			----FechaSyncAxCorp PBI_CliProvExternos, cambiada
			--and  SO.NAME not in ('PBI_CliProvExternos')

			--******PBI propias
			and  SO.NAME not in('PBI_TIEMPO_FIJA')

          ORDER BY SO.NAME

OPEN ProdInfo
FETCH NEXT FROM ProdInfo INTO @Description
WHILE @@fetch_status = 0

BEGIN
 SET @query= @Description
 Set @tabla = (select substring(@query,85, 150))

set @tabla =  (select (SUBSTRING(@tabla
						, charindex('].P',@tabla)+1, 
						len(@tabla)-CHARINDEX('].P', @tabla))))

set @tabla = (select replace(@tabla,')', ''))
set @tabla = (select replace(@tabla,'.', ''))

   --TABLA TEMPORAL CON UNA COLUMNA
DECLARE @t TABLE (resultado VARCHAR(MAX) )
INSERT INTO @t  exec (@query)
SELECT @resultado=resultado FROM @t


INSERT INTO [AxChiPhiOLAP].[dbo].[Auditoria_PBI_count]   ([Query]   ,[Tabla]  ,[Resultado]  ,[Fecha])
select @query, @tabla,  @resultado, getdate()
 -- print @query
  FETCH NEXT FROM ProdInfo INTO @Description

END
CLOSE ProdInfo
DEALLOCATE ProdInfo

End

			
GO
*********************************************************************************************************************************

USE [AxChiPhiOLAP]
GO

/****** Object:  StoredProcedure [dbo].[SP_Auditoria_PBI_Sync]    Script Date: 25/10/2023 9:32:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Germán olate>
-- Create date: <29/09/2022>
-- Description:	<Inserta >
-- =============================================
ALTER PROCEDURE  [dbo].[SP_Auditoria_PBI_Sync]
	
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------------------------------------------------------------
truncate table  [AxChiPhiOLAP].[dbo].[Auditoria_PBI_Sync] 

DECLARE @query varchar(500)
DECLARE @tabla varchar(500)
DECLARE @resultado INT

--****Cursor
DECLARE @Description AS nvarchar(400)
DECLARE ProdInfo CURSOR FOR 

			SELECT  concat ('select datediff(day, (',concat('select max(cast(fechasync as date)) ', 'FROM [AxChiPhiOLAP].[dbo].',  SO.NAME ),')', ' , (', concat('select max(cast(fechasync as date)) ', 'FROM [azure olap].[AxChiPhiOLAP].[dbo].',  SO.NAME ), '))' ) as resultado
			FROM sys.objects SO INNER JOIN sys.columns SC ON SO.OBJECT_ID = SC.OBJECT_ID
			WHERE SO.TYPE = 'U'
			and  SO.NAME like '%PBI_%'
			--********* que tengan el campo fechasync
			and SC.NAME = 'fechasync'
			--******PBI que no estan en Azure Olap
			and  SO.NAME not in ('PBI_DeudaFinMesAnteriores','PBI_eLog_Articulos', 'PBI_eLog_Compras', 'PBI_eLog_CostoReposicion','PBI_eLog_Inventario','PBI_eLog_Ventas', 'PBI_Indice_Tracking','PBI_VentaFacturadaTodo_agregaDocumentosManuales'
			,'PBI_VentaFacturadaTodo_delete'
	
			--error 7/10/2022 golate
			--eliminadas 26/10/2022 golate
		--	,'PBI_ComprasFacturas0610','PBI_InventarioIngresado0610', 'PBI_VentaFacturadaTodoOLD_eliminar'
			)
						
			----FechaSyncAxCorp PBI_CliProvExternos, cambiada
			--and  SO.NAME not in ('PBI_CliProvExternos')

			--******PBI propias
			and  SO.NAME not in('PBI_TIEMPO_FIJA')
			ORDER BY SO.NAME
OPEN ProdInfo
FETCH NEXT FROM ProdInfo INTO @Description
WHILE @@fetch_status = 0

BEGIN
 SET @query= @Description
 Set @tabla = (select substring(@query,85, 150))

set @tabla =  (select (SUBSTRING(@tabla
						, charindex('].P',@tabla)+1, 
						len(@tabla)-CHARINDEX('].P', @tabla))))

set @tabla = (select replace(@tabla,'))', ''))
set @tabla = (select replace(@tabla,'.', ''))

   --TABLA TEMPORAL CON UNA COLUMNA
DECLARE @t TABLE (resultado VARCHAR(MAX) )
INSERT INTO @t  exec (@query)
SELECT @resultado=resultado FROM @t

--select datediff(day, (select max(cast(fechasync as date)) FROM [AxChiPhiOLAP].[dbo].PBI_Almacenes) , (select max(cast(fechasync as date)) FROM [azure olap].[AxChiPhiOLAP].[dbo].PBI_Almacenes))

INSERT INTO [AxChiPhiOLAP].[dbo].[Auditoria_PBI_Sync]   ([Query]   ,[Tabla]  ,[Resultado]  ,[Fecha])
select @query, @tabla,  @resultado, getdate()
 -- print @query
  FETCH NEXT FROM ProdInfo INTO @Description

END
CLOSE ProdInfo
DEALLOCATE ProdInfo

END
GO


