/*
This holds a list of integration runtimes, eg AutoResolveIntegrationRuntime 
*/
CREATE TABLE [ETL].[IntegrationRuntimes]
(
	[IntegrationRuntime] VARCHAR(100) NOT NULL,
	[Location] VARCHAR(1000) NULL, -- for descriptive purposes here.  We're not planning on setting them UP with output from the DB at this time.
	CONSTRAINT [PK_ETL_IntegrationRuntimes] PRIMARY KEY CLUSTERED (IntegrationRuntime)
)
