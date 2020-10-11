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
