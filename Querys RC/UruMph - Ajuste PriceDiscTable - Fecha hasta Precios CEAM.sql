
select * from PRICEDISCTABLE p
where p.DATAAREAID = 120
--and FROMDATE = '2022-06-'
and TODATE in ('1900-01-01' , '2022-06-30')

/*
begin tran
update PRICEDISCTABLE
set TODATE = '2020-06-30'
where recid in 
(
select recid from PRICEDISCTABLE p 
	where p.DATAAREAID = 120
	and FROMDATE = '2019-11-01'
	and TODATE = '1900-01-01'
	and ACCOUNTRELATION in ('LETERAGO S.A. (GT)', 'SAL-LET', 'CRC-LET', 'NIC-LET', 'HON-LET', 'PAN-GPH', 'GUA-LET')
)
and DATAAREAID = 120
--commit
--rollback
*/