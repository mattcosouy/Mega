
select PMFYIELDPCT, * from reqpo
where dataareaid = '050'
and reqplanid = 'Plan maest'
and itembomid in ('FOR_A02559','FOR_A02560')

select PMFYIELDPCT, * from bomversion
where dataareaid = '050'
and PMFYIELDPCT = 0
and bomid in ('FOR_A02559','FOR_A02560')
/*
--commit
begin tran 
update bomversion 
set PMFYIELDPCT = 100
where dataareaid = '050'
and PMFYIELDPCT = 0
and itembomid in ('FOR_A02559','FOR_A02560')
*/


