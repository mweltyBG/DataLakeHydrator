


CREATE PROCEDURE [etl].[TaskAuditStart] (
	@TaskAuditKey INT,
	@DataFactoryName NVARCHAR(200) = 'datafactory',
	@PipelineRunID NVARCHAR(50) = ''
)
AS

DECLARE @taskAlreadyRunning BIT = 0
SET @taskAlreadyRunning = (SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END FROM etl.TaskAudit WHERE TaskAuditKey = @TaskAuditKey AND IsRunning = 1)

IF @taskAlreadyRunning = 1
BEGIN
	DECLARE @ErrorMessage NVARCHAR(2048);
	SET @ErrorMessage =  'Error: TaskAuditKey "' + CONVERT(VARCHAR(5), @TaskAuditKey) + '" is already marked as running in the etl.TaskAudit table (IsRunning = 1)';
	THROW 50000, @ErrorMessage, 1;
END
ELSE
BEGIN
	UPDATE etl.TaskAudit SET IsRunning = 1, StartTime = GETUTCDATE(), Status = 'Execution started', DataFactoryName = @DataFactoryName, PipelineRunID = @PipelineRunID WHERE TaskAuditKey = @TaskAuditKey

	SELECT TOP 1 
		Task.TaskKey
	,	ISNULL(IsAdvancedTask, 0) AS IsAdvancedTask
	,	AdvancedConfigName
	,	AdvancedTaskKey
	,	AdvancedNextTaskKey
	FROM etl.Task
	INNER JOIN etl.TaskAudit
		ON Task.TaskKey = TaskAudit.TaskKey
	WHERE TaskAuditKey = @TaskAuditKey
END