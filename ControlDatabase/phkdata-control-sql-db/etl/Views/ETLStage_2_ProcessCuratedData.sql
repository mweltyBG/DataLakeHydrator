

CREATE VIEW [etl].[ETLStage_2_ProcessCuratedData]
WITH SCHEMABINDING AS

SELECT
    ADFActionKey
,   EnableAction
,   SourceContainer
,   SourcePath
,   SourceFile
,   TargetContainer
,   TargetPath
,   TargetFile
,   ETLStage

FROM etl.ADFActions
WHERE ETLStage = '2_ProcessCuratedData'