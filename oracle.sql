-- Rows multiplied by a value in a column
with items as 
(
    select 1 as item_id, 5 as item_qty, 'hello' as item_value from dual
    union all
    select 2 as item_id, 1 as item_qty, 'there' as item_value from dual
    union all
    select 3 as item_id, 1 as item_qty, 'world' as item_value from dual
)
select *  
from items, (select level l from dual connect by level <= 10) lvl
where lvl.l <= item_qty;


select * from all_tab_columns;
select * from all_tab_col_statistics;
select * from all_tables;
select * from all_indexes;
select * from all_ind_columns;

-- Character Length Semantics
select * from nls_database_parameters where parameter = 'NLS_LENGTH_SEMANTICS'


-- Split period by months
-- TODO: fix bug when DateTo = 2018-01-30, DateFrom = 2018-02-02
select 
    case
        when level = 1
        then '@{pipeline().parameters.DateFrom}'
        else TO_CHAR(TRUNC(ADD_MONTHS(TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD'), level - 1), 'MONTH'), 'YYYY-MM-DD')
        end as DateFrom
    ,  
    case
        when '@{pipeline().parameters.DateFrom}' = '@{pipeline().parameters.DateTo}'
        then '@{pipeline().parameters.DateFrom}'
        when level = TRUNC(MONTHS_BETWEEN(LAST_DAY(TO_DATE('@{pipeline().parameters.DateTo}', 'YYYY-MM-DD')), TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD'))) + 1
        then '@{pipeline().parameters.DateTo}'
        else TO_CHAR(ADD_MONTHS(LAST_DAY(TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD')), level - 1), 'YYYY-MM-DD')
        end as DateTo
from 
    dual 
connect 
    by level <= MONTHS_BETWEEN(LAST_DAY(TO_DATE('@{pipeline().parameters.DateTo}', 'YYYY-MM-DD')), TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD')) + 1;
                                                                                                           
-- TODO: fix bugs                                                                                                                                                                                                          
with months as
(
    select 
        case
            when level = 1
            then '@{pipeline().parameters.DateFrom}'
            else TO_CHAR(TRUNC(ADD_MONTHS(TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD'), level - 1), 'MONTH'), 'YYYY-MM-DD')
            end as DateFrom
        ,  
        case
            when '@{pipeline().parameters.DateFrom}' = '@{pipeline().parameters.DateTo}'
            then '@{pipeline().parameters.DateFrom}'
            when level = TRUNC(MONTHS_BETWEEN(LAST_DAY(TO_DATE('@{pipeline().parameters.DateTo}', 'YYYY-MM-DD')), TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD'))) + 1
            then '@{pipeline().parameters.DateTo}'
            else TO_CHAR(ADD_MONTHS(LAST_DAY(TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD')), level - 1), 'YYYY-MM-DD')
            end as DateTo
    from 
        dual 
    connect 
        by level <= MONTHS_BETWEEN(LAST_DAY(TO_DATE('@{pipeline().parameters.DateTo}', 'YYYY-MM-DD')), TO_DATE('@{pipeline().parameters.DateFrom}', 'YYYY-MM-DD')) + 1
)
select
    p.DateFrom
    , p.DateTo
from
    months m
    cross apply (
        select 
            m.DateFrom
            ,
            case
                when extract(day from to_date(m.DateFrom, 'YYYY-MM-DD')) <= 15 and extract(day from to_date(m.DateTo, 'YYYY-MM-DD')) > 15
                then to_char(trunc(to_date(m.DateFrom, 'YYYY-MM-DD'), 'MONTH') + 14, 'YYYY-MM-DD') 
                else m.DateTo
            end as DateTo
        from dual

        union all

        select 
            to_char(trunc(to_date(m.DateFrom, 'YYYY-MM-DD'), 'MONTH') + 15, 'YYYY-MM-DD') as DateFrom
            , m.DateTo
        from dual
        where
            extract(day from to_date(m.DateFrom, 'YYYY-MM-DD')) <= 15 and extract(day from to_date(m.DateTo, 'YYYY-MM-DD')) > 15
    ) p
