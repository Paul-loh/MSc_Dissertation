CREATE TABLE [ref].[RefPriceSources]
(	
	[Meta_LoadDateTime]					DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]				DATETIME2 NOT NULL DEFAULT N'9999-12-31',
-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]					NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]					INT	NOT NULL,				-- FK to ID of import batch audit table	?

	[RecordPriority]					INT NULL,
	[PrimaryType]						NCHAR(1) NULL,
	[PriceCcy]							NCHAR(3) NULL,
	[Residence]							NCHAR(2) NULL,
	[PriSrcPriority]					INT NULL,
	[PriceSource]						NVARCHAR(3) NULL,	
	CONSTRAINT [UIX_refPriceSources]	UNIQUE CLUSTERED	(
																[Meta_LoadDateTime] ASC,	
																[Meta_LoadEndDateTime] ASC,	
																[PrimaryType] ASC,
																[PriceCcy] ASC,
																[Residence] ASC,
																[PriceSource] ASC,
																[RecordPriority] ASC,
																[PriSrcPriority] ASC
															)    
)
