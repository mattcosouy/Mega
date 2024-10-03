DECLARE @Contador          INT = 1
DECLARE @AAMM_Ini          INT = 202001
DECLARE @AAMM_Fin          INT = 202210
DECLARE @FECHA_Act         DATE = (SELECT CAST(CAST(@AAMM_Ini * 100 + 01 AS CHAR(8)) AS DATE))
DECLARE @FECHA_Act_EOM     DATE = (SELECT EOMonth(CAST(CAST(@AAMM_Ini * 100 + 01 AS CHAR(8)) AS DATE)))
DECLARE @FECHA_Fin         DATE = (SELECT EOMonth(CAST(CAST(@AAMM_Fin * 100 + 01 AS CHAR(8)) AS DATE)))
-- 
SELECT @AAMM_Ini AAMM_Ini, @AAMM_Fin AAMM_Fin, @FECHA_Act FECHA_Act, @FECHA_Act_EOM FECHA_Act_EOM, @FECHA_Fin FECHA_Fin

WHILE ( @FECHA_Act <= @FECHA_Fin)
BEGIN
       PRINT CONVERT(VARCHAR, @Contador) + ' -- @FECHA_Act = ' + CONVERT(VARCHAR,@FECHA_Act, 23) + ' -- @FECHA_Act_EOM = ' + CONVERT(VARCHAR,@FECHA_Act_EOM, 23)

       -- aquí inicia tu código de insert

       -- tu codigo -- >> considere armar transacciones para DELETE (o INSERT) <<
 

       -- aquí finaliza tu código de insert

       SET @Contador       = (SELECT @Contador + 1)
       SET @FECHA_Act             = (SELECT DATEADD(MONTH, 1, @FECHA_Act))
       SET @FECHA_Act_EOM  = (SELECT EOMonth(@FECHA_Act))    
END

/*
El rango de fechas que trabajará ese query es:
AAMM_Ini          AAMM_Fin          FECHA_Act         FECHA_Act_EOM             FECHA_Fin
202001                202210                2020-01-01         2020-01-31                        2022-10-31

El detalle de cada rango de ese query es (nótese que no le erra en los años bisiestos):
1 -- @FECHA_Act = 2020-01-01 -- @FECHA_Act_EOM = 2020-01-31
2 -- @FECHA_Act = 2020-02-01 -- @FECHA_Act_EOM = 2020-02-29
3 -- @FECHA_Act = 2020-03-01 -- @FECHA_Act_EOM = 2020-03-31
4 -- @FECHA_Act = 2020-04-01 -- @FECHA_Act_EOM = 2020-04-30
5 -- @FECHA_Act = 2020-05-01 -- @FECHA_Act_EOM = 2020-05-31
6 -- @FECHA_Act = 2020-06-01 -- @FECHA_Act_EOM = 2020-06-30
7 -- @FECHA_Act = 2020-07-01 -- @FECHA_Act_EOM = 2020-07-31
8 -- @FECHA_Act = 2020-08-01 -- @FECHA_Act_EOM = 2020-08-31
9 -- @FECHA_Act = 2020-09-01 -- @FECHA_Act_EOM = 2020-09-30
10 -- @FECHA_Act = 2020-10-01 -- @FECHA_Act_EOM = 2020-10-31
11 -- @FECHA_Act = 2020-11-01 -- @FECHA_Act_EOM = 2020-11-30
12 -- @FECHA_Act = 2020-12-01 -- @FECHA_Act_EOM = 2020-12-31
13 -- @FECHA_Act = 2021-01-01 -- @FECHA_Act_EOM = 2021-01-31
14 -- @FECHA_Act = 2021-02-01 -- @FECHA_Act_EOM = 2021-02-28
15 -- @FECHA_Act = 2021-03-01 -- @FECHA_Act_EOM = 2021-03-31
16 -- @FECHA_Act = 2021-04-01 -- @FECHA_Act_EOM = 2021-04-30
17 -- @FECHA_Act = 2021-05-01 -- @FECHA_Act_EOM = 2021-05-31
18 -- @FECHA_Act = 2021-06-01 -- @FECHA_Act_EOM = 2021-06-30
19 -- @FECHA_Act = 2021-07-01 -- @FECHA_Act_EOM = 2021-07-31
20 -- @FECHA_Act = 2021-08-01 -- @FECHA_Act_EOM = 2021-08-31
21 -- @FECHA_Act = 2021-09-01 -- @FECHA_Act_EOM = 2021-09-30
22 -- @FECHA_Act = 2021-10-01 -- @FECHA_Act_EOM = 2021-10-31
23 -- @FECHA_Act = 2021-11-01 -- @FECHA_Act_EOM = 2021-11-30
24 -- @FECHA_Act = 2021-12-01 -- @FECHA_Act_EOM = 2021-12-31
25 -- @FECHA_Act = 2022-01-01 -- @FECHA_Act_EOM = 2022-01-31
26 -- @FECHA_Act = 2022-02-01 -- @FECHA_Act_EOM = 2022-02-28
27 -- @FECHA_Act = 2022-03-01 -- @FECHA_Act_EOM = 2022-03-31
28 -- @FECHA_Act = 2022-04-01 -- @FECHA_Act_EOM = 2022-04-30
29 -- @FECHA_Act = 2022-05-01 -- @FECHA_Act_EOM = 2022-05-31
30 -- @FECHA_Act = 2022-06-01 -- @FECHA_Act_EOM = 2022-06-30
31 -- @FECHA_Act = 2022-07-01 -- @FECHA_Act_EOM = 2022-07-31
32 -- @FECHA_Act = 2022-08-01 -- @FECHA_Act_EOM = 2022-08-31
33 -- @FECHA_Act = 2022-09-01 -- @FECHA_Act_EOM = 2022-09-30
34 -- @FECHA_Act = 2022-10-01 -- @FECHA_Act_EOM = 2022-10-31
*/

