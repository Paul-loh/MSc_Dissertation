CREATE TABLE [ref].[RefTransactionAnalysisMapping]
(	
	[Meta_LoadDateTime]						DATETIME2 NOT NULL,
	[Meta_LoadEndDateTime]					DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	-- As no CDC from source used to check duration since data last sent
	[Meta_RecordSource]						NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]						INT	NOT NULL,				-- FK to ID of import batch audit table	?

	[From_TransType]						NVARCHAR (100) NOT NULL DEFAULT N'',
	[From_FootNote]							NVARCHAR (100) NOT NULL DEFAULT N'',
	[From_TradeType]						NVARCHAR (100) NOT NULL DEFAULT N'',
	[From_PrimaryType]						NVARCHAR (100) NOT NULL DEFAULT N'',

	[To_Trans_Category]						NVARCHAR (100) NOT NULL DEFAULT N'',
	[To_Unit_Category]						NVARCHAR (100) NOT NULL DEFAULT N'',
	[To_Cash_Category]						NVARCHAR (100) NOT NULL DEFAULT N'',
	
	CONSTRAINT [UIX_RefTransactionAnalysis]	UNIQUE CLUSTERED	(
																	[Meta_LoadDateTime]		ASC,
																	[From_TransType]		ASC,
																	[From_FootNote]			ASC, 
																	[From_TradeType]		ASC, 
																	[From_PrimaryType]		ASC,
																	[To_Trans_Category]		ASC,
																	[To_Unit_Category]		ASC,
																	[To_Cash_Category]		ASC
																)    
)

