-- operadores con mi email
select id, name, enabled, email_address
from msdb..sysoperators
where (email_address like '%mrobinson%' or email_address like '%OperacionesAX%')

-- operadores habilitados SIN mi email
select id, name, enabled, email_address
from msdb..sysoperators
where enabled=0
and (email_address like '%mrobinson%' or email_address like '%OperacionesAX%')


select top 1000 
	j.name	JobName
	,j.enabled	JobEnabled
	,o.id	OperatorId
	,o.name	OperatorName
	,o.enabled	OperatorEnabled
	,o.email_address	OperatorEmail
from msdb..sysjobs j
inner join msdb..sysoperators o
	on j.notify_email_operator_id = o.id
where 
j.notify_email_operator_id > 0 -- q notifique a 1 operador via email
and j.enabled=1 -- true
--and o.email_address like '%mrobinson%'
