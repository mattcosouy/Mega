select      -- distinct
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
                    (      (mp.[ValorOrig] * ljt.AmountCurCredit) /
                           (select sum(AmountCurCredit) from LedgerJournalTrans l where l.DataAreaID = ljt.DataAreaID and l.JournalNum = ljt.JournalNum)
                    )                                                                                                                                                                                                                       as [ValorMonOri],                       -- Medio de Pago - Nuevo Valor Proporcionado en Mondea Origen

                    -- En Moneda de Local de la Empresa
                    (      (mp.[ValorOrig] * ljt.AmountCurCredit) /
                           (select sum(AmountCurCredit) from LedgerJournalTrans l where l.DataAreaID = ljt.DataAreaID and l.JournalNum = ljt.JournalNum)
                    )      * (mp.[ValorMonLoc] / (case when mp.[ValorOrig] = 0 then 1 else [ValorOrig]         end))                                                                                                                                               as [ValorMonLoc],   
                    

                    -- En Moneda de Secundaria de la Empresa
                    (      (mp.[ValorOrig] * ljt.AmountCurCredit) /
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
       /*        inner join LedgerJournalTrans ljt1 on                                   -- Cruzo nuevamente para recuperar los multiples voucher contenidos en la cabecera del diario
                    ljt1.DataAreaID = ljt.DataAreaID and
                    ljt1.JournalNum = ljt.JournalNum */
               where mp.[DataAreaID] = '010'
                    and ljt.AmountCurCredit != 0                                                     -- Transacciones con Credito != 0
                    --and ljt1.AmountCurCredit != 0                                             -- Transacciones con Credito != 0
                    --and mp.[AnaFecha] = '20200915'                                          -- 16, 17 y 18   el distinct solo difiere en tres días
                    --and mp.DocReciAsiento = 'DPM007661'
                    and ljt.Voucher = 'DPM007661'
                    and ljt.JOURNALNUM = '008_166010'
