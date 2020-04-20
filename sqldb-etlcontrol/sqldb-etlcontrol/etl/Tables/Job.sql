CREATE TABLE [etl].[Job] (
    [JobKey]         INT            IDENTITY (1, 1) NOT NULL,
    [JobName]        NVARCHAR (500) NULL,
    [JobDescription] NVARCHAR (500) NULL,
    CONSTRAINT [PK_etl_Job] PRIMARY KEY CLUSTERED ([JobKey] ASC)
);

