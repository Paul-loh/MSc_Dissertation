CREATE TABLE [dv].[HubValuations]
(
	[HKeyValuation]					BINARY(20) NOT NULL,
	[Meta_LoadDateTime]				DATETIME2 NOT NULL,
	[Meta_LastSeenDateTime]			DATETIME2 NOT NULL,				-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]				NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]				INT	NOT NULL,					-- FK to ID of import batch audit table	?

	[PORTCDBK]						NVARCHAR (100) NULL,
	[SECIDBK]						NVARCHAR (100) NULL,
	[VALDATEBK]						DATETIME2 NULL,
	[BOKFXCBK]						NCHAR (3) NULL,

	CONSTRAINT [PK_HubValuations]	PRIMARY KEY NONCLUSTERED ([HKeyValuation], [Meta_LoadDateTime]), 
	CONSTRAINT [UIX_HubValuations]	UNIQUE CLUSTERED ( [PORTCDBK] ASC, [SECIDBK] ASC, [VALDATEBK] ASC, [BOKFXCBK] ASC) -- Good practice to add a unique index constraint on Business Key columns
)
