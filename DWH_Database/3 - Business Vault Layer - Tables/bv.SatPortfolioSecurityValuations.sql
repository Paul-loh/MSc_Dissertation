-- Satellite table for summarising valuation information at Portfolio \ Security \ Price Currency level grain 
CREATE TABLE [bv].[SatPortfolioSecurityValuations]		
(	
	[HKeyPortfolioSecuritySummary]		BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffPortfolioSecuritySummaryPL]	BINARY(20) NULL, 
	
	ValuationLC							NUMERIC (38,20) NULL,
	ValuationBC							NUMERIC (38,20) NULL,

	CONSTRAINT [PK_SatPortfolioSecurityValuations]	PRIMARY KEY NONCLUSTERED ( [HKeyPortfolioSecuritySummary], [Meta_LoadDateTime] )
)
;