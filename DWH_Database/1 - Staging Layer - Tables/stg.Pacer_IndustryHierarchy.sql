CREATE TABLE [stg].[PACER_IndustryHierarchy]
(
	[ID]							INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[In_FIELDS]						VARCHAR (100) NULL,	
	[Out_Code]						NVARCHAR (1000) NULL,
	[Out_SecurityClass]				NVARCHAR (1000) NULL,
	[Out_ParentCode]				NVARCHAR (1000) NULL,

	[Out_HKeyLinkIndustryHierarchy]	BINARY(20) NULL,	
	[Out_HKeyIndustryParentCode]	BINARY(20) NULL,		
	[Out_HKeyHubCode]				BINARY(20) NULL,	
	[Out_HierarchyLevelPL]			NVARCHAR(4000) NULL,	
	[Out_HDiffHierarchyLevelPL]		BINARY(20) NULL,

	[Meta_ETLProcessID]				INT	NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)
