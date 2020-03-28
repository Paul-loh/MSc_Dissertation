CREATE TABLE [dv].[SatFXRates]
(
	[HKeyFXRate]					BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]			DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffFXRatePL]					BINARY(20) NOT NULL,		-- Include BKs; CurrencyCode and RateDate
	
	[SSCCcyCode]					NVARCHAR (100) NOT NULL,
	[RateToGBP]						NUMERIC (38,20) NULL,
	
    CONSTRAINT [PK_SatFXRates]		PRIMARY KEY NONCLUSTERED ([HKeyFXRate], [Meta_LoadDateTime])
)
