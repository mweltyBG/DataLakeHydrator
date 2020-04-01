



CREATE PROCEDURE [etl].[GetADFActions]
	@ETLSTage NVARCHAR(50),
	@SourceDB NVARCHAR(255) = NULL,
	@SourceContainer NVARCHAR(2000) = NULL,
	@SourcePath NVARCHAR(2000) = NULL,
	@SourceFile NVARCHAR(2000) = NULL,
	@DataLoadType NVARCHAR(255) = NULL
AS
BEGIN
	SELECT
		ADFActionKey
	FROM
		etl.ADFActions
	WHERE
		EnableAction = 1
		AND ISNULL(ETLStage, '') LIKE ISNULL(NULLIF(@ETLStage, ''), '%')
		AND ISNULL(SourceDB, '') LIKE ISNULL(NULLIF(@SourceDB, ''), '%')
		AND ISNULL(SourceContainer, '') LIKE ISNULL(NULLIF(@SourceContainer, ''), '%')
		AND ISNULL(SourcePath, '') LIKE ISNULL(NULLIF(@SourcePath, ''), '%')
		AND ISNULL(SourceFile, '') LIKE ISNULL(NULLIF(@SourceFile, ''), '%')		
		AND ISNULL(DataLoadType, '') LIKE ISNULL(NULLIF(@DataLoadType, ''), '%')

END