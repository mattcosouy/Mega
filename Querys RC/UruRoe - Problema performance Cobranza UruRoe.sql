-- Resolver problema de preformance Cobranza UruRoe (intentando...)

select       distinct
                                  -- #100852 - SP Central B en Base de Datos AX
                    -- Informacion derivada del Medio de Pago
                    mp.[DocStatusDes]                                                                                                                                                                                         as [DocStatusDes],
                    mp.[DocTipo]                                                                                                                                                                                              as [DocTipo], 
                    mp.[ValorOrig]                                                                                                                                                                                                   as [ValorMonOriTotal],                  -- Medio de Pago - Valor a Prorratear -- AmountCur del Doc
                    mp.[ValorMonLoc]                                                                                                                                                                                          as [ValorMonLocTotal],                  -- Medio de Pago - Valor a Prorratear -- Convertido MonLoc
                    mp.[ValorMonSec]                                                                                                                                                                                          as [ValorMonSecTotal],                  -- Medio de Pago - Valor a Prorratear -- Convertido MonSec

                    -- Proprocion el Valor para cada voucher afectado.  Valor = MedioValMon / [JournalNumValTotal] * ljt1.AmountCurCredit
                    ----------------------------------------------------------------------------------------------------------------------------------
                    -- En Moneda de la Operacion
                    (      (mp.[ValorOrig] * ljt1.AmountCurCredit) /
                           (select sum(AmountCurCredit) from LedgerJournalTrans l where l.DataAreaID = ljt.DataAreaID and l.JournalNum = ljt.JournalNum)
                    )                                                                                                                                                                                                                       as [ValorMonOri],                       -- Medio de Pago - Nuevo Valor Proporcionado en Mondea Origen

                    -- En Moneda de Local de la Empresa
                    (      (mp.[ValorOrig] * ljt1.AmountCurCredit) /
                           (select sum(AmountCurCredit) from LedgerJournalTrans l where l.DataAreaID = ljt.DataAreaID and l.JournalNum = ljt.JournalNum)
                    )      * (mp.[ValorMonLoc] / (case when mp.[ValorOrig] = 0 then 1 else [ValorOrig]         end))                                                                                                                                               as [ValorMonLoc],   
                    

                    -- En Moneda de Secundaria de la Empresa
                    (      (mp.[ValorOrig] * ljt1.AmountCurCredit) /
                           (select sum(AmountCurCredit) from LedgerJournalTrans l where l.DataAreaID = ljt.DataAreaID and l.JournalNum = ljt.JournalNum)
                    )      * (mp.[ValorMonLoc] / (case when mp.[ValorOrig] = 0 then 1 else [ValorOrig]         end))
                           * (mp.[ValorMonSec] / (case when mp.[ValorOrig] = 0 then 1 else [ValorMonLoc] end))                                                              as [ValorMonSec],
               mp.[DocReciAsiento],
               ljt.JournalNum,
               mp.AnaFecha
     -- select * from XLS_FIN_MediosDePago mp	where  mp.[DocReciAsiento] in ( 'DPM007661', 'DPM007644')
	 -- select * from LedgerJournalTrans where JournalNum = '008_165896'
	 
	 from XLS_FIN_MediosDePago mp
               inner join LedgerJournalTrans ljt on                                    -- Cruzo para recuperar el ID del Diario
                    ljt.DataAreaID = mp.[DataAreaID] and
                    ljt.Voucher = mp.[DocReciAsiento]
               inner join LedgerJournalTrans ljt1 on                                   -- Cruzo nuevamente para recuperar los multiples voucher contenidos en la cabecera del diario
                    ljt1.DataAreaID = ljt.DataAreaID and
                    ljt1.JournalNum = ljt.JournalNum 
               where mp.[DataAreaID] = '010'
                    and ljt.AmountCurCredit != 0                                                     -- Transacciones con Credito != 0
                    --and ljt1.AmountCurCredit != 0                                             -- Transacciones con Credito != 0
                    --and mp.[AnaFecha] = '20200915'                                          -- 16, 17 y 18   el distinct solo difiere en tres días
                    --and mp.DocReciAsiento = 'DPM007661'
                    and ljt1.Voucher = 'DPM007661'
                    and ljt1.JOURNALNUM = '008_166010'
                    --and mp.[DocNro] = 'brou siif 15*9*'
				order by
                    mp.[DocStatusDes]    ,
                    mp.[DocTipo],
                    mp.[ValorOrig] ,
                    mp.[ValorMonLoc],
                    mp.[ValorMonSec],
                         [ValorMonOri],                       -- Medio de Pago - Nuevo Valor Proporcionado en Mondea Origen
                    [ValorMonLoc],   
			 [ValorMonSec],
               mp.[DocReciAsiento],
               ljt.JournalNum,
               mp.AnaFecha


                    select  * from LedgerJournalTrans where Voucher = 'DPM007661' --61 registros
                    select  * from LedgerJournalTrans where JournalNum = '008_166010' --61 registros

                    --DPM007644 & 008_165896
                    select  * from LedgerJournalTrans where Voucher = 'DPM007644' --61 registros
                    select  * from LedgerJournalTrans where JournalNum = '008_165896' --61 registros

                    --DPM007653 & 008_165921
                    select  * from LedgerJournalTrans where Voucher = 'DPM007653' --61 registros
                    select  * from LedgerJournalTrans where JournalNum = '008_165921' --61 registros

                    --DPM007647 & 008_165902
                    select  * from LedgerJournalTrans where Voucher = 'DPM007647' --61 registros
                    select  * from LedgerJournalTrans where JournalNum = '008_165902' --61 registros

                    --- busco un registro de múltiples líneas al pagador central DPM
                    select  JOURNALNUM, Voucher, count(JOURNALNUM) from LedgerJournalTrans where Voucher like 'DPM%'group by JOURNALNUM, Voucher order by count(JOURNALNUM) desc
                    select  * from LedgerJournalTrans where Voucher = 'DPM007462' and JournalNum = '008_161298' --correcto
                    select  * from LedgerJournalTrans where Voucher = 'DPM007662' and JournalNum = '008_166014' --incorrecto
    /*                              
                    DPM007660 16/09
                    DPM007661 16/09
                    DPM007662 16/09
                    DPM007656 06/09
                    DPM007663 17/09
                    DPM007630 15/09
                    DPM007453 15/09
	*/