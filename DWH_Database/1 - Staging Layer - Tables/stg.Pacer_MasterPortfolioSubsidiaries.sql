CREATE TABLE [stg].[PACER_MasterPortfolioSubsidiaries]
(
	[In_MasterCode]								VARCHAR(100) NULL,
	[In_SubPortfCode]							VARCHAR(100) NULL,	

	[Out_MasterCode]							NVARCHAR(100) NULL,
	[Out_SubPortfCode]							NVARCHAR(100) NULL,	

	[Out_HKeyLinkPortfolioMasterSubsidiary]		BINARY(20) NULL,		
	[Out_HKeyHubMasterCode]						BINARY(20) NULL,
	[Out_HKeyHubSubPortfCode]					BINARY(20) NULL,

	[Meta_ETLProcessID]							INT NULL,		
	[Meta_RecordSource]							NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]							DATETIME2 NULL,
	[Meta_SourceSysExportDateTime]				DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]					DATETIME2 NULL,
	[Meta_EffectToDateTime]						DATETIME2 NULL,	
	[Meta_ActiveRow]							BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import	
)