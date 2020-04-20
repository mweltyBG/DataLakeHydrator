


CREATE PROCEDURE [etl].[JobAuditFailure] (
	@JobAuditKey INT
)
AS

UPDATE etl.JobAudit
SET 
	Status = 'Failed',
	EndTime = GETUTCDATE()
WHERE JobAuditKey = @JobAuditKey