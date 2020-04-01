CREATE VIEW etl.TableRecordCounts
AS
     SELECT UPPER(s.name) AS SchemaName, 
            UPPER(o.name) AS TableName, 
            i.rowcnt AS RowCnt
     FROM sysobjects o
          JOIN sysindexes i ON o.id = i.id
          JOIN sys.schemas s ON s.schema_id = o.uid
     WHERE i.indid IN(0, 1)
          AND i.rowcnt > 0
          AND o.xtype = 'u'