
-- Satellite table for aggregating the holding per Portfolio \ Security level grain 

CREATE TABLE [bv].[SatPortfolioSecurityHoldings]
(	
	[HKeyPortfolioSecuritySummary]		BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffPortfolioSecurityHoldingsPL]	BINARY(20) NULL, 	
	Holding								NUMERIC (38,20) NULL,
	Vintage								DATETIME2 NULL,
	SumMoneyInLC						NUMERIC (38,20) NULL,
	SumMoneyOutLC						NUMERIC (38,20) NULL,
	[SumInvestmentCapitalLC]			NUMERIC (38,20) NULL,
	SumMoneyInBC						NUMERIC (38,20) NULL,
	SumMoneyOutBC						NUMERIC (38,20) NULL,	
	[SumInvestmentCapitalBC]			NUMERIC (38,20) NULL,
	CONSTRAINT [PK_SatPortfolioSecurityHoldings] PRIMARY KEY NONCLUSTERED ( [HKeyPortfolioSecuritySummary], [Meta_LoadDateTime] )
)
;