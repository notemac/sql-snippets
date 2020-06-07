-- *** Version of the SQL Server instance ***
select @@VERSION;
--
select
  case 
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'8%' then 'SQL2000'
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'9%' then 'SQL2005'
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'10.0%' then 'SQL2008'
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'10.5%' then 'SQL2008 R2'
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'11%' then 'SQL2012'
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'12%' then 'SQL2014'
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'13%' then 'SQL2016'     
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'14%' then 'SQL2017' 
     when convert(nvarchar(128), serverproperty ('Productversion')) like N'15%' then 'SQL2019' 
     else 'Unknown'
  end as MajorVersion,
  serverproperty('ProductLevel') as ProductLevel,
  serverproperty('Edition') as Edition,
  serverproperty('ProductVersion') as ProductVersion
  
  
-- *** Show info about SQL Server Analysis Services instance. XMLA query: ***
<Discover xmlns="urn:schemas-microsoft-com:xml-analysis">
    <RequestType>DISCOVER_XML_METADATA</RequestType>
    <Restrictions>
<RestrictionList>
<ObjectExpansion>ObjectProperties</ObjectExpansion>
</RestrictionList>
    </Restrictions>
    <Properties>
<PropertyList>
    </PropertyList>
    </Properties>
</Discover>
