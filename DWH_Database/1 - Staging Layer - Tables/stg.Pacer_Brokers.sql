CREATE TABLE [stg].[PACER_Brokers]
(
	[ID]							INT IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[In_Columns]					VARCHAR (1000) NULL,
	[Out_BrokerCodeBK]				NVARCHAR (100) NULL,	
	[Out_BrokerName]				NVARCHAR (1000) NULL,	
	[Out_HKeyHubBroker]				BINARY(20) NULL,	
	[Out_BrokerPL]					NVARCHAR(4000) NULL,	
	[Out_HDiffBrokerPL]				BINARY(20) NULL,	
	[Meta_ETLProcessID]				INT	NULL,		
	[Meta_RecordSource]				NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]				DATETIME2 NULL DEFAULT N'9999-12-31',
	[Meta_SourceSysExportDateTime]	DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]		DATETIME2 NULL,
	[Meta_EffectToDateTime]			DATETIME2 NULL,	
	[Meta_ActiveRow]				BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
)
