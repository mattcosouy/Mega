select column_name, data_type, character_maximum_length    
from information_schema.columns  
where table_name = 'Venta'


/*
Con este query verifico el nombre de una columna, el tipo de dato y el largo del mismo. De esta manera puedo comparar los resultados obtenidos aquí con la otra tabla implicada y verificar si
tengo columnas mas o menos o si el largo de un tipo de dato fue modificado.
*/