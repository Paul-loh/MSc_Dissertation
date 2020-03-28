CREATE TABLE [dv].[LinkTransactions]
(
	[HKeyTransaction]				BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HKeyPortfolio]					BINARY(20) NOT NULL,		
	[HKeySecurity]					BINARY(20) NOT NULL,	
	[HKeyBroker]					BINARY(20) NOT NULL,	
	[HKeyPriceCcyISO]				BINARY(20) NOT NULL,	
	[HKeySettleCcyISO]				BINARY(20) NOT NULL,	
	[TRANNUM]						INT NOT NULL,				
	
	CONSTRAINT [PK_LinkTransactions]	PRIMARY KEY NONCLUSTERED ( [HKeyTransaction] ),		
	CONSTRAINT [UIX_LinkTransactions]	UNIQUE NONCLUSTERED ( [HKeyPortfolio], [HKeySecurity], [HKeyBroker], [HKeyPriceCcyISO], [HKeySettleCcyISO], [TRANNUM] )	-- Good practice to add unique index constraint on Business Key columns
)
