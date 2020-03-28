CREATE TABLE [dv].[SatBackers]
(
	[HKeyBacker]						BINARY(20) NOT NULL,
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT	NOT NULL,				-- FK to ID of import batch 		
	[HDiffBackerPL]						BINARY(20) NOT NULL,     	
	[ShortName]							NVARCHAR (1000) NOT NULL,
	CONSTRAINT [PK_SatBackers] PRIMARY KEY NONCLUSTERED ( [HKeyBacker], [Meta_LoadDateTime] )
)
