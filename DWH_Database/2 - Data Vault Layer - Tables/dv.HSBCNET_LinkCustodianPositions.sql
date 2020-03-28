CREATE TABLE [dv].[LinkCustodianPositions]
(	
	[HKeyCustodianPosition]			BINARY(20) NOT NULL,		
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,		
	[Meta_SrcSysExportDateTime]		DATETIME2 NULL, 
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,					-- FK to ID of import batch 		
	
	[HKeyCustodianAccount]			BINARY(20) NOT NULL,		--	UIX	
	[HKeyCustodianSecurity]			BINARY(20) NOT NULL,		--	UIX		
	[HKeyPriceCurrency]				BINARY(20) NOT NULL,		--	UIX	?
	
	[ReportDate]					DATE NOT NULL,				--	UIX			
	[SecuritiesAccountNumber]		NVARCHAR (100) NOT NULL,	--	UIX			
	[ISIN]							NVARCHAR (100) NOT NULL,	--	UIX			
	[SecurityCurrency]				NVARCHAR (100) NOT NULL,	--	UIX			
	[AsOfDateTime]					DATETIME2 NOT NULL,			--	UIX			
	
    CONSTRAINT [PK_LinkCustodianSecurityPosition]	PRIMARY KEY NONCLUSTERED ( [HKeyCustodianPosition] ),		
	CONSTRAINT [UIX_LinkCustodianSecurityPosition]	UNIQUE CLUSTERED	(	
																			[ReportDate], 
																			[SecuritiesAccountNumber],
																			[ISIN],
																			[SecurityCurrency],																			
																			[AsOfDateTime]
																			--[HKeySecurity], 
																			--[HKeyCustodianPosition], 
																			--[HKeyPriceCurrency]
																		)	-- Good practice to add unique index constraint on Business Key columns
)
;