CREATE TABLE [etl].[TaskAudit] (
    [TaskAuditKey] INT             IDENTITY (1, 1) NOT NULL,
    [JobAuditKey]  INT             NULL,
    [TaskKey]      INT             NULL,
    [StartTime]    DATETIME        NULL,
    [EndTime]      DATETIME        NULL,
    [RowsRead]     BIGINT          NULL,
    [RowsSkipped]  BIGINT          NULL,
    [RowsCopied]   BIGINT          NULL,
    [RowsInserted] BIGINT          NULL,
    [RowsUpdated]  BIGINT          NULL,
    [RowsDeleted]  BIGINT          NULL,
    [Status]       NVARCHAR (200)  NULL,
    [IsRunning]    BIT             NULL,
    [LastUpdated]  DATETIME        NULL,
    [DebugString]  NVARCHAR (4000) NULL,
    [DataFactoryName] NVARCHAR (200) NULL,
    [PipelineRunID]   NVARCHAR (50)   NULL,
    CONSTRAINT [PK_TaskAuditKey] PRIMARY KEY CLUSTERED ([TaskAuditKey] ASC)
);

