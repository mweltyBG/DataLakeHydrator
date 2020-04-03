CREATE VIEW etl.MasterPipelines
AS
WITH CTE0 AS
(
SELECT DISTINCT
	CASE 
		WHEN DataLoadType = 'StoredProcedure' THEN 'azure'
		WHEN SourceDB IS NULL THEN 'azure'
		ELSE SourceDB
	END as SourceDB,
	LOWER(DataLoadType) as DataLoadType,
	ETLStage
FROM	
	etl.ADFActions
WHERE
	EnableAction = 1
),
CTE1 AS
(
SELECT
	'pl_master' as OverallMasterPipelineName,
	'pl_' +ETLStage as StageMasterPipelineName,
	'pl_'+ETLStage+'_'+SourceDB as SourceStageMasterPipelineName,
	'pl_loop_'+DataLoadType+'_'+SourceDB as PipelineName,
	ETLStage,
	'Normal' as LoadType
FROM
	CTE0
WHERE
	DataLoadType <> 'onetime'
UNION ALL
SELECT
	'pl_master_onetime' as OverallMasterPipelineName,
	'pl_' +ETLStage + '_onetime' as StageMasterPipelineName,
	'pl_'+ETLStage+'_'+SourceDB + '_onetime' as SourceStageMasterPipelineName,
	'pl_loop_'+DataLoadType+'_'+SourceDB as PipelineName,
	ETLStage,
	'onetime' as LoadType
FROM
	CTE0
WHERE
	DataLoadType = 'onetime'
),
CTE2(MasterPipelineName, PipelineName, ETLStage, MasterLevel) AS
(
SELECT 
	SourceStageMasterPipelineName, PipelineName, ETLStage, 0
FROM
	CTE1
UNION ALL
SELECT DISTINCT
	StageMasterPipelineName, SourceStageMasterPipelineName, ETLStage, 1
FROM
	CTE1
UNION ALL
SELECT DISTINCT
	OverallMasterPipelineName, StageMasterPipelineName, '', 2
FROM
	CTE1
)
SELECT 
	MasterPipelineName,
	MasterLevel,
	ETLStage,
	STRING_AGG(PipelineName,',') WITHIN GROUP (ORDER BY PipelineName) as Pipelines
FROM
	CTE2
GROUP BY 
	MasterPipelineName,
	MasterLevel,
	ETLStage