CREATE TABLE [etl].[TaskLimitAudit] (
    [TaskAuditKey]        INT            NOT NULL,
    [TaskKey]             INT            NOT NULL,
    [ExecutionSequence]   NVARCHAR (5)   NULL,
    [LimitAuditTimestamp] DATETIME       NULL,
    [LowerLimit]          NVARCHAR (255) NULL,
    [UpperLimit]          NVARCHAR (255) NULL,
    [LimitType]           NVARCHAR (255) NULL,
    [Offset]              NVARCHAR (255) NULL,
    [OffsetUnit]          NVARCHAR (255) NULL,
    [TimeZoneName]        VARCHAR (255)  NULL
);

