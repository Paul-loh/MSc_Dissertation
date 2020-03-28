CREATE TABLE [stg].[PACER_MasterPortfolios]
(
	[ID]								INT IDENTITY(1,1)	NOT NULL PRIMARY KEY,
	[In_AsFromDate]						VARCHAR(100) NULL,
	[In_PortfCode]						VARCHAR(100) NULL,
	[In_MasterType]						VARCHAR(100) NULL,
	
	[Out_AsFromDate]					NVARCHAR(100) NULL,
	[Out_PortfCode]						NVARCHAR(100) NULL,
	[Out_MasterType]					NVARCHAR(100) NULL,

	[Out_HKeyHubPortfolio]				BINARY(20) NULL,
	[Out_MasterPortfolioPL]				NVARCHAR(4000) NULL,
	[Out_HDiffMasterPortfolioPL]		BINARY(20) NULL,
	
	[Meta_ETLProcessID]					INT NULL,		
	[Meta_RecordSource]					NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]					DATETIME2 NULL,
	[Meta_SourceSysExportDateTime]		DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]			DATETIME2 NULL,
	[Meta_EffectToDateTime]				DATETIME2 NULL,	
	[Meta_ActiveRow]					BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import	
)