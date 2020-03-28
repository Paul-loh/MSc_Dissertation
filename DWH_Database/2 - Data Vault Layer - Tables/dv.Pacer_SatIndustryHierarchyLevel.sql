CREATE TABLE [dv].[SatIndustryHierarchyLevel]
(	
	[HKeyIndustryHierarchyLevel]					BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]								DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]							DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]								NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]								INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffHierarchyLevelPL]							BINARY(20) NOT NULL, 
	[SecurityClass]									NVARCHAR (100) NULL,	
    CONSTRAINT [PK_SatIndustryHierarchyLevel]		PRIMARY KEY NONCLUSTERED	(	
																				[HKeyIndustryHierarchyLevel], 
																				[Meta_LoadDateTime] 
																				)
) 
GO
