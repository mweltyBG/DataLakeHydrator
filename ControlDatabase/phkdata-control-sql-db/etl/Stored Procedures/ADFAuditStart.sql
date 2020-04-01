



CREATE PROCEDURE [etl].[ADFAuditStart] 
(
	@DataFactoryName nvarchar(50), 		
	@PipelineName nvarchar(50), 			
	@PipelineRunID uniqueidentifier, 		
	@PipelineTriggerName nvarchar(50), 	
	@PipelineTriggerID nvarchar(36) = NULL, 	
	@PipelineTriggerType nvarchar(50),
	@ParentADFAuditKey BIGINT = NULL,
	@ADFActionKey BIGINT = NULL
)
AS
BEGIN
	INSERT INTO etl.ADFAudit 
	(
		ParentADFAuditKey,
		ADFActionKey,
		DataFactoryName, 		
		PipelineName, 			
		PipelineRunID,
		PipelineStartTime,
		PipelineTriggerName, 	
		PipelineTriggerID, 	
		PipelineTriggerType,
		[Status],
		LastUpdate
	)
	VALUES
	(
	     @ParentADFAuditKey,
		@ADFActionKey,
		@DataFactoryName, 		
		@PipelineName, 			
		@PipelineRunID, 		
		SYSUTCDATETIME(),
		@PipelineTriggerName, 	
		@PipelineTriggerID, 	
		@PipelineTriggerType,
		'Started',
		SYSUTCDATETIME()
	);

	SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS ADFAuditKey;
END
