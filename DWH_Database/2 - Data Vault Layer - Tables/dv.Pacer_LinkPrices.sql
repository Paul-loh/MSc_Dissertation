CREATE TABLE [dv].[LinkPrices]
(
	[HKeyPrice]						BINARY(20) NOT NULL,			-- Hash of Security Code + Price Date + Price Type + Price Source
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT NOT NULL,					-- FK to ID of import batch audit table	?
		
	[HKeySecurity]					BINARY(20) NOT NULL,			--	UIX
	[PriceDate]						DATETIME2  NOT NULL,			--	UIX
	[PriceType]						NVARCHAR (100) NOT NULL,		--	UIX	
	[PriceSource]					NVARCHAR (100) NOT NULL			--	UIX
			
	CONSTRAINT [PK_LinkPrices]	PRIMARY KEY NONCLUSTERED ( [HKeyPrice] ),		
	CONSTRAINT [CIX_LinkPrices]	UNIQUE CLUSTERED 
	(	
		[HKeyPrice] ASC,
		[HKeySecurity] ASC,
		[PriceDate] ASC,
		[PriceType] ASC,
		[PriceSource] ASC	
	) ON [PRIMARY]
)	
