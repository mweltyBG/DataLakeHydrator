

CREATE VIEW [etl].[ETLStage_3_StageTables]
WITH SCHEMABINDING AS

SELECT
    ADFActionKey
,   EnableAction
,   SourceContainer
,   SourcePath
,   SourceFile
,   TargetSchemaName
,   TargetTableName
,   ETLStage

FROM etl.ADFActions
WHERE ETLStage = '3_StageTables'