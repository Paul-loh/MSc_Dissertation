CREATE TABLE [dv].[SatCurrencies]
(	
	[HKeyCurrency]					BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]			DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffCurrencyPL]				BINARY(20) NOT NULL, 
	[CurrencyName]					NVARCHAR (100) NULL,
	[SSCCode]						NVARCHAR (100) NULL,
	[CurrencyGroup]					INT NULL,
    CONSTRAINT [PK_SatCurrencies]	PRIMARY KEY NONCLUSTERED ([HKeyCurrency], [Meta_LoadDateTime])
) 
GO
