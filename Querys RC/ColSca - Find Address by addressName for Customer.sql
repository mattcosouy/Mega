


    select * from DIRPARTYADDRESSRELATIONSHIP,   DirPartyAddressRelationshi1066,  address
            where DirPartyAddressRelationshi1066.RefCompanyId = address.dataAreaId and
                  DirPartyAddressRelationshi1066.PartyAddressRelationshipRecId = DIRPARTYADDRESSRELATIONSHIP.RecId
       
             and    address.RecId        = DirPartyAddressRelationshi1066.AddressRecId
             and DIRPARTYADDRESSRELATIONSHIP.PartyId = '202_000027952'
             --&& partyAddressRelationship.IsPrimary == _isPrimary && partyAddressRelationship.Shared &&
             and (DIRPARTYADDRESSRELATIONSHIP.ValidFromDateTime <= getutcdate()) 
             and (DIRPARTYADDRESSRELATIONSHIP.ValidToDateTime > getutcdate())
			 and type != 1
			 and address.name = 'Bella Piel - CC- Centro Chia - CQ'