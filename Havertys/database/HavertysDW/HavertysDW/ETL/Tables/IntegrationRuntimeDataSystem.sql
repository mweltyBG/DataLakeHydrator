CREATE TABLE [ETL].[IntegrationRuntimeDataSystem]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	[RuntimeName] VARCHAR(100) NOT NULL,
	[SystemName] VARCHAR(100) NOT NULL,
	[Priority] INT DEFAULT 99 NOT NULL, -- if a system can be accessed by more than 1 runtime, this provides priority on which runtime it should choose
	CONSTRAINT [PK_ETL_IntegrationRuntimeDataSystem] PRIMARY KEY CLUSTERED (RuntimeName, SystemName)
)
