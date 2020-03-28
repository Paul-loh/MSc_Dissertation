﻿CREATE TABLE [dv].[SatPortfolios]
(	
	[HKeyPortfolio]				BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]			DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]		DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]			NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]			INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffPortfolioPL]			BINARY(20) NOT NULL,     	
	[AccountExec]				NVARCHAR(100) NULL,
	[AccountNumber]				NVARCHAR(100) NULL,
	[PortfType]					NVARCHAR(100) NULL,
	[Permissions]				NVARCHAR(100) NULL,
	[InitDate]					NVARCHAR(100) NULL,
	[BaseCcy]					NVARCHAR(100) NULL,
	[ResidenceCtry]				NVARCHAR(100) NULL,
	[ResidenceRegion]			NVARCHAR(100) NULL,
	[TaxType]					NVARCHAR(100) NULL,
	[ValuationDate]				NVARCHAR(100) NULL,
	[BookCost]					NUMERIC (38,20) NULL,
	[MarketValue]				NUMERIC (38,20) NULL,
	[CustodianCode]				NVARCHAR(100) NULL,
	[SettlementAcct]			NVARCHAR(100) NULL,
	[CustAcctNumber]			NVARCHAR(100) NULL,
	[ObjectiveCode]				NVARCHAR(100) NULL,
	[PortfStatus]				NVARCHAR(100) NULL,
	[PersysFlag]				NVARCHAR(100) NULL,
	[PortfName]					NVARCHAR(100) NULL,
	[Address1]					NVARCHAR(100) NULL,
	[Address2]					NVARCHAR(100) NULL,
	[CumulGain]					NUMERIC (38,20) NULL,
	[LotIndicator]				NVARCHAR(100) NULL,
	CONSTRAINT [PK_SatPortfolios]	PRIMARY KEY NONCLUSTERED ([HKeyPortfolio], [Meta_LoadDateTime])
)
