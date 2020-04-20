

CREATE PROCEDURE [etl].[TaskAuditFailure] (
	@TaskAuditKey INT
)
AS

UPDATE etl.TaskAudit
SET 
	IsRunning = 0,
	Status = 'Failed',
	LastUpdated = GETUTCDATE(),
	EndTime = GETUTCDATE()
WHERE TaskAuditKey = @TaskAuditKey