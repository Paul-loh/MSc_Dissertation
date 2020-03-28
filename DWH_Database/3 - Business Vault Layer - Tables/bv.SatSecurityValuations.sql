CREATE TABLE [bv].[SatSecurityValuations]		
(	
	[HKeySecuritySummary]				BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffSecuritySummaryPL]			BINARY(20) NULL, 
	
	ValuationLC							NUMERIC (38,20) NULL,
	ValuationBC							NUMERIC (38,20) NULL,

	CONSTRAINT [PK_SatSecuritySummary]	PRIMARY KEY NONCLUSTERED ( [HKeySecuritySummary], [Meta_LoadDateTime] )
)
;