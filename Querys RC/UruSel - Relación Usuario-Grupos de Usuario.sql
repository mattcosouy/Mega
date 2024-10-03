/* Consulta que muestra la relación Usuario / Grupos de usuario.
 2021-05-06 - Se usa para la validación de Selenín.
*/
SELECT ui.COMPANY, ui.NAME, ui.ID, ugl.GROUPID, ui.ENABLE FROM UserInfo ui 
JOIN UserGroupList ugl ON ugl.USERID = ui.ID
--where  ui.COMPANY  = '125'