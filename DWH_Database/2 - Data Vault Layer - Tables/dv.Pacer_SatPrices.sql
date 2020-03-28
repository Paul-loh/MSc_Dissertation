CREATE TABLE [dv].[SatPrices]
(	
	[HKeyPrice]						BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]			DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffPricePL]					BINARY(20) NOT NULL, 
	
	[StatusFlag]					NVARCHAR(100) NULL,
	[ClosePrice]					NUMERIC (38,20) NULL,
	[BidPrice]						NUMERIC (38,20) NULL,
	[AskPrice]						NUMERIC (38,20) NULL,
	[HighPrice]						NUMERIC (38,20) NULL,
	[LowPrice]						NUMERIC (38,20) NULL,
	[TradingVolume]					INT NULL,
	[Yield]							NUMERIC (38,20) NULL,
	[EntryDate]						DATETIME2 NULL,
	
    CONSTRAINT [PK_SatPrices]	PRIMARY KEY NONCLUSTERED ([HKeyPrice], [Meta_LoadDateTime])
) 
GO
