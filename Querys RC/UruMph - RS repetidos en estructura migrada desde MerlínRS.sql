
--select * 
select NumRegistro,  CodigoMT, País, CodigoSAC, codigomph, count(MerlinInstance_ID) 
from RegistrosSanitarios
--where numregistro = '01133020914'
group by  NumRegistro, CodigoMT, País, CodigoSAC, codigomph
having count(MerlinInstance_ID) > 1
--RegistrosSanitarios_ID,
/*
  HealthRegistration_MPH::find(healthRegistrationInsert.HealthRegistrationId,
                                            healthRegistrationInsert.ItemId,
                                            healthRegistrationInsert.RegistrationCountryRegionId,
                                            healthRegistrationInsert.SACItemId,
                                            healthRegistrationInsert.HealthRegistrationStatus)
*/