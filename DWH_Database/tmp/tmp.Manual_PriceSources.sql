CREATE TABLE [tmp].[Manual_PriceSources]
(
	[RecordPriority]		VARCHAR(100) NULL,
	[PrimaryType]			VARCHAR(100) NULL,
	[PriceCcy]				VARCHAR(100) NULL,
	[Residence]				VARCHAR(100) NULL,
	[PriSrcPriority]		VARCHAR(100) NULL,
	[PriceSource]			VARCHAR(100) NULL,
	[Meta_ETLProcessID]		INT NULL,
	[Meta_LoadDateTime]		DATETIME2 NULL
)	ON [PRIMARY]

