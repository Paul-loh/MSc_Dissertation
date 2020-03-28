CREATE TABLE [dv].[SatPortfolioMasterType]
(
	[HKeyPortfolio]							BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]						DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]					DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]						NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]						INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffPortfolioMasterTypePL]			BINARY(20) NOT NULL,     	

	[AsFromDate]							DATETIME2 NOT NULL,
	[MasterType]							NVARCHAR (1000) NOT NULL,
	CONSTRAINT [PK_SatPortfolioMasterType]	PRIMARY KEY NONCLUSTERED ( [HKeyPortfolio], [Meta_LoadDateTime] )
)
