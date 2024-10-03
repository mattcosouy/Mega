
--1. Respaldo la tabla
drop table _mph_costSecondaryTrans_upd048
select * 
into _mph_costSecondaryTrans_upd048
from mph_costSecondaryTrans
where DATAAREAID = '048'
and CostAmountCostSec = 0
and TransDate = '2021-09-30'

--2. Update según se necesita
/*
--commit
begin tran
update mph_costSecondaryTrans
set CostAmountStd = 0.01, DocumentAmountCostSec = 0.01, CostAmountCostSec = 0.01, TotalCostAmountCostSec = 0.01,
PriceUnitCostValue = round( (0.01 / TotalQtyCostSec), 4), PriceUnitCostSec = round( (0.01 / TotalQtyCostSec), 4)
where DATAAREAID = '048'
and CostAmountCostSec = 0
and TransDate = '2021-09-30'
*/  
-- MPA5004
--------------------------------------------------------------------------------------------------
-- Luego de aplicado el script, ejecutar en Ax en la empresa, el JOB: MPH_Regenerate_Definitive --
--------------------------------------------------------------------------------------------------