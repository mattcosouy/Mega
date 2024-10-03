

select transchildtype, transchildrefid, *  
begin tran
update
 inventtrans
 set transchildtype = 0, transchildrefid = ''
where dataareaid = '100'
and recid = 5640012887
--commit

--  transchildtype = 2, transchildrefid = '084_02700642'