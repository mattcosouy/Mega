

select * from  WMSJOURNALTABLE it
inner join  WMSJOURNALTRANS ij
on ij.DATAAREAID = it.DATAAREAID
and ij.journalId = it.journalId
inner join inventDim id
on  id.DATAAREAID = ij.DATAAREAID
and id.inventDimId = ij.inventDimId
and id.InventContainerId = '120BA01402530'
where it.journalType =  0 -- Reception
and it.posted = 0
and it.DATAAREAID = '125'
