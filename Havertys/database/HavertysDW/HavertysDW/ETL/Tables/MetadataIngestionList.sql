CREATE TABLE [ETL].[MetadataIngestionList] (
    [TableID]               INT            IDENTITY (1, 1) NOT NULL,
    [SourceSchemaTable]     VARCHAR (50)   NOT NULL,
    [TargetSchemaTable]   VARCHAR (50)   NOT NULL,
    [PKColumnList]          VARCHAR (300)  NOT NULL,
    [FilterColumn]          VARCHAR (50)   NULL,
    [FilterColumnDataType]  VARCHAR (25)   NULL,
    [FilterColumnValue]     VARCHAR (50)   NULL,
    [SelectQuery]           VARCHAR (5000) NOT NULL,
    [DataLakeStagingFolder] VARCHAR (1000) NOT NULL,
    [IntegrationRuntime]    VARCHAR (100)  NOT NULL,
    [SourceSystem]          VARCHAR (100)   NOT NULL,
    [TargetSystem]          VARCHAR (100)  NOT NULL,
    [SqlOverrideQuery]      VARCHAR (MAX)  NULL,
    [LoadCurated]           BIT            NOT NULL,
    [Disabled]              BIT            NOT NULL,
    CONSTRAINT [PK_ETL_MetadataIngestionList] PRIMARY KEY CLUSTERED ([TableID] ASC),
    CONSTRAINT [FK_ETL_MetadataIngestionList_SourceSystem] FOREIGN KEY ([SourceSystem]) REFERENCES [ETL].[DataSystems]([SystemName]),
    CONSTRAINT [FK_ETL_MetadataIngestionList_TargetSystem] FOREIGN KEY ([TargetSystem]) REFERENCES [ETL].[DataSystems]([SystemName]),
    CONSTRAINT [FK_ETL_MetadataIngestionList_IntegrationRuntime] FOREIGN KEY ([IntegrationRuntime]) REFERENCES [ETL].[IntegrationRuntimes]([IntegrationRuntime])
);

