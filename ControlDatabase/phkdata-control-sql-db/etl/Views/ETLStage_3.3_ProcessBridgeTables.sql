

CREATE VIEW [etl].[ETLStage_3.3_ProcessBridgeTables]
WITH SCHEMABINDING AS

SELECT
    ADFActionKey
,   EnableAction
,   SourceDB
,   TargetSchemaName
,   TargetTableName
,   StoredProcedureName
,   DataLoadType
,   ETLStage

FROM etl.ADFActions
WHERE ETLStage = '3.3_ProcessBridgeTables'