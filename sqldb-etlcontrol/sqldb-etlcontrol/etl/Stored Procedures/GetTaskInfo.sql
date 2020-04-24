


CREATE PROCEDURE etl.GetTaskInfo 
	@TaskAuditKey INT
AS

SELECT 
	Task.TaskKey,	
	Task.SourceType,
	Task.SourceTableName, 
	Task.TargetDataLakeContainer, 
	Task.TargetDataLakeFolder, 
	COALESCE(Task.TargetDataLakeFileName, Task.SourceTableName, 'data') AS TargetDataLakeFileName, 
	Task.TargetFileCompressionType,
	Task.LoadCuratedModel,
	Task.CustomShufflePartitions,
	Task.CuratedDBName,
	Task.CuratedTableName
FROM etl.TaskAudit 
INNER JOIN etl.Task 
	ON TaskAudit.TaskKey = Task.TaskKey 
WHERE TaskAuditKey = @TaskAuditKey