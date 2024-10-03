

select recid, * from prodtable 
where DATAAREAID = '120'
and stupdate between '2021/08/10' and '2021/08/11'

    select * from sigProdStatusChange
    left join sysDataBaselog
        on sysDataBaselog.LogRecId = sigProdStatusChange.RecId and
              sysDataBaselog.TABLE_    = 2629   -- tableId
    left join sigSignatureLog
        on sigSignatureLog.AuditLogRef = sysDataBaselog.RecId
    where sigProdStatusChange.ProdId in 
										(	select prodid from prodtable 
											where DATAAREAID = '120'
											and stupdate between '2021/08/10' and '2021/08/11' )
     and  sigProdStatusChange.NewStatus = 3  --ProdStatus::Released
	 	order by sigSignatureLog.CREATEDDATETIME desc

