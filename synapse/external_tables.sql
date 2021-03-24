

// *** ERRORS ***
/*
Statement ID: {697E0915-0E89-48EA-B225-CBAD880D9C00} | Query hash: 0x6BA0352A5F7FE762 | Distributed request ID: {9ADC2FA3-5A6C-4DDD-B336-BD8482FDA9E6}. 
Total size of data scanned is 50 megabytes, total size of data moved is 0 megabytes, total size of data written is 0 megabytes.
Msg 15813, Level 16, State 1, Line 1
Error handling external file: 'Max errors count reached.'. 
File/External table name: 'https://*****.dfs.core.windows.net/dynamics365-financeandoperations/sandbox.operations.dynamics.com/Tables/Finance/FinancialDimensions/Reference/DimensionAttributeValueGroup/DimensionAttributeValueGroup.csv'.

CSV example:
5637147576,0x07FD3010000000D376D634E142825CE13F9D6450948FCBFF,4,"Admin"
5637147576,0x07FD3010000000FADA97C2F2EAE3044D8E457C50BA8CA2FF,4,"Admin"

Solution: error in column [HASH] with datatype BINARY. Azure Synapse cant convert value "0x07FD3010000000D376D634E142825CE13F9D6450948FCBFF"
to binary. To resolve need to change datatype of colum [HASH] to nvarchar(XXX) and it's.
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
            WITH ([DIMENSIONHIERARCHY] bigInt, [HASH] BINARY, [LEVELS] bigInt, [CREATEDBY] nvarchar(20)
  ) as r
