--Correr primero esta parte, para ver si hay algún archivo apuntando al PRO o archivos que sean AXAPTA_IM

select SQLStatementGroupId, OutputFilename-- , OutputFilename = REPLACE(OutputFilename, 'AXAPTA_IM','AXAPTA_IM_PRE'), *
from SQLStatement_MPH
where DATAAREAID = '100'
--and OutputFilename not like '%PRO-MexIta%'
and OutputFilename <> '' 

----------------------------------------------------------------------------------------------------------------------------------

--Si hay archivos correr estas consultas cambiando PRO por PRE (fijarse como se llaman las carpetas, sobre todo la del PRE) y el dataareaID

/*
begin tran

--Primer update
update SQLStatement_MPH
set OutputFilename = REPLACE(OutputFilename, 'PRO-MexIta','Pre-MexIta (no usar)')
where DATAAREAID = '100'
and OutputFilename like '%PRO-MexIta%'

--Segundo update
update SQLStatement_MPH
set OutputFilename = REPLACE(OutputFilename, 'AXAPTA_IM','AXAPTA_IM_PRE')
where DATAAREAID = '100'
and OutputFilename not like '%PRO-MexIta%'
and OutputFilename not like '%PRE-MexIta%'
and OutputFilename <> '' 

-- commit
--*/
