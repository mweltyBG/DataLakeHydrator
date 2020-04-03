CREATE TABLE [etl].[ADFActions] (
    [ADFActionKey]                   INT             IDENTITY (1, 1) NOT NULL,
    [SourceDB]                       NVARCHAR (255)  NULL,
    [SourceSchemaName]               NVARCHAR (255)  NULL,
    [TableName]                      NVARCHAR (255)  NULL,
    [ColumnList]                     NVARCHAR (4000) NULL,
    [SourceContainer]                NVARCHAR (255)  NULL,
    [SourcePath]                     NVARCHAR (1000) NULL,
    [SourceFile]                     NVARCHAR (1000) NULL,
    [FileDelimiter]                  NVARCHAR (3)    NULL,
    [TargetSchemaName]               NVARCHAR (255)  NULL,
    [TargetTableName]                NVARCHAR (255)  NULL,
    [TargetContainer]                NVARCHAR (255)  NULL,
    [TargetPath]                     NVARCHAR (1000) NULL,
    [TargetFile]                     NVARCHAR (1000) NULL,
    [StoredProcedureName]            NVARCHAR (255)  NULL,
    [CustomPipelineName]             NVARCHAR (255)  NULL,
    [DataLoadType]                   NVARCHAR (255)  NULL,
    [SourceQueryFromClause]          NVARCHAR (4000) NULL,
    [QueryEnd]                       NVARCHAR (255)  NULL,
    [IncrementDatatype]              NVARCHAR (255)  NULL,
    [IncrementTableName]             NVARCHAR (255)  NULL,
    [IncrementColumnName]            NVARCHAR (255)  NULL,
    [LowerLimit]                     NVARCHAR (255)  NULL,
    [UpperLimit]                     NVARCHAR (255)  NULL,
    [LimitType]                      NVARCHAR (255)  NULL,
    [Offset]                         NVARCHAR (255)  NULL,
    [OffsetUnit]                     NVARCHAR (255)  NULL,
    [TimeZoneName]                   NVARCHAR (255)  NULL,
    [DisableLimitUpdate]             BIT              DEFAULT ((0)) NOT NULL,
    [ADFAuditKey_LimitUpdate]        BIGINT          NULL,
    [LastUpdateDatetime_LimitUpdate] DATETIME        NULL,
    [LatestIncrementQuery]           NVARCHAR (4000) NULL,
    [NeedsSelectDistinct]            NVARCHAR (1)    NULL,
    [ETLStage]                       NVARCHAR (255)  NULL,
    [EnableAction]                   BIT             DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_etl_ADFActions] PRIMARY KEY CLUSTERED ([ADFActionKey] ASC)
);








