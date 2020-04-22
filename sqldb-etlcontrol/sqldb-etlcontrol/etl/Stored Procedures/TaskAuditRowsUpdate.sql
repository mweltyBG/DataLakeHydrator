

CREATE OR ALTER PROCEDURE [etl].[TaskAuditRowsUpdate] (
	@TaskAuditKey INT, @RowsRead BIGINT, @RowsCopied BIGINT
)
AS

UPDATE etl.TaskAudit
SET 
	RowsRead = @RowsRead,
	RowsCopied = @RowsCopied,
	LastUpdated = GETUTCDATE()	
WHERE TaskAuditKey = @TaskAuditKey