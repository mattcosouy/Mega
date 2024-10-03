select distinct calcfecha as [CalculoCierreAx365], fechaproceso as [FechaCalculoAx365], fechasync as [SyncAx365-Az / Ax9-PBI],  DataAreaID , COUNT(*), SUM(Disponible) from PBI_InventFisicoeLog 
  where calcfecha >= '2024-01-01'
	--and ArtCod = '004-001-005' 
  group by calcfecha, fechaproceso, fechasync,  DataAreaID
  order by DataAreaID, CalcFecha