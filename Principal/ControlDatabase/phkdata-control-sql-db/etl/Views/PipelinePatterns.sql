CREATE VIEW etl.PipelinePatterns 
AS
WITH CTE AS
(
SELECT 
	CASE 
		WHEN DataLoadType = 'StoredProcedure' THEN 'azure'
		WHEN SourceDB IS NULL THEN 'azure'
		ELSE SourceDB
	END as SourceDB, 
	LOWER(DataLoadType) as DataLoadType, 
	CAST(MIN(ADFActionKey) as varchar(50)) AS DefaultADFActionKey
FROM etl.ADFActions 
WHERE 
	EnableAction = 1 
	AND DataLoadType <> 'CustomPipeline'
GROUP BY 
	CASE 
		WHEN DataLoadType = 'StoredProcedure' THEN 'azure'
		WHEN SourceDB IS NULL THEN 'azure'
		ELSE SourceDB
	END,
	DataLoadType
)
SELECT
	PP.SourceDB,
	PP.DataLoadType,
	PP.DefaultADFActionKey,
	CASE 
		WHEN PP.DataLoadType = 'StoredProcedure' THEN 'v2_Template_pl_exec_storedprocedure.biml'
		WHEN AC.Category = 'file' THEN 'v2_Template_pl_copy_' + PP.DataLoadType + '_file.biml'
		ELSE 'v2_Template_pl_copy_' + PP.DataLoadType + '_table.biml'
	END as TemplateName,
	CASE 
		WHEN PP.DataLoadType = 'StoredProcedure' THEN 'pl_exec_storedprocedure_azure'
		WHEN AC.Category = 'file' THEN 'pl_copy_' + PP.DataLoadType + '_file_' + PP.SourceDB
		ELSE 'pl_copy_' + PP.DataLoadType + '_table_' + PP.SourceDB
	END as PipelineName,
	'pl_loop_'+PP.DataLoadType+'_'+PP.SourceDB as LoopPipelineName,
	AC.DatabaseType + 'Source' as SourceType
FROM
	CTE as PP
	JOIN etl.ADFConnections as AC
		ON PP.SourceDB = AC.SourceDB
