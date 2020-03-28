CREATE TABLE [stg].[PACER_Valuations]
(
	[ID]							INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[In_PORTCD]						VARCHAR (100) NULL,		-- Portfolio Code
	[In_SECID]						VARCHAR (100) NULL,		-- Security Code
	[In_VALDATE]					VARCHAR (100) NULL,		-- Valuation Date 
	[In_BOKFXC]						VARCHAR (100) NULL,		-- Price Currency 
	[In_HOLDINGS]					VARCHAR (100) NULL, 
	[In_COST]						VARCHAR (100) NULL, 
	[In_VALUE]						VARCHAR (100) NULL, 
	[In_COSTNAT]					VARCHAR (100) NULL, 
	[In_VALUNAT]					VARCHAR (100) NULL, 
	[In_PNAT]						VARCHAR (100) NULL, 

	[Out_PORTCDBK]					NVARCHAR (100) NULL,
	[Out_SECIDBK]					NVARCHAR (100) NULL,
	[Out_VALDATEBK]					DATETIME2 NULL,
	[Out_BOKFXCBK]					NCHAR (3) NULL,
	[Out_HOLDINGS]					NUMERIC(38,20) NULL,
	[Out_COST]						NUMERIC(38,20) NULL,
	[Out_VALUE]						NUMERIC(38,20) NULL,
	[Out_COSTNAT]					NUMERIC(38,20) NULL,
	[Out_VALUNAT]					NUMERIC(38,20) NULL,
	[Out_PNAT]						NUMERIC(38,20) NULL,
	   			
	[Out_HKeyHubValuations]			BINARY(20) NULL,	
	[Out_ValuationPL]				NVARCHAR (4000) NULL,
	[Out_HDiffValuationPL]			BINARY(20) NULL,	

	[Meta_ETLProcessID]				INT	NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL,
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)
