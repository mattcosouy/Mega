--CON EL SIGUIENTE QUERY VAMOS A ACTIVAR UNA PBI COMO ALTA FRECUENCIA O BIEN PODEMOS DEJAR QUE SEA AF PARA QUE PASE A SER NORMAL

--1RA PARTE
SELECT * from [PBI_Indice] 
where objetoid = 'PBI_TipoDeCambio'

-----------------------------------------------------

--2DA PARTE
update [PBI_Indice]
set FrecAlta = 'Si'
where Orden = 5
------------------------------------------------------------------------------------------------------------------------------------------------
