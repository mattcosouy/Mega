

-- Automatismo de Sincronía
select * from XLS_EDI_DiariosDeMovimiento 
where DataAreaID = '125'
and RefExtID in ('086_395121','OPL_00012798','OP_00017319')

--select SENTTOOWNER_MPH, * from INVENTJOURNALTABLE 
--commit
begin tran
update INVENTJOURNALTABLE 
set SENTTOOWNER_MPH = 0
where DataAreaID = '125'
and JOURNALID in ('086_087145','086_091050','086_091535')

select * from WMSJOURNALTABLE
where DataAreaID = '125'
and JOURNALID in ('137_015402','137_015866','137_015919')



-- # de Arte
select * from bom
--commit
--begin tran
--update  bom
--set  PDSINHERITENDITEMBATCHATT40004 = 1
where DATAAREAID = '120' 
and bomid = 'For_A05132'
and itemid = 'EST745003'

