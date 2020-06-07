*** Error when processing tabular model from SQL Server Agent. ***
SQL Server Analysis Services Command:
```{
  "refresh": {
    "type": "full",
    "objects": [
      {
        "database": "experimental"
      }
    ]
  }
}
```
Executed as user: NT Service\SQLSERVERAGENT. Microsoft.AnalysisServices.Xmla.XmlaException: The JSON DDL request failed with the following error: Cannot execute the Refresh command: database 'Chapter3_model' cannot be found..   at Microsoft.AnalysisServices.Xmla.XmlaClient.CheckForSoapFault(XmlReader reader, XmlaResult xmlaResult, Boolean throwIfError)   at Microsoft.AnalysisServices.Xmla.XmlaClient.CheckForError(XmlReader reader, XmlaResult xmlaResult, Boolean throwIfError)   at Microsoft.AnalysisServices.Xmla.XmlaClient.SendMessage(Boolean endReceivalIfException, Boolean readSession, Boolean readNamespaceCompatibility)   at Microsoft.AnalysisServices.Xmla.XmlaClient.SendMessageAndReturnResult(String& result, Boolean skipResult)   at Microsoft.AnalysisServices.Xmla.XmlaClient.ExecuteStatement(String statement, String properties, String& result, Boolean skipResult, Boolean propertiesXmlIsComplete)   at Microsoft.AnalysisServices.Xmla.XmlaClient.Execute(String command, String properties, String& result, Boolean skipResult, Boolean propertiesXmlIsComplete)   at Microsoft.SqlServer.Management.Smo.Olap.SoapClient.ExecuteStatement(String stmt, StatementType stmtType, Boolean withResults, String properties, String parameters, Boolean restrictionListElement, String discoverType, String catalog)   at Microsoft.SqlServer.Management.Smo.Olap.SoapClient.SendCommand(String command, Boolean withResults, String properties)   at OlapEvent(SCH_STEP* pStep, SUBSYSTEM* pSubSystem, SUBSYSTEMPARAMS* pSubSystemParams, Boolean fQueryFlag).  The step failed.

Solution: add "NT Service\SQLSERVERAGENT" in SSAS administrators.
