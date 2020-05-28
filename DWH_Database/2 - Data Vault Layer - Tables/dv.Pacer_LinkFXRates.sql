CREATE TABLE [dv].[LinkFXRates]
(
	[HKeyFXRate]					BINARY(20) NOT NULL,			-- Hash of Currency Code and Date
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT NOT NULL,					-- FK to ID of import batch audit table	?
		
	[HKeyCurrency]					BINARY(20) NOT NULL,	
	[CurrencyCode]					NVARCHAR(100) NOT NULL, 
	[RateDate]						DATETIME2  NOT NULL,			

    --	UIX		
	CONSTRAINT [PK_LinkFXRates]		PRIMARY KEY NONCLUSTERED ( [HKeyFXRate] ),		
	CONSTRAINT [UIX_LinkFXRates]	UNIQUE CLUSTERED ( [HKeyFXRate], [HKeyCurrency], [CurrencyCode], [RateDate] )	-- Good practice to add unique index constraint on Business Key columns
)
