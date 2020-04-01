CREATE PROCEDURE [etl].[ADFAuditEnd]
(@ADFAuditKey        BIGINT, 
 @RowsRead           BIGINT, 
 @RowsCopied         BIGINT,
 @PipelineEndTime	 nvarchar(500)
)
AS
     UPDATE etl.ADFAudit
       SET  
           RowsRead = @RowsRead, 
           RowsCopied = @RowsCopied,
		   PipelineEndTime = TRY_CONVERT(DATETIME, TRY_CONVERT(DATETIME2, @PipelineEndTime)) -- David: need to find a better way than to have the pipeline pass a string datetime value
     WHERE ADFAuditKey = @ADFAuditKey
