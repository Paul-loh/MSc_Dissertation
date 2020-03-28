CREATE TABLE [dv].[LinkIndustryHierarchy]
(
	[HKeyLinkIndustryHierarchy]		BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT NOT NULL,					-- FK to ID of import batch audit table	?
	
	[HKeyIndustryParentCode]		BINARY(20) NULL,				-- NULL or a Ghost Key ?
	[HKeyIndustryChildCode]			BINARY(20) NOT NULL,		

	[IndustryParentCode]			NVARCHAR (100) NULL,		
	[IndustryChildCode]				NVARCHAR (100) NOT NULL,		
			
	CONSTRAINT [PK_LinkIndustryHierarchy]	PRIMARY KEY NONCLUSTERED ( [HKeyLinkIndustryHierarchy] ),		
	CONSTRAINT [UIX_LinkIndustryHierarchy]	UNIQUE NONCLUSTERED ( [IndustryParentCode], [IndustryChildCode] )	-- Good practice to add unique index constraint on Business Key columns
)
