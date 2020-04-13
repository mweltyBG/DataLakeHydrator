/*
ETL.DataSources

Defines the logical source/target data systems (as if the connections were not parameterized).
Contains enough information to look up the appropriate secrets in Azure Key Vault...
Except for the associated integration runtimes, because we'll need at least the Azure Storage
  to be able to hit multiple IRs
*/
CREATE TABLE [ETL].[DataSystems]
(
	[SystemName] VARCHAR(100) NOT NULL, -- Logical data source name, eg if there was an on-prem SQL Server Database called CustomerX, then this might be 'CustomerX'
	[SystemType] VARCHAR(100) NOT NULL, -- corresponds to DB2, SQLServer, AzureSQL, Oracle, etc.
	[AuthenticationMethod] VARCHAR(100) NULL,
	CONSTRAINT [PK_ETL_DataSystem] PRIMARY KEY CLUSTERED ([SystemName])
)
