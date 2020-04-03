CREATE TABLE [etl].[ADFErrors] (
    [ADFAuditKey]   BIGINT         NOT NULL,
    [ErrorMessage]  NVARCHAR (MAX) NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [EventType]     NVARCHAR (MAX) NULL,
    [Category]      NVARCHAR (MAX) NULL,
    [ExceptionType] NVARCHAR (MAX) NULL,
    [Source]        NVARCHAR (MAX) NULL,
    [StackTrace]    NVARCHAR (MAX) NULL
);

