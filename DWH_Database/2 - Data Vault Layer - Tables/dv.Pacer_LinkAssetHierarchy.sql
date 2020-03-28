CREATE TABLE [dv].[LinkAssetHierarchy]
(
	[HKeyLinkAssetHierarchy]		BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HKeyAssetParentCode]			BINARY(20) NULL,				-- NULL or a Ghost Key ?
	[HKeyAssetChildCode]			BINARY(20) NOT NULL,		

	[AssetParentCode]				NVARCHAR (100) NULL,		
	[AssetChildCode]				NVARCHAR (100) NOT NULL,		
			
	CONSTRAINT [PK_LinkAssetHierarchy]	PRIMARY KEY NONCLUSTERED ( [HKeyLinkAssetHierarchy] ),		
	CONSTRAINT [UIX_LinkAssetHierarchy]	UNIQUE NONCLUSTERED ( [AssetParentCode], [AssetChildCode] )	-- Good practice to add unique index constraint on Business Key columns
)
