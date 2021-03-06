﻿CREATE TABLE [etl].[Task] (
    [TaskKey]                              INT             IDENTITY (1, 1) NOT NULL,
    [IsAdvancedTask]                       BIT             NULL,
    [AdvancedConfigName]                   NVARCHAR (200)  NULL,
    [AdvancedTaskKey]                      INT             NULL,
    [AdvancedNextTaskKey]                  INT             NULL,
    [SourceName]                           NVARCHAR (200)  NULL,
    --[SourceType]                           NVARCHAR (200)  NULL, -- this defaults to SQLServer, and can be overridden in etl.Source
    --[SourceDatabaseName]                   NVARCHAR (200)  NULL, -- this is specified in the connection string in the connection string secret
    [SourceSchemaName]                     NVARCHAR (200)  NULL,
    [SourceTableName]                      NVARCHAR (200)  NULL,
    [SourceColumnList]                     NVARCHAR (4000) NULL,
    [PrimaryKeyColumnList]                 NVARCHAR (4000) NULL,
    [SourceQuery]                          NVARCHAR (4000) NULL,
    [SourceWhereClause]                    NVARCHAR (4000) NULL,
    [SqlOverrideQuery]                     NVARCHAR (4000) NULL,
    [IsSelectDistinctFlag]                 BIT             NULL,
    [DataLakeTransientLandingAreaPath]     NVARCHAR (2000) NULL,
    [DataLakeTransientLandingAreaFileName] NVARCHAR (2000) NULL,
    [DataLakePersistedRawPath]             NVARCHAR (2000) NULL,
    [DataLakePersistedRawFileName]         NVARCHAR (2000) NULL,
    [DataLakeCuratedPath]                  NVARCHAR (2000) NULL,
    [DataLakeCuratedFileName]              NVARCHAR (2000) NULL,
    [IsIncrementalFlag]                    BIT             NULL,
    [IncrementDatatype]                    NVARCHAR (200)  NULL,
    [IncrementTableName]                   NVARCHAR (200)  NULL,
    [IncrementColumnName]                  NVARCHAR (200)  NULL,
    [LowerLimit]                           NVARCHAR (200)  NULL,
    [UpperLimit]                           NVARCHAR (200)  NULL,
    [LimitType]                            NVARCHAR (200)  NULL,
    [Offset]                               NVARCHAR (200)  NULL,
    [OffsetUnit]                           NVARCHAR (200)  NULL,
    [TimeZoneName]                         NVARCHAR (200)  NULL,
    [DataIntegrationUnits]                 NVARCHAR (200)  DEFAULT (N'Auto') NULL,
    [DegreeOfParallelism]                  INT             DEFAULT ((1)) NULL,
    [DisableLimitUpdate]                   BIT             DEFAULT ((0)) NOT NULL,
    [DisableAction]                        BIT             DEFAULT ((0)) NULL,
    CONSTRAINT [PK_etl_Task] PRIMARY KEY CLUSTERED ([TaskKey] ASC)
);





