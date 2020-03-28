CREATE TABLE [dv].[LinkRegionHierarchy]
(
	[HKeyLinkRegionHierarchy]		BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HKeyRegionParentCode]			BINARY(20) NULL,				-- NULL or a Ghost Key ?
	[HKeyRegionChildCode]			BINARY(20) NOT NULL,		

	[RegionParentCode]				NVARCHAR (100) NULL,		
	[RegionChildCode]				NVARCHAR (100) NOT NULL,		
			
	CONSTRAINT [PK_LinkRegionHierarchy]		PRIMARY KEY NONCLUSTERED ( [HKeyLinkRegionHierarchy] ),		
	CONSTRAINT [UIX_LinkRegionHierarchy]	UNIQUE NONCLUSTERED ( [RegionParentCode], [RegionChildCode] )	-- Good practice to add unique index constraint on Business Key columns
)
