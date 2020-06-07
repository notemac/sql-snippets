###### The smallest heading
-- Calendar generating
declare @startDate date = '20190101';
with calendar as
(
      select @startDate as [date]
      union all
      select dateadd(day , 1, [date]) from calendar where dateadd(day, 1, [date]) <= '20201231'
)
select 
      dat.date,
      year(dat.date) as year,
      format(dat.date, 'MMMM', 'ru-RU') as month,
      day(dat.date) as [day]
from calendar
option(maxrecursion 32767);
