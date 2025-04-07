--Correr primero esta parte, para ver si hay algún archivo apuntando al PRO 
select *
	--BULKPROCESSFORMAT,DATAAREAID,FILEPATHORIG, FILEPATHPROCESS
	--,FILEPATHORIG		= REPLACE(FILEPATHORIG,		'PRO-MexIta','Pre-MexIta (no usar)')
	--,FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,	'PRO-MexIta','Pre-MexIta (no usar)')
from BULKPROCESSFORMATPARAMETE40080
where DATAAREAID = '100'
AND (FILEPATHORIG <> '' OR FILEPATHPROCESS <> '')
order by 1

--Si hay archivos correr estas consultas cambiando PRO por PRE (fijarse como se llaman las carpetas, sobre todo la del PRE) y el dataareaID

/*
begin tran
UPDATE BULKPROCESSFORMATPARAMETE40080
set FILEPATHORIG		= REPLACE(FILEPATHORIG,		'PRO-MexIta','Pre-MexIta (no usar)')
	,FILEPATHPROCESS	= REPLACE(FILEPATHPROCESS,	'PRO-MexIta','Pre-MexIta (no usar)')
where DATAAREAID = '100'
AND (FILEPATHORIG <> '' OR FILEPATHPROCESS <> '')
-- commit
*/

