CREATE TABLE [etl].[JobAudit] (
    [JobAuditKey]     INT            IDENTITY (1, 1) NOT NULL,
    [JobKey]          INT            NULL,
    [StartTime]       DATETIME       NULL,
    [RestartTime]     DATETIME       NULL,
    [EndTime]         DATETIME       NULL,
    [Status]          NVARCHAR (50)  NULL,
    [DataFactoryName] NVARCHAR (200) NULL,
    [PipelineRunID]  NVARCHAR (50)  NULL,
    CONSTRAINT [PK_JobAudit] PRIMARY KEY CLUSTERED ([JobAuditKey] ASC)
);

