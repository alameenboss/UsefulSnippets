---Get Recently Modified Objects

select * 
from sys.objects 
where (type = 'U' or type = 'P') 
  and modify_date > dateadd(d, -10, getdate()) 
order by modify_date desc