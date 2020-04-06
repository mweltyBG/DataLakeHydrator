CREATE TABLE [ETL].[MetadataIngestionControlDateRanges] (
    [SourceTableID]                     INT          NOT NULL,
    [SourceSchemaTable]                 VARCHAR (50) NOT NULL,
    [SourceControlTable]                VARCHAR (50) NOT NULL,
    [SourceControlTableStartDateColumn] VARCHAR (50) NOT NULL,
    [SourceControlTableEndDateColumn]   VARCHAR (50) NOT NULL,
    [ControlProcessNumber]           INT          NOT NULL,
    [ControlStartDate]               DATETIME     NULL,
    [ControlEndDate]                 DATETIME     NULL,
    CONSTRAINT [PK_ETL_MetadataIngestionControlDateRanges] PRIMARY KEY CLUSTERED ([SourceTableID] ASC),
    FOREIGN KEY ([SourceTableID]) REFERENCES [ETL].[MetadataIngestionList] ([TableID])
);

