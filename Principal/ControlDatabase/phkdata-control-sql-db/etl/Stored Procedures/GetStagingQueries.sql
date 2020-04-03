


CREATE PROCEDURE [etl].[GetStagingQueries]
(@ADFActionKey         INT, 
 @ADFAuditKey          INT, 
 @InsertDateTime       DATETIME
)
AS
     DECLARE @SourceDB NVARCHAR(255);
     DECLARE @SourceSchemaName NVARCHAR(255);
     DECLARE @TableName NVARCHAR(255);
     DECLARE @ColumnList NVARCHAR(4000)
     DECLARE @TargetTableName NVARCHAR(255);
     DECLARE @TargetSchemaName NVARCHAR(255);
     DECLARE @LatestIncrementQuery NVARCHAR(4000);
     DECLARE @IncrementTableName NVARCHAR(255);
     DECLARE @IncrementColumnName NVARCHAR(255);
     DECLARE @NeedsSelectDistinct NVARCHAR(1);
     DECLARE @SourceQuery NVARCHAR(MAX);
     DECLARE @StoredProcedureName NVARCHAR(512);
     DECLARE @ETLStage NVARCHAR(50);
     DECLARE @SourceContainer NVARCHAR(255);
     DECLARE @SourcePath NVARCHAR(1000);
     DECLARE @SourceFile NVARCHAR(1000);
     DECLARE @TargetContainer NVARCHAR(255);
     DECLARE @TargetPath NVARCHAR(1000);
     DECLARE @TargetFile NVARCHAR(1000);
    
	DECLARE @Category NVARCHAR(255);
     DECLARE @Alias NVARCHAR(MAX);
     DECLARE @Delimiter NVARCHAR(3);
	DECLARE @IsIncremental BIT;

     SELECT @ETLStage = ETLStage, 
            @SourceDB = SourceDB, 
            @SourceSchemaName = SourceSchemaName, 
            @TableName = TableName, 
            @ColumnList = ColumnList, 
            @Alias = CASE
                         WHEN TableName NOT LIKE '%@%'
                         THEN TableName
                         ELSE LEFT(TableName, CHARINDEX('@', TableName) - 1)
                     END,
		  @TargetTableName = CASE WHEN TargetTableName <> '' THEN TargetTableName ELSE TableName END,
		  @TargetSchemaName = TargetSchemaName, 
            @LatestIncrementQuery = LatestIncrementQuery, 
            @IncrementTableName = IncrementTableName, 
            @IncrementColumnName = IncrementColumnName, 
            @NeedsSelectDistinct = NeedsSelectDistinct,
		  @SourceQuery = CASE 
							WHEN DataLoadType = 'Incremental'
							THEN CONVERT(NVARCHAR(MAX), REPLACE(REPLACE(SourceQueryFromClause, '{LowerLimit}', LowerLimit), '{UpperLimit}', UpperLimit))
						    ELSE CONVERT(NVARCHAR(MAX), ' from ' + ISNULL(NULLIF(a.SourceSchemaName, '') + '.', '') + a.TableName)
							END,
            @StoredProcedureName = StoredProcedureName, 
            @SourceContainer = SourceContainer, 
            @SourcePath = SourcePath, 
            @SourceFile = SourceFile,
            @TargetContainer = TargetContainer, 
            @TargetPath = TargetPath, 
            @TargetFile = TargetFile, 
            @Delimiter = ISNULL(FileDelimiter, ','),
		  @IsIncremental = CASE WHEN DataLoadType = 'Incremental' THEN 1 ELSE 0 END
     FROM etl.ADFActions AS A
     WHERE A.ADFActionKey = @ADFActionKey;

     IF(@SourceDB NOT IN('file', '', 'csv')
        AND @TableName <> '')
         BEGIN
		   DECLARE @MetadataColumns NVARCHAR(1000) = ''

		   -- ADFAuditKey
		   SET @MetadataColumns = @MetadataColumns + 
			 CASE WHEN @SourceDB IN ('P2000') -- Oracle databases
				THEN ', CAST(' + CAST(@ADFAuditKey AS NVARCHAR) + ' AS NUMBER(10)) AS "ADFAuditKey"'
				ELSE ', ' + CAST(@ADFAuditKey AS NVARCHAR) + ' AS ADFAuditKey'
			 END 

		   -- InsertDateTime
		   SET @MetadataColumns = @MetadataColumns + 
			 CASE WHEN @SourceDB IN ('P2000') -- Oracle databases
				THEN ', CAST(''' + CONVERT(varchar, @InsertDateTime, 6) + ''' AS DATE) AS "InsertDateTime"'
				ELSE ', CAST(''' + CONVERT(varchar, @InsertDateTime, 120) + ''' AS DATETIME) AS InsertDateTime'
			 END 		   


             SELECT @SourceQuery = 'SELECT ' + CASE
                                                   WHEN @NeedsSelectDistinct = 'Y'
                                                   THEN 'DISTINCT '
                                                   ELSE ''
                                               END + @ColumnList + @MetadataColumns
                                   + ' ' + @SourceQuery;
     END;
     SELECT @ETLStage AS ETLStage, 
            @SourceDB AS SourceDB, 
            @SourceSchemaName AS SourceSchemaName, 
            @TableName AS TableName,
		  @TargetTableName AS TargetTableName,
		  @TargetSchemaName AS TargetSchemaName,
            @ColumnList AS ColumnList, 
            @LatestIncrementQuery AS LatestIncrementQuery, 
            @SourceQuery AS SourceQuery, 
            @StoredProcedureName AS StoredProcedureName, 
            @SourceContainer AS SourceContainer, 
            @SourcePath AS SourcePath, 
            @SourceFile AS SourceFile,
            @TargetContainer AS TargetContainer, 
            @TargetPath AS TargetPath, 
            @TargetFile AS TargetFile, 
            @Delimiter AS Delimiter,
		  @IsIncremental AS IsIncremental;