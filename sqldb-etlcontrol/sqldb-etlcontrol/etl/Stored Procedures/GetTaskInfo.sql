




CREATE PROCEDURE [etl].[GetTaskInfo] 
	@TaskAuditKey INT
AS

/*
Target Notes
There are three places that a file could go within the datalake:
	1. The transient landing area. This is overwritten during each ETL execution, hence the "transience"
	2. Persisted raw area. This is where data is persisted long-term, usually in a folder or file that contains a timestamp.
	3. Curated area. For this framework, this means re-assembled datasets. For instance, if we load a transactional source table incrementally, then the landing area will only have the latest incremental transactions. The raw area will have those records and all other prior imports, but those will be spread out across many files. The curated area will have a recreation of the source system table, with those latest transactions upserted into the curated dataset.

To enable any of these, you must specify a path. To disable one of these, don't specify a path. The filename, while recommended, is optional. If it is left empty then we will fill with a default value.
Hence the control for enabling/disabling these different areas in the datalake is to supply or not supply a path for each task.

read the data lake targets into variables
these could be explicit paths, they could be paths with tokens (for which we need to substitute in some values) or they could be references to path/locations that are configured in the etl.KeyValueConfig table

An example of an explicit path would be: /datalake/stage/landing_area/ipc/hwf/order_master/
	- In this example, "datalake" is the container or what Azure sometimes calls "File System"

You can also supply a path but include tokens, which will be swapped out for the run-time value.
For example: /datalake/staging/landing_area/ipc/hwf/{SourceTableName}/{SourceTableName}-{TaskAuditKey}-{ETLDate-YYYYmmDD}.parquet
	- This example mixes hardcoded values (like "/datalake/staging/landing_area/ipc/hwf") with tokens that will be replaced with dynamic values at runtime.
	- We should catalog somewhere a full list of supported tokens

Finally, the path could just be a reference to a ConfigKey within the etl.KeyValueConfig table. A path could be configured in this table and then used across numerous tasks.
For example:
	ConfigKey: DefaultLandingAreaFileLocation
	ConfigValue: /staging/landing_area/sqldb/ipc/

In addition to specifying an explicit path for "ConfigValue", this value can also use tokens. For example:
	DataLakeTransientLandingAreaPath: {DefaultLandingAreaFileLocation}
	ConfigKey: DefaultLandingAreaFileLocation
	ConfigValue: /staging/landing_area/{SourceType}/{SourceName}/{SourceTableName}

If the path value is enclosed in curly brackets, then we will join to etl.KeyValueConfig and try to find a ConfigKey with the enclosed value. 
If one is found, then we will return the ConfigValue and attempt to interpret it (if it contains additional tokens) and then use that for the path.
Otherwise if no value is returned from etl.KeyValueConfig but the path value is still enclosed in curly brackets, then we'll attempt to interpret any tokens and then use the subsequent value for the path.
Finally, if there are no curly brackets, then we'll just use the path value as-is.

Source Notes
You can override the default actions of a source by filling in an entry in etl.Sources.  You do NOT need an entry if you're using all defaults.  You'll need to set up
ADF to look for this string setup in the switch:

Azure SQL (defaults): AzureSQL
Azure SQL (specify integration runtime): AzureSQL_integrationruntime
SQL Server (defaults): SQLServer_SQL
SQL Server (specify integration runtime): SQLServer_integrationruntime_SQL
SQL Server (Windows auth): SQLServer_Windows
SQL Server (Windows auth and specify integration runtime): SQLServer_integrationruntime_Windows

Here's what you can specify in etl.Sources:
- Authentication Type - only currently used for SQL Server (not Azure SQL).  With Azure SQL, the connection string can contain all the authorization information.  
  With SQL Server, using Windows authentication requires that you provide a connection string, username and password.  Since we're using Key Vault for the
  Connection String and password, we can specify a secret name, or just use the default ('kv-' + SourceName + '-connstr' or 'kv-' + SourceName + '-passwd')
- UserName - if the SQL Server uses Windows authentication, specify the 'Domain\User' here
- IntegrationRuntimeName - If a source *type* can be used by more than one integration runtime, then specify which integration runtime to use here.  For
  instance, if you're pulling from two different regional offices that each have their own IR, you'd be able to specify the IR here.
- ConnectionStringSecret - If you want to use a different secret name from the default, which is 'kv-' + SourceName + '-connstr', specify the custom secret 
  name here.
- PasswordSecret - If you're using Windows authentication and using a different secret name from the default, which is 'kv-' + SourceName + '-passwd',
  specify the custom secret name here.


*/

-- the following variables will be read in from metadata on either the etl.Task or etl.KeyValueConfig tables
DECLARE @dataLakeTransientLandingAreaPath NVARCHAR(2000)
DECLARE @dataLakeTransientLandingAreaFileName NVARCHAR(2000)
DECLARE @dataLakePersistedRawPath NVARCHAR(2000)
DECLARE @dataLakePersistedRawFileName NVARCHAR(2000)
DECLARE @dataLakeCuratedPath NVARCHAR(2000)
DECLARE @dataLakeCuratedFileName NVARCHAR(2000)

SELECT TOP 1
	@dataLakeTransientLandingAreaPath = ISNULL(LandingAreaPathConfigValue.ConfigValue, DataLakeTransientLandingAreaPath),
	@dataLakePersistedRawPath = ISNULL(PersistedRawPathConfigValue.ConfigValue, DataLakePersistedRawPath),
	@dataLakeCuratedPath = ISNULL(CuratedPathConfigValue.ConfigValue, DataLakeCuratedPath),
	@dataLakeTransientLandingAreaFileName = ISNULL(LandingAreaFileNameConfigValue.ConfigValue, DataLakeTransientLandingAreaFileName),
	@dataLakePersistedRawFileName = ISNULL(PersistedRawFileNameConfigValue.ConfigValue, DataLakePersistedRawFileName),
	@dataLakeCuratedFileName = ISNULL(CuratedFileNameConfigValue.ConfigValue, DataLakeCuratedFileName)
FROM etl.TaskAudit 
INNER JOIN etl.Task 
	ON TaskAudit.TaskKey = Task.TaskKey
OUTER APPLY (SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE LEFT(DataLakeTransientLandingAreaPath, 1) = '{' AND LEN(REPLACE(DataLakeTransientLandingAreaPath, '{', '')) = (LEN(DataLakeTransientLandingAreaPath) - 1) AND ('{' + ConfigKey + '}' = DataLakeTransientLandingAreaPath)) LandingAreaPathConfigValue
OUTER APPLY (SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE LEFT(DataLakeTransientLandingAreaFileName, 1) = '{' AND LEN(REPLACE(DataLakeTransientLandingAreaFileName, '{', '')) = (LEN(DataLakeTransientLandingAreaFileName) - 1) AND ('{' + ConfigKey + '}' = DataLakeTransientLandingAreaFileName)) LandingAreaFileNameConfigValue
OUTER APPLY (SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE LEFT(DataLakePersistedRawPath, 1) = '{' AND LEN(REPLACE(DataLakePersistedRawPath, '{', '')) = (LEN(DataLakePersistedRawPath) - 1) AND ('{' + ConfigKey + '}' = DataLakePersistedRawPath)) PersistedRawPathConfigValue
OUTER APPLY (SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE LEFT(DataLakePersistedRawFileName, 1) = '{' AND LEN(REPLACE(DataLakePersistedRawFileName, '{', '')) = (LEN(DataLakePersistedRawFileName) - 1) AND ('{' + ConfigKey + '}' = DataLakePersistedRawFileName)) PersistedRawFileNameConfigValue
OUTER APPLY (SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE LEFT(DataLakeCuratedPath, 1) = '{' AND LEN(REPLACE(DataLakeCuratedPath, '{', '')) = (LEN(DataLakeCuratedPath) - 1) AND ('{' + ConfigKey + '}' = DataLakeCuratedPath)) CuratedPathConfigValue
OUTER APPLY (SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE LEFT(DataLakeCuratedFileName, 1) = '{' AND LEN(REPLACE(DataLakeCuratedFileName, '{', '')) = (LEN(DataLakeCuratedFileName) - 1) AND ('{' + ConfigKey + '}' = DataLakeCuratedFileName)) CuratedFileNameConfigValue
WHERE TaskAuditKey = @TaskAuditKey

-- the following variables will hold the interpretted/literal values that get passed back to the pipeline to use
-- for each of the three areas in the datalake, we'll pass back the Container, Path, and FileName, since that's how ADF wants to define the dataset location
DECLARE @landingAreaResolvedContainer NVARCHAR(2000)
DECLARE @landingAreaResolvedPath NVARCHAR(2000)
DECLARE @landingAreaResolvedFileName NVARCHAR(2000)

DECLARE @persistedRawResolvedContainer NVARCHAR(2000)
DECLARE @persistedRawResolvedPath NVARCHAR(2000)
DECLARE @persistedRawResolvedFileName NVARCHAR(2000)

DECLARE @curatedResolvedContainer NVARCHAR(2000)
DECLARE @curatedResolvedPath NVARCHAR(2000)
DECLARE @curatedResolvedFileName NVARCHAR(2000)

-- default filename if none is supplied
IF NULLIF(@dataLakeTransientLandingAreaFileName, '') IS NULL AND NULLIF(@dataLakeTransientLandingAreaPath, '') IS NOT NULL
	SET @dataLakeTransientLandingAreaFileName = 'landed-{TaskAuditKey}_{ETLDate}.parquet'

IF NULLIF(@dataLakePersistedRawFileName, '') IS NULL AND NULLIF(@dataLakePersistedRawPath, '') IS NOT NULL
	SET @dataLakePersistedRawFileName = 'raw-{TaskAuditKey}_{ETLDate}.parquet'

IF NULLIF(@dataLakeCuratedFileName, '') IS NULL AND NULLIF(@dataLakeCuratedPath, '') IS NOT NULL
	SET @dataLakeCuratedFileName = 'curated-{TaskAuditKey}_{ETLDate}.parquet'

-- token substitution
-- paths:
SET @landingAreaResolvedPath = 
	CASE
		WHEN CHARINDEX('{', @dataLakeTransientLandingAreaPath) > 0 THEN etl.PerformTokenSubstitution(@dataLakeTransientLandingAreaPath, @TaskAuditKey)
		ELSE @dataLakeTransientLandingAreaPath
	END
SET @persistedRawResolvedPath = 
	CASE
		WHEN CHARINDEX('{', @dataLakePersistedRawPath) > 0 THEN etl.PerformTokenSubstitution(@dataLakePersistedRawPath, @TaskAuditKey)
		ELSE @dataLakePersistedRawPath
	END
SET @curatedResolvedPath = 
	CASE
		WHEN CHARINDEX('{', @dataLakeCuratedPath) > 0 THEN etl.PerformTokenSubstitution(@dataLakeCuratedPath, @TaskAuditKey)
		ELSE @dataLakeCuratedPath
	END

-- filenames:
SET @landingAreaResolvedFileName = 
	CASE
		WHEN CHARINDEX('{', @dataLakeTransientLandingAreaFileName) > 0  THEN etl.PerformTokenSubstitution(@dataLakeTransientLandingAreaFileName, @TaskAuditKey)
		ELSE @dataLakeTransientLandingAreaFileName
	END
SET @persistedRawResolvedFileName = 
	CASE
		WHEN CHARINDEX('{', @dataLakePersistedRawFileName) > 0  THEN etl.PerformTokenSubstitution(@dataLakePersistedRawFileName, @TaskAuditKey)
		ELSE @dataLakePersistedRawFileName
	END
SET @curatedResolvedFileName = 
	CASE
		WHEN CHARINDEX('{', @dataLakeCuratedFileName) > 0  THEN etl.PerformTokenSubstitution(@dataLakeCuratedFileName, @TaskAuditKey)
		ELSE @dataLakeCuratedFileName
	END

-- now split these values out into separate Container, FolderPath, and FileName (with no leading or trailing slashes)

-- strip off any leading slash (i.e. turn '/containername/folder/' into 'containername/folder/'
IF LEFT(@landingAreaResolvedPath, 1) = '/'
	SET @landingAreaResolvedPath = RIGHT(@landingAreaResolvedPath, LEN(@landingAreaResolvedPath) - 1)
IF LEFT(@persistedRawResolvedPath, 1) = '/'
	SET @persistedRawResolvedPath = RIGHT(@persistedRawResolvedPath, LEN(@persistedRawResolvedPath) - 1)
IF LEFT(@curatedResolvedPath, 1) = '/'
	SET @curatedResolvedPath = RIGHT(@curatedResolvedPath, LEN(@curatedResolvedPath) - 1)

-- strip off any trailing slash (i.e. turn 'containername/folder/' into 'containername/folder'
IF RIGHT(@landingAreaResolvedPath, 1) = '/'
	SET @landingAreaResolvedPath = LEFT(@landingAreaResolvedPath, LEN(@landingAreaResolvedPath) - 1)
IF RIGHT(@persistedRawResolvedPath, 1) = '/'
	SET @persistedRawResolvedPath = LEFT(@persistedRawResolvedPath, LEN(@persistedRawResolvedPath) - 1)
IF RIGHT(@curatedResolvedPath, 1) = '/'
	SET @curatedResolvedPath = LEFT(@curatedResolvedPath, LEN(@curatedResolvedPath) - 1)

-- if the path does contain multiple directory hierarchies, then assume that the sole directory is the container and that the path variable will be empty
IF CHARINDEX('/', @landingAreaResolvedPath) = 0
BEGIN
	SET @landingAreaResolvedContainer = @landingAreaResolvedPath
	SET @landingAreaResolvedPath = ''
END
ELSE
BEGIN
	SET @landingAreaResolvedContainer = LEFT(@landingAreaResolvedPath, CHARINDEX('/', @landingAreaResolvedPath) - 1)
	SET @landingAreaResolvedPath = RIGHT(@landingAreaResolvedPath, LEN(@landingAreaResolvedPath) - CHARINDEX('/', @landingAreaResolvedPath))
END

IF CHARINDEX('/', @persistedRawResolvedPath) = 0
BEGIN
	SET @persistedRawResolvedContainer = @persistedRawResolvedPath
	SET @persistedRawResolvedPath = ''
END
ELSE
BEGIN
	SET @persistedRawResolvedContainer = LEFT(@persistedRawResolvedPath, CHARINDEX('/', @persistedRawResolvedPath) - 1)
	SET @persistedRawResolvedPath = RIGHT(@persistedRawResolvedPath, LEN(@persistedRawResolvedPath) - CHARINDEX('/', @persistedRawResolvedPath))
END

IF CHARINDEX('/', @curatedResolvedPath) = 0
BEGIN
	SET @curatedResolvedContainer = @curatedResolvedPath
	SET @curatedResolvedPath = ''
END
ELSE
BEGIN
	SET @curatedResolvedContainer = LEFT(@curatedResolvedPath, CHARINDEX('/', @curatedResolvedPath) - 1)
	SET @curatedResolvedPath = RIGHT(@curatedResolvedPath, LEN(@curatedResolvedPath) - CHARINDEX('/', @curatedResolvedPath))
END


-- this marks the end of the token substitution code. now return all the fields


SELECT 
	Task.TaskKey,	

	-- Source info
	ISNULL(Sources.SourceType, 'SQLServer')
	+ CASE 
		WHEN Sources.IntegrationRuntimeName <> ''
		THEN '_' + Sources.IntegrationRuntimeName
		ELSE ''
	END
	+ CASE 
		WHEN ISNULL(Sources.SourceType,'SQLServer') NOT IN ('SQLServer') THEN ''
		WHEN Sources.AuthenticationType <> ''
		THEN '_' + Sources.AuthenticationType
		ELSE ''
	END  as SourceType, -- see notes, this needs to match the switch statement
	
	ISNULL(Sources.ConnectionStringSecret, 'kv-' + Task.SourceName + '-connstr') as ConnectionStringSecret,
	
	CASE 
		WHEN Sources.SourceType = 'SQLServer' AND Sources.AuthenticationType = 'Windows' AND Sources.UserName <> ''
		THEN Sources.UserName
		ELSE ''
	END as UserName,
	
	CASE 
		WHEN Sources.SourceType = 'SQLServer' AND Sources.AuthenticationType = 'Windows' AND Sources.PasswordSecret <> ''
		THEN Sources.PasswordSecret
		WHEN Sources.SourceType = 'SQLServer' AND Sources.AuthenticationType = 'Windows'
		THEN 'kv-' + Task.SourceName + '-passwd'
		ELSE ''
	END as PasswordSecret, -- This might not be necessary.  See notes above.
	
	-- Target info
	@landingAreaResolvedContainer AS TransientLandingAreaContainer,
	@landingAreaResolvedPath AS TransientLandingAreaFolder,
	@landingAreaResolvedFileName AS TransientLandingAreaFileName,

	@persistedRawResolvedContainer AS PersistedRawContainer,
	@persistedRawResolvedPath AS PersistedRawFolder,
	@persistedRawResolvedFileName AS PersistedRawFileName,

	@curatedResolvedContainer AS CuratedContainer,
	@curatedResolvedPath AS CuratedFolder,
	@curatedResolvedFileName AS CuratedFileName,

	ISNULL((SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE ConfigKey = 'LandingAreaFileCompressionType'), 'snappy') AS TransientLandingAreaFileCompressionType,
	ISNULL((SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE ConfigKey = 'RawFileCompressionType'), 'snappy') AS PersistedRawFileCompressionType,
	ISNULL((SELECT TOP 1 ConfigValue FROM etl.KeyValueConfig WHERE ConfigKey = 'CuratedFileCompressionType'), 'snappy') AS CuratedFileCompressionType,

	Task.DataIntegrationUnits,
	Task.DegreeOfParallelism 
	
FROM etl.TaskAudit 
INNER JOIN etl.Task 
	ON TaskAudit.TaskKey = Task.TaskKey 
LEFT JOIN etl.Sources
	ON Task.SourceName = Sources.SourceName
WHERE TaskAuditKey = @TaskAuditKey