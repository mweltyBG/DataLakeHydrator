
CREATE VIEW etl.ETLStage_1_HydrateLake
WITH SCHEMABINDING
AS SELECT ADFActionKey, 
		EnableAction, 
		SourceDB, 
		SourceSchemaName, 
		TableName, 
		ColumnList, 
		SourceContainer, 
		SourcePath, 
		SourceFile, 
		FileDelimiter, 
		TargetSchemaName, 
		TargetTableName, 
		DataLoadType, 
		SourceQueryFromClause, 
		QueryEnd, 
		IncrementDatatype, 
		IncrementTableName, 
		IncrementColumnName, 
		LowerLimit, 
		UpperLimit, 
		LimitType, 
		Offset, 
		OffsetUnit, 
		TimeZoneName, 
		DisableLimitUpdate,
		ADFAuditKey_LimitUpdate, 
		LastUpdateDatetime_LimitUpdate, 
		NeedsSelectDistinct, 
		ETLStage
   FROM etl.ADFActions
   WHERE ETLStage='1_HydrateLake';