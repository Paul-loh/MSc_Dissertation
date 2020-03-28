CREATE TABLE [dv].[LinkSecurityClassification]
(
	[HKeyLinkSecurityClassification]	BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]				DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HKeySecurity]						BINARY(20) NOT NULL,		
	[HKeyIndustryHierarchyLevel]		BINARY(20) NOT NULL,		
	[HKeyRegionHierarchyLevel]			BINARY(20) NOT NULL,		
	[HKeyAssetHierarchyLevel]			BINARY(20) NOT NULL,		

	[SecID]								NVARCHAR (100) NULL,		
	[IndustryHierarchyCode]				NVARCHAR (100) NULL,		
	[RegionHierarchyCode]				NVARCHAR (100) NULL,		
	[AssetHierarchyCode]				NVARCHAR (100) NULL,		
		
	CONSTRAINT [PK_LinkSecurityClassification]	PRIMARY KEY NONCLUSTERED ( [HKeyLinkSecurityClassification] ),		
	CONSTRAINT [UIX_LinkSecurityClassification]	UNIQUE NONCLUSTERED (	
																		[SecID], 
																		[Meta_LoadDateTime], 
																		[IndustryHierarchyCode], 
																		[RegionHierarchyCode], 
																		[AssetHierarchyCode] 
																	)		-- Good practice to add unique index constraint on Business Key columns
)
