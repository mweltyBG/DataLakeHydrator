

CREATE VIEW [etl].[ETLStage_3.5_ProcessFactTables]
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
WHERE ETLStage = '3.5_ProcessFactTables'