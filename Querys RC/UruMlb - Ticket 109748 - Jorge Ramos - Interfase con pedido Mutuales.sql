
/*
select * from CUSTTABLE
where DATAAREAID = '010'
and CustPortfolioId_MPH = 'MUTUALES'
*/
/*
select /*count(accountcode)*/ * into _RC_BK_suppitemtable from suppitemtable
select /*count(accountcode)*/ * into _RC_BK_suppitemgroup from suppitemgroup
select /*count(accountcode)*/ * into _RC_BK_custtable from custtable
*/

select /*count(accountcode)*/ * from suppitemtable s
inner join CUSTTABLE c
on s.DATAAREAID = c.DATAAREAID
and s.ACCOUNTRELATION = c.ACCOUNTNUM
and CustPortfolioId_MPH = 'MUTUALES'
where s.dataareaid = '010'
--and module != 1

--and itemcode = 1 
--and itemrelation = '152814'
--and ACCOUNTRELATION = '151207' --152814' 
--and suppitemid = '1105401'
and ACCOUNTCODE = 0  --> eliminar los registros incluyendo este filtro 
--and ACCOUNTCODE = 1   --> modificar los registros incluyendo este filtro: campo ITEMRELATION = '152814', ITEMCODE = 1, suppitemid = '1105401'
--and createdby = 'rcarb'
and TODATE > '2022-03-22'


/*
1. Copiar los registros con filtros dataareaid = '010' y and ACCOUNTRELATION = '152814' a tabla de bkp 
2. Contar los registros de la tabla de backup agrupando por Artículo. Todos debieran dar 2, si alguno no lo da, tratarlo como excepción, revisando si es accountcode 0 o 1 y actuar en consecuencia.
3. Eliminar los registros incluyendo este filtro and ACCOUNTCODE = 0 
4. Modificar los registros incluyendo este filtroand ACCOUNTCODE = 1 - Update campos ITEMRELATION = '152814', ITEMCODE = 1
5. Hacer preubas 
*/