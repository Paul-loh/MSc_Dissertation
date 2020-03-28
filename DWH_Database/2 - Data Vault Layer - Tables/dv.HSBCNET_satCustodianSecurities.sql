CREATE TABLE [dv].[SatCustodianSecurities]
(
	[HKeyCustodianSecurity]			BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_SrcSysExportDateTime]		DATETIME2 NULL, 
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HDiffCustodianSecurityPL]		BINARY(20) NOT NULL, 

	[SEDOL]							NVARCHAR (100) NULL,	
	[SecurityDescription]			NVARCHAR (100) NULL,	
	[IssueType]						NVARCHAR (100) NULL,
	[IssueTypeDescription]			NVARCHAR (1000) NULL,
	[SecurityCurrency]				NVARCHAR (100) NULL,

	CONSTRAINT [PK_SatCustodianSecurities]	PRIMARY KEY NONCLUSTERED ([HKeyCustodianSecurity] , [Meta_LoadDateTime])
)