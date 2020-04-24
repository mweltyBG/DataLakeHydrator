
-- =============================================
-- Author:		David Barnhart
-- Create date: 2020-04-23
-- Description:	Returns a two-column table of tokens and their literal value for the etl.GetTaskQuery proc
-- =============================================
CREATE FUNCTION [etl].[GetLiteralFromToken]
(
	@TaskAuditKey INT
)
RETURNS 
@returnTable TABLE 
(
	Token NVARCHAR(2000),
	LiteralValue NVARCHAR(2000)
)
AS
BEGIN
	-- dates
	-- this one will be the default date format if not format is specified:
	INSERT INTO @returnTable VALUES ('ETLDate', CONVERT(NVARCHAR, GETUTCDATE(), 23) + 'T' + REPLACE(CONVERT(NVARCHAR, GETUTCDATE(), 108), ':', '')) 

	INSERT INTO @returnTable VALUES ('ETLDate:YYYYmmDD', CONVERT(NVARCHAR, GETUTCDATE(), 112))
	INSERT INTO @returnTable VALUES ('ETLDate:YYYYmmDDHHMMSS', CONVERT(NVARCHAR, GETUTCDATE(), 112) + REPLACE(CONVERT(NVARCHAR, GETUTCDATE(), 108), ':', '')) 
	INSERT INTO @returnTable VALUES ('ETLDate:YYYY-mm-DDTHHMMSS', CONVERT(NVARCHAR, GETUTCDATE(), 23) + 'T' + REPLACE(CONVERT(NVARCHAR, GETUTCDATE(), 108), ':', '')) 

	-- add the TaskAuditKey and other keys
	INSERT INTO @returnTable VALUES ('TaskAuditKey', CONVERT(NVARCHAR, @TaskAuditKey))
	INSERT INTO @returnTable SELECT TOP 1 'JobAuditKey', CONVERT(NVARCHAR, JobAuditKey) FROM etl.TaskAudit WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'JobKey', CONVERT(NVARCHAR, JobAudit.JobKey) FROM etl.TaskAudit INNER JOIN etl.JobAudit ON TaskAudit.JobAuditKey = JobAudit.JobAuditKey WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'TaskKey', CONVERT(NVARCHAR, TaskKey) FROM etl.TaskAudit WHERE TaskAuditKey = @TaskAuditKey
	
	-- values off the Task record
	INSERT INTO @returnTable SELECT TOP 1 'SourceName', CONVERT(NVARCHAR, Task.SourceName) FROM etl.TaskAudit INNER JOIN etl.Task ON TaskAudit.TaskKey = Task.TaskKey WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'SourceType', CONVERT(NVARCHAR, Task.SourceType) FROM etl.TaskAudit INNER JOIN etl.Task ON TaskAudit.TaskKey = Task.TaskKey WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'SourceDatabaseName', CONVERT(NVARCHAR, Task.SourceDatabaseName) FROM etl.TaskAudit INNER JOIN etl.Task ON TaskAudit.TaskKey = Task.TaskKey WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'SourceSchemaName', CONVERT(NVARCHAR, Task.SourceSchemaName) FROM etl.TaskAudit INNER JOIN etl.Task ON TaskAudit.TaskKey = Task.TaskKey WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'SourceTableName', CONVERT(NVARCHAR, Task.SourceTableName) FROM etl.TaskAudit INNER JOIN etl.Task ON TaskAudit.TaskKey = Task.TaskKey WHERE TaskAuditKey = @TaskAuditKey
	INSERT INTO @returnTable SELECT TOP 1 'AdvancedConfigName', CONVERT(NVARCHAR, Task.AdvancedConfigName) FROM etl.TaskAudit INNER JOIN etl.Task ON TaskAudit.TaskKey = Task.TaskKey WHERE TaskAuditKey = @TaskAuditKey

	-- replace null with some sort of string value
	UPDATE @returnTable SET LiteralValue = ISNULL(LiteralValue, 'NULL')

	RETURN 
END