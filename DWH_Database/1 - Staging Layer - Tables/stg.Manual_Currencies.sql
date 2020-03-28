CREATE TABLE [stg].[MANUAL_Currencies]
(
	[ID]							INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[In_CcyCode]					VARCHAR (50) NULL,
	[In_SSCCode]					VARCHAR (50) NULL,
	[In_CurrencyName]				VARCHAR (50) NULL,
	[In_Group]						VARCHAR (50) NULL, 
	[Out_CcyCodeBK]					NCHAR (3) NULL,	
	[Out_SSCCode]					NCHAR (2) NULL,
	[Out_CurrencyName]				NVARCHAR (100) NULL,
	[Out_Group]						INT NULL,
	[Out_HKeyHubCurrencies]			BINARY(20) NULL,	
	[Out_CurrencyPL]				NVARCHAR(4000) NULL,	
	[Out_HDiffCurrencyPL]			BINARY(20) NULL,	
	[Meta_ETLProcessID]				INT	NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)

