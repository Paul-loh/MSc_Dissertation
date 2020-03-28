CREATE TABLE [tmp].[Manual_TransactionMappings]
(
	[From_TransType]		VARCHAR(100) NULL,
	[From_FootNote]			VARCHAR(100) NULL,
	[From_TradeType]		VARCHAR(100) NULL,
	[From_PrimaryType]		VARCHAR(100) NULL,
	[To_Trans_Category]		VARCHAR(100) NULL,
	[To_Unit_Category]		VARCHAR(100) NULL,
	[To_Cash_Category]		VARCHAR(100) NULL,
	[Meta_ETLProcessID]		INT NULL,
	[Meta_LoadDateTime]		DATETIME2 NULL
)	ON [PRIMARY]

