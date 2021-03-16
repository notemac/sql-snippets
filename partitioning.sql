-- Get boundaries for RANGE RIGHT
select 
    QUOTENAME(s.name) + N'.' + QUOTENAME(obj.name) as object_name
    , p.partition_id
    , p.partition_number
    , p.rows
    , p.data_compression_desc
    , ps.data_space_id
    , pf.function_id
    , pf.fanout --Number of partitions created by the function.
    , prv.boundary_id
    , cast(lag(prv.value, 1, '19000101') over(order by p.partition_number) as date) as boundary_value_from
    , dateadd(dd, -1, cast(isnull(prv.value, '99991231') as date)) as boundary_value_to
from 
    sys.objects obj
    inner join sys.schemas s on
        obj.schema_id = s.schema_id
    inner join sys.partitions p on
        obj.object_id = p.object_id
    inner join sys.indexes idx on
        obj.object_id = idx.object_id
    inner join sys.partition_schemes ps on
        idx.data_space_id = ps.data_space_id
    inner join sys.partition_functions pf on
        ps.function_id = pf.function_id
    left join sys.partition_range_values prv on
        pf.function_id = prv.function_id
        and
        p.partition_number = prv.boundary_id
where
    s.name = N'dbo'
    and
    obj.name = N'partition_test'
