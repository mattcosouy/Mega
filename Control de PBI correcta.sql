select  FechaSync , isnull(AZURE,0) as AZURE, isnull(LOCAL,0) as LOCAL , isnull(LOCAL,0)-isnull(AZURE,0) as '+ = local con mas registros' from 
(select 'LOCAL' as Origen , count(FechaSync) as con, FechaSync from [dbo].[PBI_ComprasFacturas] group by FechaSync 
union
select 'AZURE' as Origen , count(FechaSync) as con, FechaSync from [AZURE OLAP].AxDomRowolap.dbo.PBI_ComprasFacturas group by FechaSync ) p
pivot (sum(con) for [Origen] in ([AZURE] , [LOCAL]) ) as tblpiv
where (isnull(LOCAL,0)-isnull(AZURE,0))!=0
order by FechaSync desc 


--Controla que la PBI seleccionada antes de ejecutar el query, este correcta la última fecha de sincronización y a su vez compara cantidad de registros
--Azure vs OnPrem