-- =============================================
-- Author:      David Barnhart, Blue-Granite
-- Create Date: 2019-12-31
-- Description: Update the upper/lower limits that control the incremental ETL pipelines
-- =============================================
CREATE PROCEDURE etl.SetLimitAuditInfo @ADFActionKey INT, @ADFAuditKey BIGINT, @ExecutionSequence NVARCHAR(5) AS
/*
This procedure updates the Lower/Upper incremental limits, which control the range of data staged from the source system. This executes immediately before data is copied from the source system and immediately after (but only when the copy data activity was successful). 
-   When this executes before the copy data activity, we only update the Upper Limit.
-   When this executes after the copy data activity, we only update the Lower Limit.
This behavior ensures that we do not accidentally cause a gap in the range of data copied from the source system in the event that the ETL fails for several days in a row, or if an outage causes the ETL to not execute for several days.
An offset value of zero means that no overlap of data from the source system gets imported. An offset of one day means that we attempt to reach back and re-import a full 24 hours plus any more recent data since the last import.
The UpperLimit value is always assigned to "RightNowLocalized". Because the Azure SQL clock is set to UTC, we convert GETDATE (or GETUTCDATE) to the localized timezone.
If the procedure is being executed after the copy data activity (which implicitly means that the copy data activity was successful), then we take the "RightNowLocalized" value, subtract the offset (if any) from that date, and this becomes the new LowerLimit. 
The procedure is designed to run using default values if none have been assigned for this particular ADFActionKey in the etl.ADFActions table. Ideally these global defaults should be configured in the etl.ADFConfig table. However, if this table is empty, then the stored procedure uses some hard-coded default values.
The only time the procedure sets a LowerLimit value in the "Pre" execution sequence is if the existing LowerLimit value on etl.ADFActions is null. In this situation, it replaces the null value with the default lower limit value.
If the procedure uses defaults (whether hard-coded or from the etl.Config table), then those values will be written back to the etl.ADFActions to help "seed" the incremental settings. Of course these can be adjusted later to take effect during subsequent ETL executions.
*/
SET NOCOUNT ON;
-- Only execute this proc if the ADFActionKey refers to an incremental action
IF EXISTS (SELECT TOP 1 ADFActionKey FROM etl.ADFActions WHERE ADFActionKey = @ADFActionKey AND DataLoadType = 'Incremental' AND DisableLimitUpdate = 0)
BEGIN
	IF @ExecutionSequence IN ('Pre', 'Post')
	BEGIN
		DECLARE @LowerLimit NVARCHAR(255), @DefaultLowerLimit NVARCHAR(255), @UpperLimit NVARCHAR(255), @LimitType NVARCHAR(255), @TimeZoneOffset NVARCHAR(255), @Offset INT, @OffsetUnit NVARCHAR(255), @TimeZoneName NVARCHAR(255), @RightNowLocalized DATETIME, @UpperLimitDateTime DATETIME, @LowerLimitDateTime DATETIME, @DefaultIncrementalEarliestDate DATETIME
		-- Get the incremental info for this ADFActionKey
		SELECT
			@LimitType = LimitType
		,   @UpperLimit = UpperLimit
		,   @LowerLimit = LowerLimit
		,   @Offset = TRY_CONVERT(INT, Offset)
		,   @OffsetUnit = OffsetUnit
		,   @TimeZoneName = TimeZoneName
		FROM etl.ADFActions
		WHERE ADFActionKey = @ADFActionKey
		-- Set some defaults if the incremental info for this ADFActionKey is incomplete
		SET @TimeZoneName = COALESCE(@TimeZoneName, (SELECT TOP 1 ConfigValue FROM etl.ADFConfig WHERE ConfigKey = 'DefaultTimeZoneName'), 'UTC')
		SET @Offset = COALESCE(@Offset, (SELECT TOP 1 ConfigValue FROM etl.ADFConfig WHERE ConfigKey = 'DefaultIncrementalOffset'), 0) -- default offset is "no overlap"
		SET @OffsetUnit = COALESCE(@OffsetUnit, (SELECT TOP 1 ConfigValue FROM etl.ADFConfig WHERE ConfigKey = 'DefaultIncrementalOffsetUnit'), 'Day')
		SET @DefaultIncrementalEarliestDate = COALESCE(TRY_CONVERT(DATETIME, ((SELECT TOP 1 ConfigValue FROM etl.ADFConfig WHERE ConfigKey = 'DefaultIncrementalEarliestDate'))), '1900-01-01')
		SET @LimitType = COALESCE(@LimitType, (SELECT TOP 1 ConfigValue FROM etl.ADFConfig WHERE ConfigKey = 'DefaultIncrementalLimitType'), 'Date')
		SELECT @TimeZoneOffset = current_utc_offset FROM sys.time_zone_info WHERE Name = @TimeZoneName
		-- if the TimeZoneOffset cannot be found, then fail the procedure
		IF @TimeZoneOffset IS NOT NULL
		BEGIN
		   SET @UpperLimitDateTime = CONVERT(DATETIME, @UpperLimit)
		   -- Prepare the LowerLimit that we will use if the previous execution was a success. This is existing upper limit, converted back into a full datetime type, minus the offset value. For the moment it will be calculated as a datetime before being cast to its final form
		   SET @LowerLimitDateTime = -- DATEADD(OffsetUnit, @Offset, @UpperLimitDateTime)
			  CASE
				 WHEN @OffsetUnit IN ('year', 'yy', 'yyyy') THEN DATEADD(YEAR, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('quarter', 'qq', 'q') THEN DATEADD(QUARTER, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('month', 'mm', 'm') THEN DATEADD(MONTH, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('dayofyear', 'dy', '') THEN DATEADD(DAYOFYEAR, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('day', 'dd', 'd') THEN DATEADD(DAY, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('weekday', 'dw', 'w') THEN DATEADD(WEEKDAY, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('week', 'wk', 'ww') THEN DATEADD(WEEK, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('hour', 'hh') THEN DATEADD(HOUR, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('minute', 'mi', 'n') THEN DATEADD(MINUTE, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('second', 'ss', 's') THEN DATEADD(SECOND, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('millisecond', 'ms') THEN DATEADD(MILLISECOND, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('microsecond', 'mcs') THEN DATEADD(MICROSECOND, -1 * @Offset, @UpperLimitDateTime)
				 WHEN @OffsetUnit IN ('nanosecond', 'ns') THEN DATEADD(NANOSECOND, -1 * @Offset, @UpperLimitDateTime)
			  END
		   -- Set the current date, using the source system's local time zone as defined by TimeZoneName
		   SET @RightNowLocalized = CONVERT(DATETIME, SWITCHOFFSET(CONVERT(datetimeoffset, GETUTCDATE()), @TimeZoneOffset))
		   -- The procedure supports several formats of incremental dates.
		   IF @LimitType = 'Integer Date' -- YYYYMMDD style "smart date" integer
			  BEGIN
				 SET @UpperLimit =
					CASE
						WHEN @ExecutionSequence = 'Pre' THEN CONVERT(VARCHAR, @RightNowLocalized, 112)
						ELSE @UpperLimit
					END
				 SET @LowerLimit =
					CASE 
						WHEN @ExecutionSequence = 'Post' THEN CONVERT(VARCHAR, @LowerLimitDateTime, 112)
						WHEN @ExecutionSequence = 'Pre' AND @LowerLimit IS NULL THEN CONVERT(VARCHAR, @DefaultIncrementalEarliestDate, 112)
						ELSE @LowerLimit
					END
			  END
		   ELSE IF @LimitType = 'DateTime' -- a date and time
			  BEGIN
				 SET @UpperLimit =
					CASE
						WHEN @ExecutionSequence = 'Pre' THEN CONVERT(VARCHAR, @RightNowLocalized, 120)
						ELSE @UpperLimit
					END
				 SET @LowerLimit =
					CASE 
						WHEN @ExecutionSequence = 'Post' THEN CONVERT(VARCHAR, @LowerLimitDateTime, 120)
						WHEN @ExecutionSequence = 'Pre' AND @LowerLimit IS NULL THEN CONVERT(VARCHAR, @DefaultIncrementalEarliestDate, 120)
						ELSE @LowerLimit
					END
			  END
		   ELSE IF @LimitType = 'Date' -- just the date, no time component
			  BEGIN
				 SET @UpperLimit =
					CASE
						WHEN @ExecutionSequence = 'Pre' THEN LEFT(CONVERT(VARCHAR, @RightNowLocalized, 120), 10)
						ELSE @UpperLimit
					END
				 SET @LowerLimit =
					CASE 
						WHEN @ExecutionSequence = 'Post' THEN LEFT(CONVERT(VARCHAR, @LowerLimitDateTime, 120), 10)
						WHEN @ExecutionSequence = 'Pre' AND @LowerLimit IS NULL THEN LEFT(CONVERT(VARCHAR, @DefaultIncrementalEarliestDate, 120), 10)
						ELSE @LowerLimit
					END
			  END
		   -- write the limits (and other values) back to the ADFActions table. 
		   UPDATE etl.ADFActions 
		   SET 
			  LowerLimit = @LowerLimit,
			  UpperLimit = @UpperLimit,
			  LimitType = @LimitType,
			  TimeZoneName = @TimeZoneName,
			  Offset = @Offset,
			  OffsetUnit = @OffsetUnit,
			  ADFAuditKey_LimitUpdate = @ADFAuditKey, 
			  LastUpdateDatetime_LimitUpdate = GETUTCDATE() 
		   WHERE ADFActionKey = @ADFActionKey
		   -- record these limit values to the LimitAudit table
		   INSERT INTO etl.ADFLimitAudit (ADFAuditKey, ADFActionKey, ExecutionSequence, LimitAuditTimestamp, LowerLimit, UpperLimit, LimitType, Offset, OffsetUnit, TimeZoneName)
		   VALUES (@ADFAuditKey, @ADFActionKey, @ExecutionSequence, GETUTCDATE(), @LowerLimit, @UpperLimit, @LimitType, @Offset, @OffsetUnit, @TimeZoneName)
		END
		ELSE
		   THROW 50000, 'No matching current_utc_offset value found in the sys.time_zone_info system table for selected TimeZoneName', 1
	END
	ELSE
		THROW 50000, 'Specify either ''Pre'' or ''Post'' for the @ExecutionSequence parameter', 1
END