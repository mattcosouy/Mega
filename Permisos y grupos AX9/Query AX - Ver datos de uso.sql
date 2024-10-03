select *
from SysLastValue
where USERID = 'mgian'
and elementName = 'Modal_MPH'

--Se aprecia que en PRE vs PRO, el mismo UserID tiene el mismo RECID, pero distintos valores de
--RECVERSION y VALUE (que es el que importa).