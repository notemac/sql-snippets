

// *** ERRORS ***
/*
Statement ID: {697E0915-0E89-48EA-B225-CBAD880D9C00} | Query hash: 0x6BA0352A5F7FE762 | Distributed request ID: {9ADC2FA3-5A6C-4DDD-B336-BD8482FDA9E6}. Total size of data scanned is 50 megabytes, total size of data moved is 0 megabytes, total size of data written is 0 megabytes.
Msg 15813, Level 16, State 1, Line 1
Error handling external file: 'Max errors count reached.'. File/External table name: 'https://finsystemdatalake.dfs.core.windows.net/dynamics365-financeandoperations/alfastrah-uat-perf.sandbox.operations.dynamics.com/Tables/Finance/FinancialDimensions/Reference/DimensionAttributeValueGroup/DimensionAttributeValueGroup.csv'.
*/
SELECT top 10 
  r.filepath(1) as [$FileName], 
  DIMENSIONHIERARCHY, 
  HASH, 
  LEVELS
  CREATEDBY 
FROM 
  OPENROWSET(BULK 'Tables/Finance/FinancialDimensions/Reference/DimensionAttributeValueGroup/*.csv', 
            FORMAT = 'CSV', 
            PARSER_VERSION = '2.0', 
            DATA_SOURCE ='dynamics365_financeandoperations') 
            WITH (DIMENSIONHIERARCHY bigInt, [HASH] BINARY, LEVELS bigInt, CREATEDBY nvarchar(20)
  ) as r

