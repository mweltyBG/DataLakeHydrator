


CREATE PROCEDURE etl.GetTaskInfo 
	@TaskAuditKey INT
AS

SELECT 
	Task.TaskKey,	
	SourceType, 
	TargetDataLakeContainer, 
	TargetDataLakeFolder, 
	COALESCE(TargetDataLakeFileName, SourceTableName, 'import') AS TargetDataLakeFileName, 
	TargetFileCompressionType 
FROM etl.TaskAudit 
INNER JOIN etl.Task 
	ON TaskAudit.TaskKey = Task.TaskKey 
WHERE TaskAuditKey = @TaskAuditKey