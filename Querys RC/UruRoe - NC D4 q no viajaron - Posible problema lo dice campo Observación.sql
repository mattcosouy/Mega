
--  exec dbo.XLS_EDI_AXInvoice_To_D4 '010', 'AM',  'WEB', 'D4_NCFACDet_V01',null, null, '2021-01-15', null, null, 'D400000', null
-- exec dbo.XLS_EDI_AXInvoice_To_D4 '010', 'AM',  'WEB', 'D4_NCFACDet_V01',null, null, '2021-01-15', null, null, 'D40001', null

select substring(referencia, 15, 20) as ref, * from   
--begin tran
--update
XLS_EDI_AXInvoice_To_D4_Sync 
--set ClaveID = ClaveID + '_1'
where DataAreaID = '010'
--and Pro_TipoSync = 'D4_VTAINV_V01' 
and claveid in ('A133484','A133485','A133487','A133490','A133491','A133492','A133493','A133494','A133495','A133496','A133498','A133499','A133500',
'A133501','A133502','A133503','A133504')
--and Env_Obsarvacion != 'Grabado Correctamente'
--and substring(referencia, 15, 20) in  ('225446','225447','225448','225471','225478','225489','225490','225491','225492',
--'225514','225526','225529','225538','225541','225555','225556','225558','235090')
--commit
--rollback
--and Informacion != 'Almacen: Todos Operac.: 4 (4) PedGrup: Local (0)'
--and CONVERT(date,pro_fechahora) = '2021-01-15'
--and Pro_Accion = 'A'
order by Ref

/*
'A133484','A133485','A133487','A133490','A133491','A133492','A133493','A133494','A133495','A133496','A133498','A133499','A133500','A133501','A133502',
'A133503','A133504'
*/

