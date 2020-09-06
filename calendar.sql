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



CREATE view [хд_в].[Календарь_запрос]
as
with t as
(
	select
		cast(dateadd(day, row_number() over(order by col.column_id), '19991230') as date) as date
	from
		sys.all_columns col
)
,
calendar as
(
	select
		cast(convert(char(8), date, 112) as int)     as date_id
		,date                                        as date
												     
		,cast(year(date) as smallint)                as year
		,cast(month(date) as tinyint)                as month_of_year
		,cast(datepart(quarter, date) as tinyint)    as qarter_of_year
		,cast(datepart(day, date) as tinyint)        as day_of_month
												    
		,cast(datepart(dayofyear, date) as smallint) as day_of_year
	   
		--,cast(datepart(iso_week, date) as smallint) as iso_week_of_year
		,cast(datepart(weekday, date) as tinyint)    as day_of_week
		,cast(datepart(week, date) as smallint)      as week_of_year
 
		,cast(eomonth(date) as date)                 as month_end

		,cast(1 as tinyint)                          as calendar_days
 
	from
		t
	where
		date between '20150101' and cast(dateadd(MM, 2, getDate()) as date)
)
,
calendar_derivative_1 as
(
	select
		t.*
		,cast(concat(year, qarter_of_year) as int)                                  as quarter_id
		,cast(concat(year, iif(month_of_year < 10, '0', ''), month_of_year) as int) as month_id

		,concat(year, iif(week_of_year < 10, '0',''), week_of_year)                 as week_of_year_id
		,cast(dateadd(day, 1 - day_of_week, date) as date)                          as week_beg
		,cast(iif (year < 9999, dateadd(day, 7 - day_of_week, date), null) as date) as week_end

		-- simple rule - only Sundays are holidays
		,cast(iif(day_of_week = 7, 0, 1) as tinyint)                                as is_working_day
 
		,day(month_end)                                                             as days_in_month

	from
		calendar t
)
,
calendar_derivative_2 as
(
	select
		t.*
		,
		case 
			when year < 9999
			then
				concat
				(
					 convert(varchar(5), week_beg, 4), '-'
					,convert(varchar(5), week_end, 4), ', '
					,year
				)
		end                              as week_of_year_name

		,cast(1 as float)/days_in_month  as day_rate_in_month

	from
		calendar_derivative_1 t
)
,
quarter_name as
(
	select
		cast(1 as tinyint)                   as quarter_id
		,cast('Q1' as nvarchar(32))          as qarter_en
		,cast('1-й кв.'     as nvarchar(32)) as qarter_ru

	union all

	select
		cast(2 as tinyint)
		,'Q2'
		,'2-й кв.'

	union all

	select
		cast(3 as tinyint)
		,'Q3'
		,'3-й кв.'

	union all

	select
		cast(4 as tinyint)
		,'Q4'
		,'4-й кв.'
)
,
season_name as
(
	select
		 cast(1 as tinyint)               as month_of_year
		,cast(1 as tinyint)              as id_season
		,cast('Winter' as nvarchar(32))   as en_season
		,cast('Зима'     as nvarchar(32)) as ru_season

	union all
	select
		 cast(2 as tinyint)
		,cast(1 as tinyint) 
		,'Winter'
		,'Зима'
	union all
	select
		 cast(3 as tinyint)
		,cast(2 as tinyint) 
		,'Spring'
		,'Весна'
	union all
	select
		 cast(4 as tinyint)
		,cast(2 as tinyint) 
		,'Spring'
		,'Весна'
	union all
	select
		 cast(5 as tinyint)
		,cast(2 as tinyint) 
		,'Spring'
		,'Весна'
	union all
	select
		 cast(6 as tinyint)
		,cast(3 as tinyint) 
		,'Summer'
		,'Лето'
	union all
	select
		 cast(7 as tinyint)
		,cast(3 as tinyint) 
		,'Summer'
		,'Лето'
	union all
	select
		 cast(8 as tinyint)
		,cast(3 as tinyint) 
		,'Summer'
		,'Лето'
	union all
	select
		 cast(9 as tinyint)
		,cast(4 as tinyint) 
		,'Autumn'
		,'Осень'
	union all
	select
		 cast(10 as tinyint)
		,cast(4 as tinyint) 
		,'Autumn'
		,'Осень'
	union all
	select
		 cast(11 as tinyint)
		,cast(4 as tinyint) 
		,'Autumn'
		,'Осень'
	union all
	select
		 cast(12 as tinyint)
		,cast(1 as tinyint) 
		,'Winter'
		,'Зима'
)
,
add_en as
(
	select
		t.*
		--,convert(char(10), date, 101) as date_en
		,convert(char(10), date, 104)              as date_en

		,concat(month_name.item, ' ', year)        as month_en
		,concat(quarter_name.qarter_en, ' ', year) as qarter_en

		,month_name.item                           as month_of_year_en
		,quarter_name.qarter_en                    as quarter_of_year_en

		,day_name.item                             as day_of_week_en

		-- 101
		,convert(char(10), week_beg, 104)          as week_beg_en
		,convert(char(10), week_end, 104)          as week_end_en

		,iif(is_working_day = 1, N'Working Days', N'Holidays') as is_working_day_en,

		cast(concat(year, season_name.id_season) as int)       as season_id,
		concat(season_name.en_season, ' ', year)               as season_en

	from
		calendar_derivative_2 as t

		left join (select cast(row_number() over (order by (select 1)) as tinyint) as id, value as item from string_split((select months from sys.syslanguages where alias = N'English'), N',')) month_name on
			t.month_of_year = month_name.id

		left join (select cast(row_number() over (order by (select 1)) as tinyint) as id, value as item from string_split((select days   from sys.syslanguages where alias = N'English'), N',')) day_name on
			t.day_of_week = day_name.id

		left join quarter_name on
			t.qarter_of_year = quarter_name.quarter_id
		left join season_name on
		    t.month_of_year=season_name.month_of_year
)
,
add_ru as
(
	select
		t.*
		,convert(char(10), date, 104)              as date_ru

		,concat(month_name.item, ' ', year)        as month_ru
		,concat(quarter_name.qarter_ru, ' ', year) as qarter_ru

		,month_name.item                           as month_of_year_ru
		,quarter_name.qarter_ru                    as quarter_of_year_ru

		,day_name.item                             as day_of_week_ru

		,convert(char(10), week_beg, 104)          as week_beg_ru
		,convert(char(10), week_end, 104)          as week_end_ru

		,iif(is_working_day = 1, N'рабочие дни', N'выходные') as is_working_day_ru,

		concat(season_name.ru_season, ' ', year)                      as season_ru
	from
		add_en as t

		left join (select cast(row_number() over (order by (select 1)) as tinyint) as id, value as item from string_split((select lower(months) from sys.syslanguages where alias = N'Russian'), N',')) month_name on
			t.month_of_year = month_name.id

		left join (select cast(row_number() over (order by (select 1)) as tinyint) as id, value as item from string_split((select lower(days)   from sys.syslanguages where alias = N'Russian'), N',')) day_name on
			t.day_of_week = day_name.id

		left join quarter_name on
			t.qarter_of_year = quarter_name.quarter_id
		left join season_name on
		    t.month_of_year=season_name.month_of_year

)
,
relative_day as
(
	select
		 cast(0 as tinyint)              as rel_day_id
		,cast('today'   as nvarchar(32)) as rel_day_en
		,cast('сегодня' as nvarchar(32)) as rel_day_ru
		,0                               as delta
		,null                            as others

	union all

	select
		 cast(1 as tinyint)
		,'yesterday'
		,'вчера'
		,-1
		,null

	union all

	select
		 cast(2 as tinyint)
		,'the day before yesterday'
		,'позавчера'
		,-2
		,null

	union all

	select
		 cast(255 as tinyint)
		,'other days'
		,'прочие дни'
		,-3
		,1
)
,

relative_month_day as
(
	select
		 cast(0 as tinyint)                        as rel_month_day_id
		,cast('1st day of month' as nvarchar(32))  as rel_month_day_en
		,cast('1-й день месяца' as nvarchar(32))   as rel_month_day_ru
		,cast(1 as tinyint)                        as day
		,0                                         as is_last_day
		,null                                      as others

	union all

	select
		 cast(1 as tinyint) 
		,'last day of month'
		,'последний день месяца'  
		,cast(0 as tinyint)
		,1
		,null

	union all

	select
		 cast(2 as tinyint) 
		,'other days'
		,'прочие дни'  
		,cast(0 as tinyint)
		,0
		,1
)
,
relative_year as
(
	select
		 cast(0 as tinyint)          as rel_year_id
		,'current year'              as rel_year_en
		,'текущий год'               as rel_year_ru
		,0                           as delta
		,null                        as others
						         
	union all				         
						         
	select					         
		 cast(1 as tinyint)          as rel_year_id
		,'last month'                as rel_year_en
		,'прошлый год'               as rel_year_ru
		,-1                          as delta
		,null                        as others

	union all

	select
		 cast(2 as tinyint)          as rel_year_id
		,'before last month'         as rel_year_en
		,'позапрошлый год'           as rel_year_ru
		,-2                          as delta
		,null                        as others

	union all

	select
		 cast(255 as tinyint)        as rel_year_id
		,'other month'               as rel_year_en
		,'прочие год'                as rel_year_ru
		,-3                          as delta
		,1                           as others
)
,
relative_week as
(
	select
		 cast(0 as tinyint)          as rel_wk_id
		,'current week'              as rel_wk_en
		,'текущая неделя'            as rel_wk_ru
		,0                           as delta
		,null                        as others
						         
	union all				         
						         
	select					         
		 cast(1 as tinyint)          as rel_wk_id
		,'last week'                 as rel_wk_en
		,'прошлая неделя'            as rel_wk_ru
		,-1                          as delta
		,null                        as others

	union all

	select
		 cast(2 as tinyint)          as rel_wk_id
		,'before last week'          as rel_wk_en
		,'позапрошлая неделя'        as rel_wk_ru
		,-2                          as delta
		,null                        as others

	union all

	select
		 cast(255 as tinyint)        as rel_wk_id
		,'other week'                as rel_wk_en
		,'прочие недели'             as rel_wk_ru
		,-3                          as delta
		,1                           as others
)
,
relative_quarter as
(
	select
		 cast(0 as tinyint)          as rel_quarter_id
		,'current quarter'           as rel_quarter_en
		,'текущий квартал'           as rel_quarter_ru
		,0                           as delta
		,null                        as others
						         
	union all				         
						         
	select					         
		 cast(1 as tinyint)           as rel_quarter_id
		,'last quarter'               as rel_quarter_en
		,'прошлый квартал'            as rel_quarter_ru
		,-1                           as delta
		,null                         as others

	union all

	select
		 cast(2 as tinyint)          as rel_quarter_id
		,'before last quarter'       as rel_quarter_en
		,'позапрошлый квартал'       as rel_quarter_ru
		,-2                          as delta
		,null                        as others

	union all

	select
		 cast(255 as tinyint)        as rel_quarter_id
		,'other quarter'             as rel_quarter_en
		,'прочий квартал'            as rel_quarter_ru
		,-3                          as delta
		,1                           as others
)
,
relative_month as 
(
	select
		 cast(0 as tinyint)          as rel_month_id
		,'current month'             as rel_month_en
		,'текущий месяц'             as rel_month_ru
		,0                           as delta
		,null                        as others
						         
	union all				         
						         
	select					         
		 cast(1 as tinyint)          as rel_month_id
		,'last month'                as rel_month_en
		,'прошлый месяц'             as rel_month_ru
		,-1                          as delta
		,null                        as others

	union all

	select
		 cast(2 as tinyint)          as rel_month_id
		,'before last month'         as rel_month_en
		,'позапрошлый месяц'         as rel_month_ru
		,-2                          as delta
		,null                        as others

	union all

	select
		 cast(255 as tinyint)        as rel_month_id
		,'other month'               as rel_month_en
		,'прочие месяц'              as rel_month_ru
		,-3                          as delta
		,1                           as others
)
,
add_relatives as
(
	select
		t.*

		,rd.rel_day_id
		,rd.rel_day_en
		,rd.rel_day_ru
		
		,rmd.rel_month_day_id
		,rmd.rel_month_day_en
		,rmd.rel_month_day_ru
		
		,ry.rel_year_id
		,ry.rel_year_en
		,ry.rel_year_ru

		,rw.rel_wk_id
		,rw.rel_wk_en
		,rw.rel_wk_ru

		,rq.rel_quarter_id
		,rq.rel_quarter_en
		,rq.rel_quarter_ru

		,rm.rel_month_id
		,rm.rel_month_en
		,rm.rel_month_ru
	from
		add_ru as t

		left join relative_day rd on
			t.date = cast(dateAdd(day, rd.delta, getDate()) as date)
			or
			(
				rd.others = 1
				and
				t.date <= cast(dateAdd(day, rd.delta, getDate()) as date)
			)
			
		left join relative_month_day rmd on
			t.day_of_month = rmd.day
			or
			(
				t.date = t.month_end
				and
				rmd.is_last_day = 1
			)
			or
			(
				t.day_of_month > 1
				and
				t.date != t.month_end
				and
				rmd.others = 1
			)
			left join relative_year ry on
			dateDiff(year, getDate(), t.date) = ry.delta 
			or 
			(
				ry.others = 1 
				and 
				dateDiff(year, getDate(), t.date) <= ry.delta
			)

		left join relative_week rw on
			dateDiff(week, dateAdd(day, -1, getDate()), dateAdd(day, -1, t.date)) = rw.delta 
			or 
			(
				rw.others = 1 
				and 
				dateDiff(week, dateAdd(day,-1,getDate()), dateAdd(day, -1, t.date)) <= rw.delta
			)

		left join relative_quarter rq on
			dateDiff(quarter, getDate(), t.date) = rq.delta 
			or 
			(
				rq.others = 1 
				and 
				dateDiff(quarter, getDate(), t.date) <= rq.delta
			)

		left join relative_month rm on
			dateDiff(month, getDate(), t.date) = rm.delta 
			or 
			(
				rm.others = 1 
				and 
				dateDiff(month, getDate(), t.date) <= rm.delta
			)
/*
		left join хд.КалендарьВремяОтносительноеГоды y		
		on dateDiff(year, getDate(), t.Дата) = y.Смещение or (y.УсловиеПрочие = 1 and dateDiff(year, getDate(), t.Дата) <= y.Смещение)
		left join хд.КалендарьВремяОтносительноеНедели w 
		--   dateAdd(day,-1,...) смещаемся на один день т.к. у dateDiff(week,...) первый день недели всегда ВС 
		on dateDiff(week, dateAdd(day,-1,getDate()), dateAdd(day,-1,t.Дата)) = w.Смещение or (w.УсловиеПрочие = 1 and dateDiff(week, dateAdd(day,-1,getDate()), dateAdd(day,-1,t.Дата)) <= w.Смещение)
		left join хд.КалендарьВремяОтносительноеМесяц m
		on dateDiff(month, getDate(), t.Дата) = m.Смещение or (m.УсловиеПрочие = 1 and dateDiff(month, getDate(), t.Дата) <= m.Смещение)
		left join хд.КалендарьВремяОтносительноеКвартал q
		on dateDiff(quarter, getDate(), t.Дата) = q.Смещение or (q.УсловиеПрочие = 1 and dateDiff(quarter, getDate(), t.Дата) <= q.Смещение)
*/

)

-- TODO
-- относительные недели, месяцы, кварталы, годы
-- количество дней в интервалах (неделя года, месяц, квартал, год)

select
	*
from
	add_relatives
GO


