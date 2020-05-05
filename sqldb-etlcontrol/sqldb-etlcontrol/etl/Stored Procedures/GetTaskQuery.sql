


CREATE PROCEDURE [etl].[GetTaskQuery]
(@TaskAuditKey INT,
 @ETLExtractDatetime DATETIME = NULL
)
AS
	SET NOCOUNT ON



--DECLARE @TaskAuditKey INT = 54
--DECLARE @ETLExtractDatetime DATETIME = '1900-01-01'

	DECLARE @ErrorMessage NVARCHAR(2048) -- just declare this here. there are several spots later where we may attempt to use this

	DECLARE @TaskKey INT
	SET @TaskKey = (SELECT TOP 1 TaskKey FROM etl.TaskAudit WHERE TaskAuditKey = @TaskAuditKey)
	IF @TaskKey IS NULL
	BEGIN
		SET @ErrorMessage =  'Error: Could not find a TaskKey when searching the etl.TaskAudit table for TaskAuditKey ' + CONVERT(VARCHAR(5), @TaskAuditKey) + '.';
		THROW 50000, @ErrorMessage, 1;
	END

-- This constructs the query against the source database. One goal is to add additional "SourceType" database support.
-- Current SourceTypes supported are:
	DECLARE @SupportedTypes TABLE (
		SourceType NVARCHAR(200),
		Description NVARCHAR(200)
	)
	INSERT INTO @SupportedTypes (SourceType, Description) VALUES ('SQL Server', 'on-premise SQL Server database')
	INSERT INTO @SupportedTypes (SourceType, Description) VALUES ('Azure SQLDB', 'Azure SQL DB')

-- The following are the incoming values that the stored procedure gathers from the etl.Task table:
	DECLARE @SourceType NVARCHAR(200) -- (required) type of source system (see supported options above)
	DECLARE @SourceDatabaseName NVARCHAR(200) -- (possibly required) database/catalog name
	DECLARE @SourceSchemaName NVARCHAR(200) -- (possibly required)
	DECLARE @SourceTableName NVARCHAR(200) -- (required unless "SourceQuery" is used)
	DECLARE @SourceWhereClause NVARCHAR(4000) -- (optional) used with SourceTableName to support custom filtering, also required for incremental functionality
	DECLARE @SourceColumnList NVARCHAR(4000) -- (optional) if left blank than all columns will be imported
	DECLARE @PrimaryKeyColumnList NVARCHAR(4000) -- (optional but needed for incremental and curated functionality)
	DECLARE @SourceQuery NVARCHAR(4000) -- (optional) a customized query that overrrides the SourceTableName
	--DECLARE @SqlOverrideQuery NVARCHAR(4000) -- probably deprecate this
	DECLARE @IsSelectDistinctFlag BIT -- (optional) set to true if the query needs to include a "distinct" clause
	--DECLARE @TargetDataLakeContainer NVARCHAR(200) -- (required) the target name of the container for the parquet file to be dropped into
	--DECLARE @TargetDataLakeFolder NVARCHAR(200) -- (required)
	DECLARE @IsIncrementalFlag BIT -- (optional) enables incremental-loading functionality
	DECLARE @IncrementDatatype NVARCHAR(200) -- (optional but required for incremental) 
	--DECLARE @IncrementTableName NVARCHAR(200) -- probably deprecate this
	DECLARE @IncrementColumnName NVARCHAR(200)
	DECLARE @LowerLimit NVARCHAR(200) -- (optional but required for incremental) 
	DECLARE @UpperLimit NVARCHAR(200) -- (optional but required for incremental) 
	DECLARE @LimitType NVARCHAR(200) -- (optional but required for incremental) 
	DECLARE @DisableAction BIT -- (optional) when set to true, disables this task

	SELECT
		@SourceType = ISNULL(ConnectionConfig.ConnectionType, ''),
		@SourceDatabaseName = ISNULL(SourceDatabaseName, ''), 
		@SourceSchemaName = ISNULL(SourceSchemaName, ''), 
		@SourceTableName = ISNULL(SourceTableName, ''),
		@SourceColumnList = ISNULL(SourceColumnList, ''), 
		@PrimaryKeyColumnList = ISNULL(PrimaryKeyColumnList, ''),
		@SourceQuery = ISNULL(SourceQuery, ''),
		@SourceWhereClause = ISNULL(SourceWhereClause, ''),
--		@SqlOverrideQuery = ISNULL(SqlOverrideQuery, ''),
		@IsSelectDistinctFlag = ISNULL(IsSelectDistinctFlag, 0),
--		@TargetDataLakeContainer = ISNULL(TargetDataLakeContainer, ''),
--		@TargetDataLakeFolder = ISNULL(TargetDataLakeFolder, ''),
		@IsIncrementalFlag = ISNULL(IsIncrementalFlag, 0),
		@IncrementDatatype = ISNULL(IncrementDatatype, ''),
--		@IncrementTableName = ISNULL(IncrementTableName, ''),
		@IncrementColumnName = ISNULL(IncrementColumnName, ''),
		@LowerLimit = ISNULL(LowerLimit, ''),
		@UpperLimit = ISNULL(UpperLimit, ''),
		@LimitType = ISNULL(LimitType, ''),
		@DisableAction = ISNULL(DisableAction, 0)

	FROM etl.Task
	LEFT OUTER JOIN etl.ConnectionConfig
		ON Task.SourceName = ConnectionConfig.ConnectionName
	WHERE Task.TaskKey= @TaskKey

	IF @SourceType NOT IN (SELECT SourceType FROM @SupportedTypes)
	BEGIN
		SET @ErrorMessage =  'Error: SourceType "' + @SourceType + '" defined by TaskKey "' + CONVERT(VARCHAR(5), @TaskKey) + '" is not currently a supported SourceType. Supported SourceType options are: ' + (SELECT STRING_AGG(SourceType, ', ') FROM @SupportedTypes);
		THROW 50000, @ErrorMessage, 1;
	END
	ELSE
	BEGIN

		-- 	Begin constucting the source system query using all the prior options/input

		DECLARE @Query NVARCHAR(MAX)

		IF @SourceQuery != ''
			SET @Query = @SourceQuery
		ELSE
		BEGIN
			-- build a custom query based on all the supplied options
			SET @Query = 'SELECT '

			IF @IsSelectDistinctFlag = 1 AND @SourceType IN ('Azure SQLDB', 'SQL Server')
				SET @Query = @Query + 'DISTINCT '

			-- Columns
			IF @SourceColumnList != ''
				SET @Query = @Query + @SourceColumnList + ' '
			ELSE
				SET @Query = @Query + '*'

			-- Metadata Columns
			DECLARE @MetadataColumns NVARCHAR(1000) = ''

			-- TaskAuditKey:
			SET @MetadataColumns = @MetadataColumns + 
				CASE 
					WHEN @SourceType IN ('Oracle')
					THEN 'CAST(' + CAST(@TaskAuditKey AS NVARCHAR) + ' AS NUMBER(10)) AS "TaskAuditKey", '
					ELSE CAST(@TaskAuditKey AS NVARCHAR) + ' AS TaskAuditKey, '
				END 

			-- ETLExtractDatetime:
			IF @ETLExtractDatetime IS NULL
				SET @ETLExtractDatetime = GETUTCDATE()

			SET @MetadataColumns = @MetadataColumns + 
				CASE 
					WHEN @SourceType IN ('Oracle')
					THEN 'CAST(''' + CONVERT(varchar, @ETLExtractDatetime, 6) + ''' AS DATE) AS "ETLExtractDatetime"'
					ELSE 'CAST(''' + CONVERT(varchar, @ETLExtractDatetime, 120) + ''' AS DATETIME) AS ETLExtractDatetime'
				END 	

			SET @Query = @Query + ', ' + @MetadataColumns + ' '

			-- FROM Clause
			IF @SourceType IN ('Azure SQLDB', 'SQL Server')
			BEGIN
				SET @Query = @Query + 'FROM '

				IF @SourceDatabaseName != ''
					SET @Query = @Query + '[' + @SourceDatabaseName + '].'

				IF @SourceSchemaName != ''
					SET @Query = @Query + '[' + @SourceSchemaName + '].'

				SET @Query = @Query + '[' + @SourceTableName + '] '
			END

			-- WHERE clause and incremental functionality

			IF @IsIncrementalFlag = 0
			BEGIN
				IF @SourceWhereClause != ''
					SET @Query = @Query + @SourceWhereClause
			END
			ELSE
			BEGIN
				-- incremental functionality:

				IF @SourceWhereClause = ''
				BEGIN
					SET @ErrorMessage =  'Error: Incremental functionality enabled for TaskKey "' + CONVERT(VARCHAR(5), @TaskKey) + '",  however, no SourceWhereClause was supplied. This is required for incremental functionality.';
					THROW 50000, @ErrorMessage, 1;
				END
				ELSE
				BEGIN
					SET @Query = @Query + REPLACE(REPLACE(@SourceWhereClause, '{LowerLimit}', @LowerLimit), '{UpperLimit}', @UpperLimit)
				END

			END


		END

		SELECT @Query AS SourceQuery
	END