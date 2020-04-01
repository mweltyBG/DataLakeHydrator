CREATE PROCEDURE [etl].[ADFAuditUpdate]
(
	@ADFAuditKey BIGINT, 
	@ETLStage nvarchar(50) = NULL,
	@SourceDB NVARCHAR(255) = NULL,
	@SourceTableName nvarchar(500) = NULL,
	@TableName nvarchar(500) = NULL,
	@DataLakeFilePath nvarchar(4000) = NULL,
	@StoredProcedureName nvarchar(500) = NULL,
	@Status	 nvarchar(500),
	@RowsRead bigint = NULL,
	@RowsCopied bigint = NULL,
	@RowsSkipped bigint = NULL,
	@RowsInserted bigint = NULL,
	@RowsUpdated BIGINT = NULL,
	@RowsDeleted BIGINT = NULL,
	@EndPipeline BIT = 0
)
AS
BEGIN
    UPDATE etl.ADFAudit
    SET  
		[Status] = @Status,
		ETLStage = ISNULL(@ETLStage, ETLStage),
		SourceDB = ISNULL(@SourceDB, SourceDB),
		SourceTableName = ISNULL(@SourceTableName, SourceTableName),
		TableName = ISNULL(@TableName, TableName),
		DataLakeFilePath = ISNULL(@DataLakeFilePath, DataLakeFilePath),
		StoredProcedureName = ISNULL(@StoredProcedureName,StoredProcedureName),
		RowsRead = ISNULL(@RowsRead, RowsRead),
		RowsCopied = ISNULL(@RowsCopied, RowsCopied),
		RowsSkipped = ISNULL(@RowsSkipped, RowsSkipped),
		RowsInserted = ISNULL(@RowsInserted, RowsInserted),
		RowsUpdated = ISNULL(@RowsUpdated, RowsUpdated),
		RowsDeleted = ISNULL(@RowsDeleted, RowsDeleted),
		PipelineEndTime = CASE WHEN @EndPipeline = 1 THEN SYSUTCDATETIME() ELSE PipelineEndTime END,
		LastUpdate = SYSUTCDATETIME()
    WHERE 
		ADFAuditKey = @ADFAuditKey
END