CREATE TABLE [etl].[ADFConnections]
(
	[SourceDB] [nvarchar](255) NOT NULL PRIMARY KEY,
	[DatabaseType] NVARCHAR(255) NOT NULL,
	[ConnectionString] NVARCHAR(MAX) NULL,--not implemented at the moment
	[Category] NVARCHAR(255) NULL
)
