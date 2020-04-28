/*
ETL.Sources

This catalogs logical sources which are used by a dynamic source.  It is used only when you need to specify an integration runtime or non-default behavior.
Note that there needs to be a linked service that is set up to use these options.

Source Options
- Authentication Type - only currently used for SQL (not Azure SQL).  With Azure SQL, the connection string can contain all the authorization information.  
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
CREATE TABLE [etl].[Sources]
(
	[SourceName] NVARCHAR(200) NOT NULL,
	[AuthenticationType] NVARCHAR(200) NULL,
	[UserName] NVARCHAR(200) NULL,
	[IntegrationRuntimeName] NVARCHAR(200) NULL,
	[ConnectionStringSecret] NVARCHAR(200) NULL,
	[PasswordSecret] NVARCHAR(200) NULL,
	CONSTRAINT [PK_ETL_SOURCES] PRIMARY KEY CLUSTERED ([SourceName])
)
