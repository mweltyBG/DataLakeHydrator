

CREATE PROCEDURE [etl].[TaskAuditSuccess] (
	@TaskAuditKey INT
)
AS

UPDATE etl.TaskAudit
SET 
	IsRunning = 0,
	Status = 'Success',
	LastUpdated = GETUTCDATE(),
	EndTime = GETUTCDATE()
WHERE TaskAuditKey = @TaskAuditKey