 Есть таблица, которая содержит данные о времени выполнения задач/процессов (ProcessID, TaskID, RunStartTime, RunEndTime). Процесс разбивается на задачи.
Т.е. одна задача = одна строка в таблице. Один процесс = N задач = N строк. Нужен SQL-запрос, который посчитает время работы каждого процесса или, по-другому, который вернет
итоговый набор отрезков времени выполнения по всем задачам для каждой процесса, задачи могут выполняться параллельно. У кого-нибудь есть под рукой такой запрос?
Пример:

ProcessID
TaskID
RunSartTime   
RunEndTime
1
1
14:00
14:30
1
2
14:15
15:00
1
3
16:00
16:30

Итого два отрезка:
14:00 - 15:00 и 16:00 - 16:30
Итоговое время: 1 час 30 мин;


with q as
(
select
                ID
                ,[ДатаС]
                ,iif(
                    ДатаПо > lead( [ДатаС]) over (partition by ID order by [ДатаС]),               
                    coalesce(lead(dateadd(second, -1, [ДатаС])) over (partition by ID order by [ДатаС]), max(ДатаПо) over (partition by ID))
                    ,ДатаПо
                    ) as [ДатаПо_New]
                ,datediff(second, [ДатаС], iif(
                    ДатаПо > lead( [ДатаС]) over (partition by ID order by [ДатаС]),               
                    coalesce(lead(dateadd(second, -1, [ДатаС])) over (partition by ID order by [ДатаС]), max(ДатаПо) over (partition by ID))
                    ,ДатаПо
                    )) as Diff
            from
                Таблица with (nolock)
)
select ID, sum (Diff) from q group by ID;


with source AS
(
    select 1 as ID, cast('2021-03-03 14:00:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 14:30:00.000' as datetime2(3)) as RunEndTime
    union all
    select 1 as ID, cast('2021-03-03 14:15:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 15:00:00.000' as datetime2(3)) as RunEndTime
    union all
    select 1 as ID, cast('2021-03-03 14:15:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 15:01:00.000' as datetime2(3)) as RunEndTime
    union all
    select 1 as ID, cast('2021-03-03 11:00:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 18:00:00.000' as datetime2(3)) as RunEndTime
    union all
    select 1 as ID, cast('2021-03-03 16:00:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 16:30:00.000' as datetime2(3)) as RunEndTime
    union all
    select 2 as ID, cast('2021-03-03 16:00:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 16:30:00.000' as datetime2(3)) as RunEndTime
    union all
    select 2 as ID, cast('2021-03-03 16:00:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 16:31:01.000' as datetime2(3)) as RunEndTime
    union all
    select 2 as ID, cast('2021-03-03 19:00:00.000' as datetime2(3)) as RunStartTime, cast('2021-03-03 19:10:00.000' as datetime2(3)) as RunEndTime
)
select
    s1.ID
    , s2.MinRunStartTime
    , s2.MaxRunEndTime
    , datediff(ss, s2.MinRunStartTime, s2.MaxRunEndTime) as Duration
from 
    source s1
    cross apply
    (
        select 
            min(s2.RunStartTime) as MinRunStartTime
            , max(s2.RunEndTime) as MaxRunEndTime
        from 
            source s2
        where 
            s1.ID = s2.ID
            and -- все пересекающиеся итервалы
            s1.RunStartTime <= s2.RunEndTime and s1.RunEndTime >= s2.RunStartTime
    ) s2
group by
    s1.ID
    , s2.MinRunStartTime
    , s2.MaxRunEndTime
;

-------------------------------------------------------------
-- формируем финальный справочник SCD2
---- объединяем историю ХД по product_chron_id и все прочие истории из источников
---- в данном случае объединяем два источника: dwh.product_chron и dbo.УчётнаяЕдиница_ИсторияЦен
---- суррогатный ключ - product_hist_id. Значение может меняться на глубину обновления!!!
---- !!! Концепция определения минимальных неделимых временных диапазонов (CTE range) !!!
-------------------------------------------------------------
with price_hist as
(
       select
             p.product_id
             ,h.ДатаС as date_beg
             ,lead(dateadd(day, -1, h.ДатаС), 1, cast('99990101' as date)) over (partition by p.product_id order by h.ДатаС) as date_end
             ,h.Цена  as price
       from
             dwh.product p  with (nolock)
             
             inner join dbo.УчётнаяЕдиница_ИсторияЦен h with (nolock) on
                    h.КодУчётнойЕдиницы = p.product_bk
)
,
range as
(
       select
             product_id
             ,date_beg
             ,lead(dateadd(day, -1, date_beg), 1, cast('99990101' as date)) over (partition by product_id order by date_beg) as date_end
       from
       (
             select
                    product_id
                    ,date_beg
             from
                    price_hist
             union
             select
                    product_id
                    ,date_beg
             from
                    dwh.product_chron with (nolock)
             -- union
             -- ...
       ) t
)
,
hist as
(
       select
             rng.product_id
             ,rng.date_beg
             ,rng.date_end
             ,chron.product_chron_id
             ,hist.price
             -- в целях денормализации можно прокинуть поля
             --,product_bk
             --,product
       from
             range rng
             left join dwh.product_chron chron with (nolock) on
                    chron.product_id = rng.product_id
                    and
                    chron.date_beg   <= rng.date_end
                    and
                    chron.date_end   >= rng.date_beg 
             left join price_hist hist with (nolock) on
                    hist.product_id = rng.product_id
                    and
                    hist.date_beg   <= rng.date_end
                    and
                    hist.date_end   >= rng.date_beg 
             -- left join
             -- ...
);


with source AS
(
    select * from dwh.ADF_RZCONTRACT_Log with(nolock) 
    where Activity = 'Blob -> Synapse' and status <> 'PreExecute' 
)
, source2
as
(
    select
        s1.MainPipelineRunID
        , s2.MinRunStartTime
        , s2.MaxRunEndTime
        , datediff(ss, s2.MinRunStartTime, s2.MaxRunEndTime) as Duration
    -- , min(s2.MinRunStartTime) over()
        --, max(s2.MaxRunEndTime) over()
        --, datediff(ss, min(s2.MinRunStartTime) over(), max(s2.MaxRunEndTime) over()) as Duration
    from 
        source s1
        cross apply
        (
            select 
                min(s2.RunStartTime) as MinRunStartTime
                , max(s2.RunEndTime) as MaxRunEndTime
            from 
                source s2
            where 
                s1.MainPipelineRunID = s2.MainPipelineRunID
                and -- все пересекающиеся итервалы
                s1.RunStartTime <= s2.RunEndTime and s1.RunEndTime >= s2.RunStartTime
        ) s2
    group by
        s1.MainPipelineRunID
        , s2.MinRunStartTime
        , s2.MaxRunEndTime
)
, 
source3 as
(
    select 
        MainPipelineRunID
        , MinRunStartTime
        , max(MaxRunEndTime) as MaxRunEndTime
    from source2
    group by
        MainPipelineRunID, MinRunStartTime
)
, source4 as
(
    select
        MainPipelineRunID
        , min(MinRunStartTime) as MinRunStartTime
        , MaxRunEndTime
    from source3
    group by
        MainPipelineRunID, MaxRunEndTime
)
select 
    DATEDIFF(ss, min(MinRunStartTime), max(MaxRunEndTime)) as AllDuration
    , sum(DATEDIFF(ss, MinRunStartTime, MaxRunEndTime)) as ExactDuration
from source4

