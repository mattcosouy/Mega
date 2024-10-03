-- Consulta para conocer el nivel de acceso de un campo en una tabla.
-- En el primer select el ID es el de la tabla, en este ejemplo: InventItemInventSetup (1762) NumberSequenceTable (273)
-- En el segundo select el ID es el del campo en la tabla, en este ejemplo: StandarQty (9)
-- La relación entre ellos se establece mediante el ParentId, allí se coloca el id de la tabla. También pesan los valores del RecordType.

SELECT * FROM ACCESSRIGHTSLIST
WHERE ID = '752' and RECORDTYPE = '0'  AND DOMAINID = 'PC-MPH' AND ACCESSTYPE > 1 and GROUPID NOT IN
      (SELECT GROUPID FROM ACCESSRIGHTSLIST
      WHERE id = '2' and RECORDTYPE = '1' AND DOMAINID = 'PC-MPH' and PARENTID ='752' AND ACCESSTYPE < 2)
      
SELECT * FROM ACCESSRIGHTSLIST
WHERE ID = '1762' and RECORDTYPE = '0'  AND DOMAINID = 'Admin' AND ACCESSTYPE > 1 and GROUPID NOT IN
      (SELECT GROUPID FROM ACCESSRIGHTSLIST
      WHERE id = '9' and RECORDTYPE = '1' AND DOMAINID = 'Admin' and PARENTID ='1762' AND ACCESSTYPE < 2)



/* AccessRecordType
Name				Value  Description 
Table					 0 Table 
Field					 1 Field
UserType				 2 UserType
DefaultTable			 4 DefaultTable
DefaultField			 5 DefaultField
SecurityKey				 6 SecurityKey
MenuItemDisplay			 7 MenuItemDisplay
MenuItemOutput			 8 MenuItemOutput
MenuItemAction			 9 MenuItemAction
MenuItemWeb				10 MenuItemWeb
WebUrlItem				11 WebUrlItem
WebActionItem			12 WebActionItem  
WebDisplayContentItem	13 WebDisplayContentItem
WebOutputContentItem	14 WebOutputContentItem
WebletItem				15 WebletItem
WebManagedContentItem	16 WebManagedContentItem

AccessType
Name		Value	 Description 
NoAccess     0		 NoAccess 
View		 1		 View 
Edit		 2		 Edit 
Add			 3		 Add 
Delete		 4		 Delete 
 
*/