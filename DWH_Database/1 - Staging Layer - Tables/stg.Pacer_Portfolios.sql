﻿CREATE TABLE [stg].[PACER_Portfolios]
(
	[ID]							INT IDENTITY(1,1)	NOT NULL PRIMARY KEY,
	[In_PortfCode]					VARCHAR(100) NULL,
	[In_AccountExec]				VARCHAR(100) NULL,
	[In_AccountNumber]				VARCHAR(100) NULL,
	[In_PortfType]					VARCHAR(100) NULL,
	[In_Permissions]				VARCHAR(100) NULL,
	[In_InitDate]					VARCHAR(100) NULL,
	[In_BaseCcy]					VARCHAR(100) NULL,
	[In_ResidenceCtry]				VARCHAR(100) NULL,
	[In_ResidenceRegion]			VARCHAR(100) NULL,
	[In_TaxType]					VARCHAR(100) NULL,
	[In_ValuationDate]				VARCHAR(100) NULL,
	[In_BookCost]					VARCHAR(100) NULL,
	[In_MarketValue]				VARCHAR(100) NULL,
	[In_CustodianCode]				VARCHAR(100) NULL,
	[In_SettlementAcct]				VARCHAR(100) NULL,
	[In_CustAcctNumber]				VARCHAR(100) NULL,
	[In_ObjectiveCode]				VARCHAR(100) NULL,
	[In_PortfStatus]				VARCHAR(100) NULL,
	[In_PersysFlag]					VARCHAR(100) NULL,
	[In_PortfName]					VARCHAR(100) NULL,
	[In_Address1]					VARCHAR(100) NULL,
	[In_Address2]					VARCHAR(100) NULL,
	[In_CumulGain]					VARCHAR(100) NULL,
	[In_LotIndicator]				VARCHAR(100) NULL,
	[Out_PortfCode]					NVARCHAR(100) NULL,
	[Out_AccountExec]				NVARCHAR(100) NULL,
	[Out_AccountNumber]				NVARCHAR(100) NULL,
	[Out_PortfType]					NVARCHAR(100) NULL,
	[Out_Permissions]				NVARCHAR(100) NULL,
	[Out_InitDate]					NVARCHAR(100) NULL,
	[Out_BaseCcy]					NVARCHAR(100) NULL,
	[Out_ResidenceCtry]				NVARCHAR(100) NULL,
	[Out_ResidenceRegion]			NVARCHAR(100) NULL,
	[Out_TaxType]					NVARCHAR(100) NULL,
	[Out_ValuationDate]				NVARCHAR(100) NULL,
	[Out_BookCost]					NUMERIC (38,20) NULL,
	[Out_MarketValue]				NUMERIC (38,20) NULL,
	[Out_CustodianCode]				NVARCHAR(100) NULL,
	[Out_SettlementAcct]			NVARCHAR(100) NULL,
	[Out_CustAcctNumber]			NVARCHAR(100) NULL,
	[Out_ObjectiveCode]				NVARCHAR(100) NULL,
	[Out_PortfStatus]				NVARCHAR(100) NULL,
	[Out_PersysFlag]				NVARCHAR(100) NULL,
	[Out_PortfName]					NVARCHAR(100) NULL,
	[Out_Address1]					NVARCHAR(100) NULL,
	[Out_Address2]					NVARCHAR(100) NULL,
	[Out_CumulGain]					NUMERIC (38,20) NULL,
	[Out_LotIndicator]				NVARCHAR(100) NULL,
	[Out_HKeyHubPortfolios]			BINARY(20) NULL,
	[Out_PortfolioPL]				NVARCHAR(4000) NULL,
	[Out_HDiffPortfolioPL]			BINARY(20) NULL,
	[Meta_ETLProcessID]				INT NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL,
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import	
)

