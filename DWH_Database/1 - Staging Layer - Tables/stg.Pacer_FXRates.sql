CREATE TABLE [stg].[PACER_FXRates]
(	
	[ID]							INT IDENTITY(1,1) NOT NULL,	
	[In_CcyCode]					VARCHAR (100) NULL,
	[In_RateToGBP]					VARCHAR (100) NULL,
	[In_RateDate]					VARCHAR (100) NULL,
	
	[Out_CurrencyCode]				NVARCHAR(100) NULL,				-- Unique Constraint on Meta_ETLProcessID, Out_SSCCcyCode & Out_RateDate
	[Out_RateDate]					DATETIME2 NULL,
	[Out_RateToGBP]					NUMERIC (38,20) NULL,
	[Out_SSCCcyCode]				NVARCHAR (100) NULL,	

	[Out_HKeyFXRates]				BINARY (20) NULL,
	[Out_FXRatesPL]					NVARCHAR (4000) NULL,
	[Out_HDiffFXRatesPL]			BINARY (20) NULL,
	[Out_HKeyCurrencyCode]			BINARY (20) NULL,

	[Meta_ETLProcessID]				INT	NULL,			
	[Meta_RecordSource]				NVARCHAR (100) NULL, 
	[Meta_LoadDateTime]				DATETIME2 NULL,
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1,				-- Identify active record e.g. usually last import
	CONSTRAINT [PK_PACER_FXRates]	PRIMARY KEY ([ID])
)