CREATE    PROCEDURE [dbo].[usp_JobConfigurationMetadataList] (
@MasterProcessNumber int
)
AS

SELECT 
	JM.StartTime,
	IL.[TableID], 
	IL.[SourceSchemaTable], 
	IL.[TargetSchemaTable],
	IL.[PKColumnList], 
	IL.[FilterColumn], 
	IL.[FilterColumnDataType],
	IL.[FilterColumnValue],
	IL.[SelectQuery], 
	IL.[DataLakeStagingFolder],
	IL.[IntegrationRuntime],
	'ds_'+SDS.SystemType+'_' +IL.IntegrationRuntime + '_' + CASE WHEN SDS.SystemType IN ('Azure','AzureSQL','SQLServer') THEN SDS.AuthenticationMethod ELSE SDS.SystemName END as [SourceDataset],
	'ds_'+SDS.SystemType+'_' +IL.IntegrationRuntime + '_' + CASE WHEN TDS.SystemType IN ('Azure','AzureSQL','SQLServer') THEN TDS.AuthenticationMethod ELSE TDS.SystemName END as [TargetDataset],
	'kv-'+SDS.SystemName+'-connstr' as [SourceConnectionString],
	'kv-'+TDS.SystemName+'-connstr' as [TargetConnectionString],
	'kv-'+SDS.SystemName+'-passwd' as [SourcePassword],
	'kv-'+TDS.SystemName+'-passwd' as [TargetPassword],
	IL.[SqlOverrideQuery],
	IL.[LoadCurated],
	CDR.[SourceControlTable],
	CDR.[ControlProcessNumber], 
	CDR.[ControlStartDate],
	CDR.[ControlEndDate],
	CONCAT(
		'select ',
		CASE WHEN CDR.[SourceControlTable] IS NULL THEN 'cast(null as date) ' ELSE CDR.[SourceControlTableStartDateColumn] END,
		' as start_date, ',
		CASE WHEN CDR.[SourceControlTable] IS NULL THEN 'cast(null as date) ' ELSE CDR.[SourceControlTableEndDateColumn] END,
		' as end_date, ',
		CASE WHEN CDR.[SourceControlTable] IS NULL THEN '0' ELSE 'next_process_number ' END,
		' as next_process_number from ', 
		CASE WHEN CDR.[SourceControlTable] IS NULL THEN 'sysibm.sysdummy1'  ELSE CDR.[SourceControlTable] END
	) 
	as ControlTableSql

FROM
	[ETL].[JobMaster] AS JM
	JOIN [ETL].[JobConfiguration] as JCon 
		ON JM.JobConfiguration = JCon.JobConfiguration 
		AND JM.Status IN ('Running','ReRunning') 
		AND JM.MasterProcessNumber = @MasterProcessNumber 
	JOIN [ETL].[MetadataIngestionList] AS IL 
		ON JCon.TableID = IL.TableID
		AND JCon.ExecuteFlag = CONVERT(bit, 1) 
		AND IL.[Disabled] = CONVERT(bit,  0)
	JOIN [ETL].[DataSystems] as SDS
		On IL.SourceSystem = SDS.SystemName
	JOIN [ETL].[DataSystems] as TDS
		on IL.TargetSystem = TDS.SystemName
	LEFT JOIN [ETL].[MetadataIngestionControlDateRanges] AS CDR 
		ON IL.TableID = CDR.SourceTableID
WHERE 
	NOT EXISTS (
		SELECT 1 
		FROM [ETL].[JobTableLog] 
		WHERE MasterProcessNumber = JM.MasterProcessNumber 
			AND TableID = JCon.TableID
			AND JobConfiguration = JM.JobConfiguration 
			AND [Status] IN ('Running','ReRunning','Success')
		) -- This table must not have an existing successful or running log for this run 