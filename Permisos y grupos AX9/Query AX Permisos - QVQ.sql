select top 100 *
from TableFieldBehavior_MPH t
inner join TableFieldBehaviorByUser_MPH u
on t.TABLEFIELDBEHAVIORID = u.TABLEFIELDBEHAVIORID
where MAINTABLEID = 26and ((u.USERTABLECODE = 0 AND USERTABLERELATION = 'jpere')or 
 (u.USERTABLECODE = 1 AND USERTABLERELATION in (SELECT ugl.GROUPID 
												FROM USERINFO ui
												INNER JOIN USERGROUPLIST ugl ON ui.ID = ugl.USERID
												INNER JOIN USERGROUPINFO ugi ON ugl.GROUPID = ugi.ID
												WHERE ui.ID = 'jpere')
)
)