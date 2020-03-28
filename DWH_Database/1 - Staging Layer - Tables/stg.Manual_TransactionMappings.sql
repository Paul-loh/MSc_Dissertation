CREATE TABLE [stg].[Manual_TransactionMappings]
(
	[ID]							INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	

	[In_From_TransType]				VARCHAR(100) NULL,
	[In_From_FootNote]				VARCHAR(100) NULL,
	[In_From_TradeType]				VARCHAR(100) NULL,
	[In_From_PrimaryType]			VARCHAR(100) NULL,
	[In_To_Trans_Category]			VARCHAR(100) NULL,
	[In_To_Unit_Category]			VARCHAR(100) NULL,
	[In_To_Cash_Category]			VARCHAR(100) NULL,

	[Out_From_TransType]			NVARCHAR(100) NULL,
	[Out_From_FootNote]				NVARCHAR(100) NULL,
	[Out_From_TradeType]			NVARCHAR(100) NULL,
	[Out_From_PrimaryType]			NVARCHAR(100) NULL,
	[Out_To_Trans_Category]			NVARCHAR(100) NULL,
	[Out_To_Unit_Category]			NVARCHAR(100) NULL,
	[Out_To_Cash_Category]			NVARCHAR(100) NULL,
		
	[Meta_ETLProcessID]				INT	NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)

