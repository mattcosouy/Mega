

select * from eventrule e
left join EVENTRULEDATA ed
on e.DATAAREAID = ed.DATAAREAID 
and e.RULEID = ed.RULEID
left join EVENTRULEFIELD ef
on e.DATAAREAID = ef.DATAAREAID 
and e.RULEID = ef.RULEID
left join EVENTRULEREL er
on e.DATAAREAID = er.DATAAREAID 
and e.RULEID = er.RULEID
left join EVENTRULERELDATA erd
on e.DATAAREAID = erd.DATAAREAID 
and e.RULEID = erd.RULERELID
