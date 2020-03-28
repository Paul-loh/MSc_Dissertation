CREATE TABLE [dv].[SatBrokers]
(
	[HKeyBroker]						BINARY(20) NOT NULL,
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffBrokerPL]						BINARY(20) NOT NULL,     	
	[BrokerName]						NVARCHAR (1000) NOT NULL,
	CONSTRAINT [PK_SatBrokers] PRIMARY KEY NONCLUSTERED ( [HKeyBroker], [Meta_LoadDateTime] )
)
