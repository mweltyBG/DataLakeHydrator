CREATE TABLE [etl].[KeyValueConfig] (
    [ConfigKey]   NVARCHAR (200)  NOT NULL,
    [ConfigValue] NVARCHAR (2000) NULL,
    CONSTRAINT [PK_KeyValueConfig] PRIMARY KEY CLUSTERED ([ConfigKey] ASC)
);

