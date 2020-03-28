﻿CREATE TABLE [dv].[HubRegionHierarchyLevel]
(	
	[HKeyRegionHierarchyLevel]					BINARY(20) NOT NULL,		
	[Meta_LoadDateTime]							DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]						DATETIME2 NOT NULL,					-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]							NVARCHAR(1000) NOT NULL,
	[Meta_ETLProcessID]							INT	NOT NULL,						-- FK to ID of import batch audit table	?
	[Code]										NVARCHAR(100) NOT NULL,	
	CONSTRAINT [PK_HubRegionHierarchyLevel]		PRIMARY KEY NONCLUSTERED ([HKeyRegionHierarchyLevel]),
	CONSTRAINT [UIX_HubRegionHierarchyLevel]	UNIQUE CLUSTERED ( [Code] ASC )		-- Good practice to add a unique index constraint on Business Key columns
)
;
