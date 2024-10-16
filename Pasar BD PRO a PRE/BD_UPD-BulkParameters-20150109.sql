declare @Area		nvarchar(5)

set @Area = '120'

declare
	@origen		varchar(MAX),
	@destino	varchar(MAX) 

-- MegaPharma
--/*
set @Area = '120'
--set @origen	= 'URUMPH\PRO-MPH'
--set @destino	= 'URUMPH\Pre-MPH'
set @origen		= 'Megalabs\PRO-MPH'
set @destino	= 'Megalabs\Pre-MPH'
--set @destino	= 'URUMPH\DEV-MPH'
--set @destino	= 'PRO-SEL'
--*/

-- Selenin
/*
set @Area = '125'
--set @origen		= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Selenin\EDI'
--set @destino	= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Selenin\Pre-SEL\EDI'
set @origen		= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Megalabs\PRO-MPH'
set @destino	= '\\192.168.220.16\File Sharing Mega Labs\DPUBLIC\AX Files\Megalabs\Pre-MPH'
--*/

/*  Paso 1/3
set @Area = '125'
set @origen		= 'URUMPH\PRO-MPH'
set @destino	= 'PRO-SEL'
--*/
/*  Paso 2/3
set @Area = '125'
set @origen		= 'ax2k9fsgral\PRO-SEL\EDI'
set @destino	= 'PRO-SEL\EDI'
--*/
/*  Paso 3/3
set @Area = '125'
set @origen		= 'PRO-SEL\EDI'
set @destino	= 'PRO-SEL\Pre-Sel\EDI'
--*/

-- Roemmeres
/*
set @Area = '010'
--para PRE
set @origen		= 'UruRoe\PRO-UruRoe'	--'UruRoe\PRO-UruRoe'
set @destino	= 'UruRoe\Pre-UruRoe'	--'UruRoe\Pre-UruRoe'

--para PRO
--set @origen		= '\\192.168.204.230'			--'UruRoe\PRO-UruRoe'
--set @destino	= '\\192.168.114.3\AxFiles'		--'UruRoe\Pre-UruRoe'

--set @origen		= '\\192.168.114.3\EDI'		--'UruRoe\Pre-UruRoe'
--set @destino	= '\\192.168.114.3\AxFiles\UruRoe\Pre-UruRoe\EDI'	--'UruRoe\Pre-UruRoe'
--*/

/*
set @origen		= 'EDI\Almacen'
set @destino	= 'EDI\INTERCOMPANY$\Almacen'
*/

/*
set @Area = '70'
set @origen		= 'ArgRay\PRO-ArgRay'
set @destino	= 'ArgRay\Pre-ArgRay'
--*/
/*
set @Area = '070'
set @origen		= 'ArgRay\PRO-ArgRay'
set @destino	= 'ArgRay\DEV-ArgRay'
--*/

/*
set @Area = '050'
--set @origen		= 'ColSca\PRO-ColSca'
--set @destino	= 'ColSca\Pre-ColSca'
set @origen		= 'AX-Pharma\PRO-ColSca'
set @destino	= 'AX-Pharma\Pre-ColSca'
--*/

-- Roemmers PERU
/*
set @Area = '050'
set @origen		= 'PRO-PerRoe'
set @destino	= 'Pre-PerRoe'
--*/

/*
set @Area = '050'
set @origen		= 'Pre-PerRoe'
set @destino	= 'Sana-PerRoe'
--*/



select BULKPROCESSFORMAT,DATAAREAID,FILEPATHORIG, FILEPATHPROCESS
from BULKPROCESSFORMATPARAMETE40080
where DATAAREAID = @Area
order by 1

print '------------------------------------------------------------------------'

print 'De '+@origen
print 'A  '+@destino

--rollback
--commit
begin tran

/*
update BULKPROCESSFORMATPARAMETE40080
set FILEPATHORIG	= REPLACE(FILEPATHORIG,'\\','\')
  , FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,'\\','\')
where DATAAREAID = @Area
--*/

/* SC1
update BULKPROCESSFORMATPARAMETE40080
set FILEPATHORIG	= REPLACE(FILEPATHORIG,@origen,@destino)
  , FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,@origen,@destino)
where DATAAREAID = @Area
--*/

/* SC2
update BULKPROCESSFORMATPARAMETE40080
set FILEPATHORIG	= REPLACE(FILEPATHORIG,'\192.','\\192.')
  , FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,'\192.','\\192.')
where DATAAREAID = @Area
--*/

/*
update BULKPROCESSFORMATPARAMETE40080
set FILEPATHORIG	= '\\192.168.220.20x\GnaMailBox\Send'
  , FILEPATHPROCESS	= '\\192.168.220.20x\GnaMailBox\Send\Procesados'
where DATAAREAID = @Area
  and BULKPROCESSFORMAT = '11'
--*/

print '------------------------------------------------------------------------'

select BULKPROCESSFORMAT,DATAAREAID,FILEPATHORIG, FILEPATHPROCESS
from BULKPROCESSFORMATPARAMETE40080
where DATAAREAID = @Area
order by 1



-- NOTAS AGREGADAS EL 16/10/2024 Ticket 152605 MexIta -- 

select 
	BULKPROCESSFORMAT,DATAAREAID,FILEPATHORIG, FILEPATHPROCESS
	,FILEPATHORIG		= REPLACE(FILEPATHORIG,		'PRO-MexIta','Pre-MexIta (no usar)')
	,FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,	'PRO-MexIta','Pre-MexIta (no usar)')
from BULKPROCESSFORMATPARAMETE40080
where DATAAREAID = '100'
AND (FILEPATHORIG <> '' OR FILEPATHPROCESS <> '')
order by 1
 
/*
begin tran
UPDATE BULKPROCESSFORMATPARAMETE40080
set FILEPATHORIG		= REPLACE(FILEPATHORIG,		'PRO-MexIta','Pre-MexIta (no usar)')
	,FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,	'PRO-MexIta','Pre-MexIta (no usar)')
where DATAAREAID = '100'
AND (FILEPATHORIG <> '' OR FILEPATHPROCESS <> '')
-- commit
*/