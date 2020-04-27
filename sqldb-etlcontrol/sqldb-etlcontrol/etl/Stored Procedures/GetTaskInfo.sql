﻿


CREATE PROCEDURE etl.GetTaskInfo 
	@TaskAuditKey INT
AS

SELECT 
	TaskAudit.TaskAuditKey,
	Task.TaskKey,	
	Task.SourceType,
	Task.SourceTableName, 
	Task.TargetDataLakeContainer, 
	Task.TargetDataLakeFolder, 
	COALESCE(Task.TargetDataLakeFileName, Task.SourceTableName, 'data') AS TargetDataLakeFileName, 
	Task.TargetFileCompressionType,
	Task.IsIncrementalFlag,
	Task.LoadRawReplica,
	Task.CustomShufflePartitions,
	Task.RawReplicaDBName,
	Task.RawReplicaTableName,
	Task.PrimaryKeyColumnList
FROM etl.TaskAudit 
INNER JOIN etl.Task 
	ON TaskAudit.TaskKey = Task.TaskKey 
WHERE TaskAuditKey = @TaskAuditKey