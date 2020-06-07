-- *** Calendar generating ***
declare @startDate date = '20190101';
with calendar as
(
      select @startDate as [date]
      union all
      select dateadd(day , 1, [date]) 
      from calendar 
      where dateadd(day, 1, [date]) <= '20201231'
)
select 
      c.date                          as [date],
      year(c.date)                    as [year],
      format(c.date, 'MMMM', 'ru-RU') as [month],
      day(c.date)                     as [day]
from calendar c
option(maxrecursion 32767);
