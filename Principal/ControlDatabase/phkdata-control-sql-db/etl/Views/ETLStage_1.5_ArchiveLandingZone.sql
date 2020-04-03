
CREATE VIEW etl.[ETLStage_1.5_ArchiveLandingZone]
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
WHERE ETLStage = '1.5_ArchiveLandingZone'