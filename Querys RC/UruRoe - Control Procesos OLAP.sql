--sp_who2

--select * from   XLS_DIM_ProcesoCentralOLAP
select ProCod, prodes, profecha, round(sum(prodemora/60),2) from XLS_DIM_ProcesoCentralOLAP
where dataareaid = '010'
and year(Profecha) = 2021
--and MONTH(profecha) = 02
--and DAY(Profecha) = 04
--and SUBSTRING(prodes,1,3) = '080'
group by procod, prodes, profecha
--order by profechaini --desc