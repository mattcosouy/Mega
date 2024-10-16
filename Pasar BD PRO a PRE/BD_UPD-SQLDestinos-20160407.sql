--ROLLBACK

/*
select OutputFilename, *
from SQLStatement_MPH
where DATAAREAID = @dataArea
--  and objectID like '%DES,%'
--*/

/*
begin tran
update SQLStatement_MPH
set ObjectId = replace(ObjectId,'DON y OTR',' DON y VAR')
where DATAAREAID = @dataArea
  and objectID like '%DES,DON y OTR'
--commit
--*/

print '--------------------------------------------------------------------------------------------------------------------'

declare
	@origen		varchar(MAX),
	@destino	varchar(MAX),
	@origen2	varchar(MAX),
	@destino2	varchar(MAX),
	@dataArea	varchar(05)

/*
set @origen2	= 'ax2k9fsgral\'
set @destino2	= ''
update SQLStatement_MPH
set OutputFilename = REPLACE(OutputFilename, @origen2, @destino2)
where DATAAREAID = @dataArea
--*/

/*
set @dataArea = '050'
set @origen2	= '\\192.168.191.3\PRO-UruRoe'
set @destino2	= '\\192.168.204.230\ColSca\PRO-ColSca'
--*/

-- Cambio de carpeta por IP
/*
set @origen2	= '\\mpap230mvd6'
set @destino2	= '\\192.168.204.230'
--*/

/*
update SQLStatement_MPH
set OutputFilename = REPLACE(OutputFilename, @origen2, @destino2)
where DATAAREAID = @dataArea
--*/

-- MegaPharma
--/*
set @dataArea = '120'
--set @origen	= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Megalabs\PRO-MPH'
--set @destino	= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Megalabs\Pre-MPH'
--set @origen		= 'UruMPH\PRO-MPH'
--set @destino	= 'UruMPH\Pre-MPH'
set @origen		= 'Megalabs\PRO-MPH'
set @destino	= 'Megalabs\Pre-MPH'
--set @destino	= 'UruMPH\Dev-MPH'
--set @origen		= 'AX Files\Selenin\EDI'
--set @destino	= 'AX Files\Selenin\Pre-SEL\EDI'
--*/
/*
set @origen		= 'PRO-MPH'
set @destino	= 'Pre-MPH'
--*/

-- Selenin
/*
set @dataArea = '125'
set @origen		= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Selenin\EDI'
set @destino	= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Selenin\Pre-SEL\EDI'
--*/

-- Roemmeres
/*
set @dataArea = '010'
set @origen		= 'UruRoe\PRO-UruRoe'
set @destino	= 'UruRoe\Pre-UruRoe'
--*/

-- Raymos
/*
set @dataArea = '070'
set @origen		= 'ArgRay\PRO-ArgRay'
set @destino	= 'ArgRay\Pre-ArgRay'
--*/

-- Raymos DEV
/*
set @dataArea = '070'
set @origen		= 'ArgRay\PRO-ArgRay'
set @destino	= 'ArgRay\DEV-ArgRay'
--*/

-- Scandinavia Col
/*
set @dataArea = '050'
--set @origen	= 'ColSca\PRO-ColSca'
--set @destino	= 'ColSca\Pre-ColSca'
set @origen		= 'AX-Pharma\PRO-ColSca'
set @destino	= 'AX-Pharma\Pre-ColSca'
--*/

-- Roemmers Per
/*
set @dataArea = '310'
set @origen		= 'PRO-PerRoe'
set @destino	= 'Pre-PerRoe'
--*/

/*
set @origen		= 'Pre-PerRoe'
set @destino	= 'Sana-PerRoe'
--*/

--/*
select SQLStatementGroupId, OutputFilename, *
from SQLStatement_MPH
where DATAAREAID = @dataArea
--  and objectID like '%other%'
--  and QueryStatementText like '%exportaci%'
--  and sqlstatementgroupid like '%Alma%'

 --ROLLBACK
begin tran

update SQLStatement_MPH
set OutputFilename = REPLACE(OutputFilename, @origen, @destino)
where DATAAREAID = @dataArea
--*/

--commit

print '--------------------------------------------------------------------------------------------------------------------'

select SQLStatementGroupId, OutputFilename, *
from SQLStatement_MPH
where DATAAREAID = @dataArea
--  and objectID like '%other%'
--  and QueryStatementText like '%exportaci%'
--  and sqlstatementgroupid like '%Alma%'

/*
select OutputFilename, *
from SQLStatement_MPH
where DATAAREAID = @dataArea
  and objectId like '%MEGAPAN%'

begin tran
update SQLStatement_MPH
set ObjectId = replace(objectId,'EXT-MEGAPAN','MEGAPAN-01')
where DATAAREAID = @dataArea
  and objectId like '%MEGAPAN%'
--commit
--*/
