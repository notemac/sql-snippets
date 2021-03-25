## Creating external table
```SQL
--DROP DATABASE SCOPED CREDENTIAL sas_dynamics365_financeandoperations
CREATE DATABASE SCOPED CREDENTIAL sas_dynamics365_financeandoperations
WITH IDENTITY = 'SHARED ACCESS SIGNATURE', 
SECRET = 'Data Lake Storage account Access Key';
GO
-- DROP EXTERNAL FILE FORMAT csv_cdm_entity_d365
CREATE EXTERNAL FILE FORMAT csv_cdm_entity_d365
WITH 
(  
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS 
    (     
        FIELD_TERMINATOR = ','
        , STRING_DELIMITER = '"'
        , First_Row = 1
        , DATE_FORMAT = 'yyyy-MM-dd HH:mm:ss.fffffff'
        , USE_TYPE_DEFAULT = FALSE 
        , Encoding = 'UTF8'
    )
);
GO
-- DROP EXTERNAL DATA SOURCE dynamics365_financeandoperations
CREATE EXTERNAL DATA SOURCE dynamics365_financeandoperations
WITH 
(    
    LOCATION   = N'abfss://<container>@<storage_account>.dfs.core.windows.net'
    , CREDENTIAL = sas_dynamics365_financeandoperations
    , TYPE = HADOOP 
)
GO
-- drop external table dfs.MAINACCOUNT
create external table dfs.MAINACCOUNT
(
    ACCOUNTCATEGORYREF bigInt, 
    ADJUSTMENTMETHOD_MX bigInt, 
    CLOSETYPE bigInt, 
    CLOSING bigInt, 
    CONSOLIDATIONMAINACCOUNT nvarchar(10), 
    CURRENCYCODE nvarchar(3), 
    DEBITCREDITBALANCEDEMAND bigInt, 
    DEBITCREDITCHECK bigInt, 
    DEBITCREDITPROPOSAL bigInt, 
    EXCHANGEADJUSTED bigInt, 
    EXCHANGEADJUSTMENTRATETYPE bigInt, 
    FINANCIALREPORTINGEXCHANGERATETYPE bigInt, 
    FINANCIALREPORTINGTRANSLATIONTYPE bigInt, 
    INFLATIONADJUSTMENT_MX bigInt,
    LEDGERCHARTOFACCOUNTS bigInt, 
    MAINACCOUNTID nvarchar(20), 
    MAINACCOUNTTEMPLATE bigInt, 
    MANDATORYPAYMENTREFERENCE bigInt, 
    MONETARY bigInt, 
    NAME nvarchar(60), 
    OFFSETLEDGERDIMENSION bigInt, 
    OPENINGACCOUNT bigInt, 
    PARENTMAINACCOUNT bigInt, 
    POSTINGTYPE bigInt, 
    REPOMOTYPE_MX bigInt, 
    REPORTINGACCOUNTTYPE bigInt, 
    SRUCODE nvarchar(4), 
    TRANSFERYEARENDACCOUNT_ES bigInt, 
    TYPE bigInt, 
    UNITOFMEASURE bigInt, 
    USERINFOID nvarchar(20), 
    VALIDATECURRENCY bigInt, 
    VALIDATEPOSTING bigInt, 
    VALIDATEUSER bigInt, 
    REPORTINGEXCHANGEADJUSTMENTRATETYPE bigInt, 
    STANDARDMAINACCOUNT_W bigInt, 
    PARTITION bigInt, 
    RECID bigInt, 
    RECVERSION bigInt, 
    MODIFIEDDATETIME datetime2(7), 
    MODIFIEDBY nvarchar(20), 
    CREATEDDATETIME datetime2(7), 
    CREATEDBY nvarchar(20)
)
WITH (LOCATION=N'Tables/Custom/MAINACCOUNT/',
    DATA_SOURCE = [dynamics365_financeandoperations],  
    FILE_FORMAT = [csv_cdm_entity_d365],
    REJECT_TYPE = VALUE,
    REJECT_VALUE = 0
);
select top 10 * from dfs.MAINACCOUNT 
```



# ERRORS
**Msg 15813, Level 16, State 1, Line 1 Error handling external file: 'Max errors count reached.'**  
Statement ID: {697E0915-0E89-48EA-B225-CBAD880D9C00} | Query hash: 0x6BA0352A5F7FE762 | Distributed request ID: {9ADC2FA3-5A6C-4DDD-B336-BD8482FDA9E6}. 
Total size of data scanned is 50 megabytes, total size of data moved is 0 megabytes, total size of data written is 0 megabytes.  
Msg 15813, Level 16, State 1, Line 1 Error handling external file: 'Max errors count reached.'. 
File/External table name: 'https://*****.dfs.core.windows.net/dynamics365-financeandoperations/sandbox.operations.dynamics.com/Tables/Finance/FinancialDimensions/Reference/DimensionAttributeValueGroup/DimensionAttributeValueGroup.csv'.

**Query:**  
```SQL
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
```  
**CSV file example:**  
5637147576,0x07FD3010000000D376D634E142825CE13F9D6450948FCBFF,4,"Admin"
5637147576,0x07FD3010000000FADA97C2F2EAE3044D8E457C50BA8CA2FF,4,"Admin"  
**Solution:** error in column [HASH] with datatype BINARY. Azure Synapse cant convert value "0x07FD3010000000D376D634E142825CE13F9D6450948FCBFF"
to binary. To resolve need to change datatype BINARY of colum [HASH] to NVARCHAR(XXX).
