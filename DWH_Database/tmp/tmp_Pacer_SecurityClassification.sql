CREATE TABLE [tmp].[PACER_SecurityClassification]
(	
	[SecurityID]			[varchar](100) NULL,
	[IndustryCode]			[varchar](100) NULL,
	[RegionCode]			[varchar](100) NULL,
	[AssetCatCode]			[varchar](100) NULL,
	[Meta_ETLProcessID]		INT NULL,
	[Meta_LoadDateTime]		DATETIME2 NULL
) ON [PRIMARY]