CREATE TABLE [dv].[SatSecurityClassificationEffectivity]
(
	[HKeyLinkSecurityClassification]	BINARY(20) NOT NULL,				
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT NOT NULL,					-- FK to ID of import batch audit table
	
	[EffectiveFromDateTime]								DATETIME2 NOT NULL,
	[EffectiveToDateTime]								DATETIME2 NOT NULL DEFAULT N'9999-12-31',
    CONSTRAINT [PK_SatIndustryHierarchyEffectivity]		PRIMARY KEY NONCLUSTERED	(	
																						[HKeyLinkSecurityClassification], 
																						[Meta_LoadDateTime] 
																					)
)
