CREATE TABLE [dv].[SatValuations]
(
	[HKeyValuation]					BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,	
	[Meta_LoadEndDateTime]			DATETIME2 NOT NULL DEFAULT '9999-12-31',
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffValuationPL]				BINARY(20) NOT NULL, 
	[HOLDINGS]						NUMERIC(38,20) NULL,
	[COST]							NUMERIC(38,20) NULL,
	[VALUE]							NUMERIC(38,20) NULL,
	[COSTNAT]						NUMERIC(38,20) NULL,
	[VALUNAT]						NUMERIC(38,20) NULL,
	[PNAT]							NUMERIC(38,20) NULL,	   		
    CONSTRAINT [PK_SatValuations]	PRIMARY KEY NONCLUSTERED ([HKeyValuation], [Meta_LoadDateTime])
)
