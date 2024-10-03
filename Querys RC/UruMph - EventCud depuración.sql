select CUDTABLEID ,count(*) from eventcud 
where companyid = '120' and status = 1 --and userid = 'usren'
group by CUDTABLEID 
order by CUDTABLEID 
--rollback
--commit
--begin tran
delete eventcud 
--select * from eventcud
where companyid = '120'
and status = 1
and CUDTABLEID = 177
and userid = 'ffont'
and CREATEDDATETIME between '2021-07-01 01:00:00.000' and '2021-07-20 23:59:22.000'
--convert(date,CREATEDDATETIME) = '

/*
sp_who2
select userid, count(*) 
from eventcud 
where companyid = '120' and status = 1
group by USERID
order by USERID
/*
--23275595
*/
