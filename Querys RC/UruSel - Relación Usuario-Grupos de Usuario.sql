/* Consulta que muestra la relaci�n Usuario / Grupos de usuario.
 2021-05-06 - Se usa para la validaci�n de Selen�n.
*/
SELECT ui.COMPANY, ui.NAME, ui.ID, ugl.GROUPID, ui.ENABLE FROM UserInfo ui 
JOIN UserGroupList ugl ON ugl.USERID = ui.ID
--where  ui.COMPANY  = '125'