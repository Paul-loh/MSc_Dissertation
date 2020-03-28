CREATE TABLE [dv].[SatCustodianAccounts]
(
	[HKeyCustodianAccount]					BINARY (20) NOT NULL,	
	[Meta_LoadDateTime]						DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]					DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_SrcSysExportDateTime]				DATETIME2 NULL, 
	[Meta_RecordSource]						NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]						INT	NOT NULL,					-- FK to ID of import batch audit table	?

	[HDiffCustodianAccountPL]				BINARY(20) NOT NULL, 	
	[AccountName]							NVARCHAR (100) NULL,	
	[AccountCurrency]						NVARCHAR(100) NULL,

	CONSTRAINT [PK_SatCustodianAccounts]	PRIMARY KEY NONCLUSTERED ([HKeyCustodianAccount], [Meta_LoadDateTime])	
)
