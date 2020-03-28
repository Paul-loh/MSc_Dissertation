CREATE TABLE [stg].[PACER_SecurityClassification]
(
	[ID]									INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	

	[In_SecurityID]							VARCHAR (100) NULL,
	[In_IndustryCode]						VARCHAR (100) NULL,
	[In_RegionCode]							VARCHAR (100) NULL,
	[In_AssetCatCode]						VARCHAR (100) NULL,

	[Out_SecurityID]						NVARCHAR (100) NULL,
	[Out_IndustryCode]						NVARCHAR (100) NULL,
	[Out_RegionCode]						NVARCHAR (100) NULL,
	[Out_AssetCatCode]						NVARCHAR (100) NULL,

	[Out_HKeyLinkSecurityClassification]	BINARY(20) NULL,
	[Out_HKeySecurityID]					BINARY(20) NULL,		

	-- Linked Business Key Hashes
	[Out_HKeyIndustryCode]					BINARY(20) NULL,	
	[Out_HKeyRegionCode]					BINARY(20) NULL,	
	[Out_HKeyAssetCatCode]					BINARY(20) NULL,	

	[Meta_ETLProcessID]						INT	NULL,		
	[Meta_RecordSource]						NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]						DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]			DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]				DATETIME2 NULL,
	[Meta_EffectToDateTime]					DATETIME2 NULL,	
	[Meta_ActiveRow]						BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)
