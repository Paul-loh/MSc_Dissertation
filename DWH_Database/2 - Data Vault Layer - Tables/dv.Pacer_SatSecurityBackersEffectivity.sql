CREATE TABLE [dv].[SatSecurityBackersEffectivity]
(	
	[HKeySecurityBacker]								BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]									DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]								DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_RecordSource]									NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]									INT	NOT NULL,				-- FK to ID of import batch 		
	[EffectiveFromDateTime]								DATETIME2 NOT NULL,
	[EffectiveToDateTime]								DATETIME2 NOT NULL DEFAULT N'9999-12-31',
    CONSTRAINT [PK_SatSecurityBackersEffectivity]		PRIMARY KEY NONCLUSTERED	(	
																						[HKeySecurityBacker], 
																						[Meta_LoadDateTime] 
																					)
)
GO