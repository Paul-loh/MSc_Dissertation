CREATE TABLE [dv].[SatCustodianPositions]
(
	[HKeyCustodianPosition]						BINARY(20) NOT NULL,	
	[Meta_LoadDateTime]							DATETIME2 NOT NULL,	
	[Meta_LoadEndDateTime]						DATETIME2 NOT NULL DEFAULT N'9999-12-31',
	[Meta_SrcSysExportDateTime]					DATETIME2 NULL,	
	[Meta_RecordSource]							NVARCHAR (1000) NOT NULL,
	[Meta_ETLProcessID]							INT	NOT NULL,				-- FK to ID of import batch 			

	[HDiffCustodianPositionPL]					BINARY(20) NOT NULL, 

	[LocationCode]								NVARCHAR(100) NULL,
	[AssetLocation]								NVARCHAR(100) NULL,
	[LocationDescription]						NVARCHAR(1000) NULL,
	
	[RegistrarCode]								NVARCHAR(100) NULL,
	[RegistrarDescription]						NVARCHAR(100) NULL,
	
	[RegistrationCode]							NVARCHAR(100) NULL,
	[RegistrationDescription]					NVARCHAR(100) NULL,

	[MaturityDate]								DATETIME2 NULL,

	[TradedAggregate]							NUMERIC(38,20) NULL,
	[SettledAggregate]							NUMERIC(38,20) NULL,
	[AvailableBalance]							NUMERIC(38,20) NULL,

	-- [SecurityCurrency]							NVARCHAR(100) NULL,
	[SecurityPrice]								NUMERIC(38,20) NULL,
	[SecurityOnLoan]							NUMERIC (38,20) NULL,
	[TradedValue_SecurityCurrency]				NUMERIC(38,20) NULL,
	[SettledAggregateValue_SecurityCurrency]	NUMERIC(38,20) NULL,
	[TradedValue_AccountCurrency]				NUMERIC(38,20) NULL,
	[SettledAggregateValue_AccountCurrency]		NUMERIC(38,20) NULL,
	[ExchangeRate]								NUMERIC(38,20) NULL,

    CONSTRAINT [PK_SatCustodianPositions]	PRIMARY KEY NONCLUSTERED ([HKeyCustodianPosition], [Meta_LoadDateTime])
)
