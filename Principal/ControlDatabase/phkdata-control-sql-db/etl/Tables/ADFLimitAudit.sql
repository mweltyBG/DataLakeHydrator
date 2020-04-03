CREATE TABLE [etl].[ADFLimitAudit](
	[ADFAuditKey] [bigint] NOT NULL,
	[ADFActionKey] [bigint] NOT NULL,
	[ExecutionSequence] [nvarchar](5) NULL,
	[LimitAuditTimestamp] [datetime] NULL,
	[LowerLimit] [nvarchar](255) NULL,
	[UpperLimit] [nvarchar](255) NULL,
	[LimitType] [nvarchar](255) NULL,
	[Offset] [nvarchar](255) NULL,
	[OffsetUnit] [nvarchar](255) NULL,
	[TimeZoneName] [varchar](255) NULL
) ON [PRIMARY]