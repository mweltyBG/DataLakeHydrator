



CREATE VIEW [etl].[ADFActionsLastStatus] AS

SELECT
    ADFActions.ADFActionKey
,   ADFActions.ETLStage
,   ActionName =
    CASE
	   WHEN ADFActions.ETLStage = '1_HydrateLake' THEN CASE WHEN ADFActions.SourceDB = 'csv' THEN SourceFile ELSE ADFActions.SourceDB + '.' + SourceSchemaName + '.' + ADFActions.TableName END
	   WHEN ADFActions.ETLStage = '1.5_ArchiveLandingZone' THEN TargetContainer + '/' + TargetPath + CASE WHEN TargetPath LIKE '%/' THEN '' ELSE '/' END + TargetFile
	   WHEN ADFActions.ETLStage = '3_StageTables' THEN TargetSchemaName + '.' + TargetTableName
	   WHEN ADFActions.ETLStage = '2_ProcessCuratedData' THEN TargetContainer + '/' + TargetPath + CASE WHEN TargetPath LIKE '%/' THEN '' ELSE '/' END + TargetFile
	   WHEN ADFActions.ETLStage IN ('3.1_ProcessDimensionTables', '3.3_ProcessBridgeTables', '3.5_ProcessFactTables') THEN ADFActions.StoredProcedureName

	   WHEN ADFActions.ETLStage = '4_Databricks' THEN CustomPipelineName
    END

,   EnableAction

,   LastRunStatus = ADFAudit.Status
,   LastRunErrorMessage = Errors.ErrorMessage
,   ADFAudit.LastUpdate
,   ADFAudit.ADFAuditKey
,   ADFAudit.ParentADFAuditKey
,   ADFAudit.DataFactoryName
,   ADFAudit.PipelineName
,   PipelineDurationSeconds = DATEDIFF(SECOND, PipelineStartTime, PipelineEndTime)

,   ADFAudit.RowsRead
,   LowerLimit
,   UpperLimit
,   ADFAuditKey_LimitUpdate
,   LastUpdateDatetime_LimitUpdate

FROM etl.ADFActions
OUTER APPLY (SELECT TOP 1 * FROM etl.ADFAudit WHERE ADFActions.ETLStage = ADFAudit.ETLStage 
    AND 
    ( ADFActions.ADFActionKey = ADFAudit.ADFActionKey
    -- these are methods we had to use before ADFActionKey got added to the audit. once this change has been deployed to production, we can remove the two lines below
    OR ADFActions.SourceDB + '.' + SourceSchemaName + '.' + ADFActions.TableName = ADFAudit.SourceDB + '.' + ADFAudit.SourceTableName -- find the HydrateLake items
    OR ADFActions.TargetSchemaName + '.' + ADFActions.TargetTableName = ADFAudit.TableName -- find the 1.5_StageTables itmes

    )
    
    ORDER BY ADFAudit.LastUpdate DESC) ADFAudit
OUTER APPLY (SELECT TOP 1 ErrorMessage FROM etl.ADFErrors WHERE ADFErrors.ADFAuditKey = ADFAudit.ADFAuditKey) Errors