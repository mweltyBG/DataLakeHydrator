CREATE TABLE [etl].[Source] (
    [SourceName]             NVARCHAR (200) NOT NULL,
    [SourceType]             NVARCHAR (200) DEFAULT ('SQLServer') NULL,
    [AuthenticationType]     NVARCHAR (200) NULL,
    [UserName]               NVARCHAR (200) NULL,
    [IntegrationRuntimeName] NVARCHAR (200) NULL,
    [ConnectionStringSecret] NVARCHAR (200) NULL,
    [PasswordSecret]         NVARCHAR (200) NULL,
    CONSTRAINT [PK_ETL_SOURCES] PRIMARY KEY CLUSTERED ([SourceName] ASC),
    CONSTRAINT [CK_ETL_Sources_AuthenticationType] CHECK ([AuthenticationType] IS NULL OR ([AuthenticationType]='WINDOWS' OR [AuthenticationType]='SQL')),
    CONSTRAINT [CK_ETL_Sources_Sourcetype] CHECK ([SourceType] IS NULL OR ([SourceType]='Oracle' OR [SourceType]='AzureSQL' OR [SourceType]='SQLServer'))
);

