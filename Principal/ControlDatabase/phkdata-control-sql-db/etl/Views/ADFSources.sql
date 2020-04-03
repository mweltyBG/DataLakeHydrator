CREATE VIEW [etl].[ADFSources]
AS 
SELECT SourceDB, 'pmx_'+LOWER(SourceDB)+'_'+CASE WHEN DatabaseType = 'AzureSql' THEN 'sqlserver' ELSE LOWER(DatabaseType) END as LinkedServiceName, DataBaseType + 'Table' AS TableType, 'ds_'+LOWER(SourceDB)+'_dynamic' as DataSetName, Category as Category 
FROM etl.ADFConnections
WHERE Category = 'Database'
UNION ALL 
SELECT SourceDB, 'pmx_'+LOWER(SourceDB)+'_sqlserver' as LinkedServiceName, DataBaseType + 'Table' AS TableType, 'ds_'+LOWER(SourceDB)+'_dynamic_table' as DataSetName, 'Param' as Category 
FROM etl.ADFConnections 
WHERE SourceDB = 'azure'
UNION ALL 
SELECT SourceDB, 'pmx_'+LOWER(SourceDB)+'_sqlserver_autoruntime' as LinkedServiceName, DataBaseType + 'Table' AS TableType, 'ds_'+LOWER(SourceDB)+'_dynamic_table_autoruntime' as DataSetName, 'Param' as Category 
FROM etl.ADFConnections 
WHERE SourceDB = 'azure'
UNION ALL 
SELECT SourceDB, 'pmx_'+LOWER(SourceDB)+'_sqlserver_autoruntime' as LinkedServiceName, DataBaseType + 'Table' AS TableType, 'ds_'+LOWER(SourceDB)+'_dynamic_autoruntime' as DataSetName, Category as Category 
FROM etl.ADFConnections 
WHERE SourceDB = 'azure'
UNION ALL
SELECT SourceDB, 'pmxdatadwhstoragedev' as LinkedServiceName, DataBaseType AS TableType, 'ds_'+LOWER(SourceDB)+'_dynamic' as DataSetName, Category as Category 
FROM etl.ADFConnections
WHERE Category = 'File'