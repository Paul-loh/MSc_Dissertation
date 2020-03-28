CREATE TABLE [stg].[Manual_PriceSources]
(
	[ID]							INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	

	[In_RecordPriority]				VARCHAR(100) NULL,
	[In_PrimaryType]				VARCHAR(100) NULL,
	[In_PriceCcy]					VARCHAR(100) NULL,
	[In_Residence]					VARCHAR(100) NULL,
	[In_PriSrcPriority]				VARCHAR(100) NULL,
	[In_PriceSource]				VARCHAR(100) NULL,

	[Out_RecordPriority]			INT NULL,
	[Out_PrimaryType]				NCHAR(1) NULL,
	[Out_PriceCcy]					NCHAR(3) NULL,
	[Out_Residence]					NCHAR(2) NULL,
	[Out_PriSrcPriority]			INT NULL,
	[Out_PriceSource]				NVARCHAR(3) NULL,	
	
	[Meta_ETLProcessID]				INT	NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)

