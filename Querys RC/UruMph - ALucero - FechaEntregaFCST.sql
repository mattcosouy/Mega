

select ReqPlan, ArtCod, rt1.reqdate, ReqEnvFecha, ReqEntFecha, rv.*, rt1.*, mrp.* from XLS_MRP_PedidosPlanificadosTodos mrp
inner join REQTRANS rt
on rt.DATAAREAID = mrp.DataAreaID
and rt.REQPLANID = mrp.ReqPlan
and rt.REFID = mrp.ReqNro
and rt.REFTYPE = mrp.RefType
inner join REQTRANSCOV rv
on rv.DATAAREAID = mrp.DataAreaID
and rv.RECEIPTRECID = rt.RECID
inner join REQTRANS rt1
on rt1.DATAAREAID = mrp.DataAreaID
and rt1.REQPLANID = mrp.ReqPlan
and rt1.RECID = rv.ISSUERECID
--and rt1.REFID = mrp.ReqNro
--and rt1.REFTYPE = mrp.RefType

/*left join REQPO r on
r.DATAAREAID = mrp.DataAreaID
and r.REQPLANID = mrp.ReqPlan
and r.ITEMID = mrp.ArtCodExt */
--and r.RefType in (31) 	
--and r.REFID = mrp.ReqNro
		where mrp.Area = '120' and
			mrp.ProEntCod = '126300' and
			mrp.ReqPlanTipo = 0 and																	-- 0= Solo se envia Plan Maestro
			mrp.RefType in (33) 	and
			mrp.ArtTipo = 'Servicio' and --ESTE
			mrp.ArtCod = 'MS2074802'
			and ReqEntMM = 12

			/*
select * from REQTRANSCOV
where DATAAREAID = '120'
and ITEMID = 'MS2074802'
*/