-- Link table to link summary financial information at security level grain (from Pacer) to that of the custodian bank.

CREATE TABLE [bv].[LinkPortfolioSecuritySummaryToCustodianPosition]
(
	[HKeyPortfolioSecuritySummaryToCustodianPosition]	BINARY(20) NOT NULL,		
	[Meta_LoadDateTime]									DATETIME2 NOT NULL,
	[Meta_RecordSource]									NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]									INT	NOT NULL,					-- FK to ID of import batch 		
	[HKeyPortfolioSecuritySummary]						BINARY(20) NOT NULL,
	[HKeyCustodianPosition]								BINARY(20) NOT NULL,		
	[ReportDate]										DATE NOT NULL,				--	UIX				
	[AsOfDateTime]										DATETIME2 NOT NULL,			--	UIX		
	[PortfCode]											NVARCHAR (100) NOT NULL,	--	BK - UIX		
	[SecID]												NVARCHAR (100) NOT NULL,	--	BK - UIX		
	[Custodian_SecID]									NVARCHAR (100) NOT NULL,	--	BK - UIX
	[MappedLeadSystemSecurityCode]						NVARCHAR (100) NOT NULL,	--	UIX
	[MappedPartnerSystemSecurityCode]					NVARCHAR (100) NOT NULL,	--	UIX

	CONSTRAINT [PK_LinkPortfolioSecuritySummaryToCustodianPosition]		PRIMARY KEY NONCLUSTERED ( [HKeyPortfolioSecuritySummaryToCustodianPosition] ),		
	CONSTRAINT [UIX_LinkPortfolioSecuritySummaryToCustodianPosition]	UNIQUE CLUSTERED	(	
																								[ReportDate], 
																								[Meta_LoadDateTime], 																			
																								[AsOfDateTime], 	
																								[PortfCode], 
																								[SecID], 
																								[Custodian_SecID],
																								[MappedLeadSystemSecurityCode],
																								[MappedPartnerSystemSecurityCode]
																							)	-- Good practice to add unique index constraint on Business Key columns
		)