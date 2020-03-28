CREATE TABLE [bv].[LinkSecuritySummary]
(	
	[HKeySecuritySummary]			BINARY(20) NOT NULL,		
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,					-- FK to ID of import batch 		
	
	[HKeySecurity]					BINARY(20) NOT NULL,	--	UIX
	[HKeyPriceCurrency]				BINARY(20) NOT NULL,	--	UIX
	-- [HKeySettleCurrency]			BINARY(20) NOT NULL,	--	UIX	
	[HKeyPriceCurrencyPrice]		BINARY(20) NOT NULL,	--	UIX		
	[HKeyPriceCurrencyFXRateToGBP]	BINARY(20) NOT NULL,	--	UIX			
	
	[ReportDate]					DATE NOT NULL,			--	UIX			
	[AsOfDateTime]					DATETIME2 NOT NULL,		--	UIX			

	[SecID]							NVARCHAR (100) NOT NULL,	-- BK
	[PriceCurrencyCode]				NVARCHAR(100) NOT NULL,		-- BK
	-- [SettleCurrencyCode]			NVARCHAR(100) NOT NULL,		-- BK
	[PriceCurrencyBidPrice]			NUMERIC (38,20) NULL,
	[PriceCurrencyFXRateToGBP]		NUMERIC (38,20) NULL,

    CONSTRAINT [PK_LinkSecuritySummary]	PRIMARY KEY NONCLUSTERED ( [HKeySecuritySummary] ),		
	CONSTRAINT [UIX_LinkSecuritySummary]	UNIQUE CLUSTERED	(	
																			[ReportDate], 
																			[Meta_LoadDateTime], 																			
																			[AsOfDateTime], 																			
																			[HKeySecurity], 
																			[HKeyPriceCurrency], 
																			-- [HKeySettleCurrency],
																			[HKeyPriceCurrencyPrice], 
																			[HKeyPriceCurrencyFXRateToGBP]
																		)	-- Good practice to add unique index constraint on Business Key columns
)
;