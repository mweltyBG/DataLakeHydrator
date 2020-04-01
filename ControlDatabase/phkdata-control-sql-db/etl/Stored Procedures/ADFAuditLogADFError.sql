


CREATE PROC [etl].[ADFAuditLogADFError]
(
    @ADFAuditKey BIGINT,
--    @PipelineRunID UNIQUEIDENTIFIER,
    @PipelineRunID NVARCHAR(500),

    @Code NVARCHAR(MAX),
    @ErrorMessage NVARCHAR(MAX),
    @EventType NVARCHAR(MAX),
    @Category NVARCHAR(MAX),
    @ExceptionType NVARCHAR(MAX),
    @Source NVARCHAR(MAX),
    @StackTrace NVARCHAR(MAX)


)
AS
    /*
	   Ideally we would know the ADFAuditKey when the error occurs. However, in some situations this may be difficult.
	   For instance, if we are capturing any and all error messages from an "execute pipeline" activity, then we do not know the child pipeline's ADFAuditKey.
	   Instead we only know the PipelineRunID. So if ADFAuditKey is null but a PipelineRunID is supplied, try to find the ADFAuditKey via the PipelineRunID

	   If Microsoft eventually offers better error-handling functionality in ADF we may no longer need this workaround

    */

    IF @ADFAuditKey IS NULL
	   SELECT TOP 1 @ADFAuditKey = ADFAuditKey FROM etl.ADFAudit WHERE PipelineRunID = TRY_CONVERT(uniqueidentifier, @PipelineRunID)
--	   SET @ADFAuditKey = 9999

    INSERT INTO etl.ADFErrors (ADFAuditKey, Code, ErrorMessage, EventType, Category, ExceptionType, Source, StackTrace) VALUES (@ADFAuditKey, @Code, @ErrorMessage, @EventType, @Category, @ExceptionType, @Source, @StackTrace)

    -- also make sure that the ADFAudit row gets marked as failed
    UPDATE etl.ADFAudit 
    SET 
	   Status = 'Failed'
    ,   LastUpdate = SYSUTCDATETIME()
    ,   PipelineEndTime = SYSUTCDATETIME()
    WHERE ADFAuditKey = @ADFAuditKey