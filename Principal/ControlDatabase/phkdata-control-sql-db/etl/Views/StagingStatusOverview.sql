
 CREATE VIEW [etl].[StagingStatusOverview] AS

SELECT

    StagingTableName = COALESCE(HydrateLake.StagingTableName, ArchiveLandingZone.StagingTableName, ProcessCurated.StagingTableName, StageToDataWarehouse.ActionName)

,   HydrateLakeADFActionKey = HydrateLake.ADFActionKey
,   HydrateLakeEnabled = HydrateLake.EnableAction
,   HydrateLakeLastRunStatus = HydrateLake.LastRunStatus
,   HydrateLakeLastUpdate = HydrateLake.LastUpdate

,   ArchiveLandingZoneActionKey = ArchiveLandingZone.ADFActionKey
,   ArchiveLandingZoneEnabled = ArchiveLandingZone.EnableAction
,   ArchiveLandingZoneLastRunStatus = ArchiveLandingZone.LastRunStatus
,   ArchiveLandingZoneLastUpdate = ArchiveLandingZone.LastUpdate

,   ProcessCuratedADFActionKey = ProcessCurated.ADFActionKey
,   ProcessCuratedEnabled = ProcessCurated.EnableAction
,   ProcessCuratedLastRunStatus = ProcessCurated.LastRunStatus
,   ProcessCuratedLastUpdate = ProcessCurated.LastUpdate

,   StageToDataWarehouseADFActionKey = StageToDataWarehouse.ADFActionKey
,   StageToDataWarehouseEnabled = StageToDataWarehouse.EnableAction
,   StageToDataWarehouseLastRunStatus = StageToDataWarehouse.LastRunStatus
,   StageToDataWarehouseLastUpdate = StageToDataWarehouse.LastUpdate



-- stage_p2000_BFP_B2000.BFP_DETALLE_PAQUETES_CAPTURA
FROM

(SELECT ADFActionKey, ActionName, EnableAction, LastRunStatus, LastUpdate,
    StagingTableName =
	   CASE
		  WHEN ActionName LIKE 'p2000.%' THEN REPLACE(ActionName, 'p2000.', 'stage_p2000_')
		  WHEN ActionName LIKE 'siif.dbo.%' THEN REPLACE(ActionName, 'siif.dbo.', 'stage_SIIF.')
		  WHEN ActionName LIKE 'cliente.dbo.%' THEN REPLACE(ActionName, 'cliente.dbo.', 'stage_cliente.')
	   END
FROM etl.ADFActionsLastStatus
WHERE ETLStage = '1_HydrateLake') HydrateLake

FULL OUTER JOIN
    (SELECT ADFActionKey, ActionName, EnableAction, LastRunStatus, LastUpdate,
	   StagingTableName =
		  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(ActionName, LEN(ActionName) - CHARINDEX('/', REVERSE(ActionName))), 'raw/', ''), 'p2000/', 'stage_p2000_'), 'cliente/dbo', 'stage_cliente'), 'siif/dbo', 'stage_siif'), '/', '.')

    FROM etl.ADFActionsLastStatus
    WHERE ETLStage = '1.5_ArchiveLandingZone') ArchiveLandingZone
	   ON HydrateLake.StagingTableName = ArchiveLandingZone.StagingTableName

FULL OUTER JOIN
    (SELECT ADFActionKey, ActionName, EnableAction, LastRunStatus, LastUpdate,
	   StagingTableName =
		  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(ActionName, LEN(ActionName) - CHARINDEX('/', REVERSE(ActionName))), 'curated/', ''), 'p2000/', 'stage_p2000_'), 'cliente/dbo', 'stage_cliente'), 'siif/dbo', 'stage_siif'), '/', '.')
    FROM etl.ADFActionsLastStatus
    WHERE ETLStage = '2_ProcessCuratedData') ProcessCurated
	   ON COALESCE(HydrateLake.StagingTableName, ArchiveLandingZone.StagingTableName) = ProcessCurated.StagingTableName

FULL OUTER JOIN
    (SELECT ADFActionKey, ActionName, EnableAction, LastRunStatus, LastUpdate
    FROM etl.ADFActionsLastStatus
    WHERE ETLStage = '3_StageTables') StageToDataWarehouse

	   ON COALESCE(HydrateLake.StagingTableName, ArchiveLandingZone.StagingTableName, ProcessCurated.StagingTableName) = StageToDataWarehouse.ActionName


--OUTER APPLY (SELECT TOP 1 * FROM etl.ADFAudit WHERE PipelineName = 'pl_copy_landingzone_to_raw' AND COALESCE(HydrateLake.StagingTableName, HydrateLake.ActionName) = ADFAudit.TableName ORDER BY ADFAuditKey DESC) CopyToRaw