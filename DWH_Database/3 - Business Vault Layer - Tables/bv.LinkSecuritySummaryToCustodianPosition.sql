-- Link table to link summary financial information at security level grain (from Pacer) to that of the custodian bank.

CREATE TABLE [bv].[LinkSecuritySummaryToCustodianPosition]
(
	[HKeySecuritySummaryToCustodianPosition]	BINARY(20) NOT NULL,		
	[Meta_LoadDateTime]							DATETIME2 NOT NULL,
	[Meta_RecordSource]							NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]							INT	NOT NULL,					-- FK to ID of import batch 		
	[HKeySecuritySummary]						BINARY(20) NOT NULL,
	[HKeyCustodianPosition]						BINARY(20) NOT NULL,		
	[ReportDate]								DATE NOT NULL,				--	UIX				
	[AsOfDateTime]								DATETIME2 NOT NULL,			--	UIX		
	[SecID]										NVARCHAR (100) NOT NULL,	--	BK - UIX		
	[Custodian_SecID]							NVARCHAR (100) NOT NULL,	--	BK - UIX
	[MappedLeadSystemSecurityCode]				NVARCHAR (100) NOT NULL,	--	UIX
	[MappedPartnerSystemSecurityCode]			NVARCHAR (100) NOT NULL,	--	UIX

	CONSTRAINT [PK_LinkLinkSecuritySummaryToCustodianPosition]	PRIMARY KEY NONCLUSTERED ( [HKeySecuritySummaryToCustodianPosition] ),		
	CONSTRAINT [UIX_LinkSecuritySummaryToCustodianPosition]		UNIQUE CLUSTERED	(	
																						[ReportDate], 
																						[Meta_LoadDateTime], 																			
																						[AsOfDateTime], 																			
																						[SecID], 
																						[Custodian_SecID],
																						[MappedLeadSystemSecurityCode],
																						[MappedPartnerSystemSecurityCode]
																					)	-- Good practice to add unique index constraint on Business Key columns
)