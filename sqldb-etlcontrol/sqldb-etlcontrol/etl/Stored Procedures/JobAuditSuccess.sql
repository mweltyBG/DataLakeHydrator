


CREATE PROCEDURE [etl].[JobAuditSuccess] (
	@JobAuditKey INT
)
AS

UPDATE etl.JobAudit
SET 
	Status = 'Success',
	EndTime = GETUTCDATE()
WHERE JobAuditKey = @JobAuditKey