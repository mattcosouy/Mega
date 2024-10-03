--rollback
--commit

/*
begin tran
update TACommitment_MPH
set TACOMMITMENTNUM = '4175730'
--select * from TACommitment_MPH
where dataareaid = '010'
and TACOMMITMENTNUM = '4175731'

begin tran
update TACommitmentLog_MPH
set TACOMMITMENTNUM = '4175730'
--select * from TACommitmentLog_MPH
where dataareaid = '010'
and TACOMMITMENTNUM = '4175731'

begin tran
update TACommitmentSum_MPH
set TACOMMITMENTNUM = '4175730'
--select * from TACommitmentSum_MPH
where dataareaid = '010'
and TACOMMITMENTNUM = '4175731'

begin tran
update TACommitmentTrans_MPH
set TACOMMITMENTNUM = '4175730'
--select * from TACommitmentTrans_MPH
where dataareaid = '010'
and TACOMMITMENTNUM = '4175731'
*/

/*
select * into TACommitment_MPH_BKRC  from TACommitment_MPH
select * into TACommitmentTrans_MPH_BKRC from TACommitmentTrans_MPH
select * into TACommitmentSum_MPH_BKRC from TACommitmentSum_MPH
select * into TACommitmentLog_MPH_BKRC from TACommitmentLog_MPH
*/
