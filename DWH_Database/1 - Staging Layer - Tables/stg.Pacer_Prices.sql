﻿CREATE TABLE [stg].[PACER_Prices]
(
	[ID]								INT IDENTITY(1,1) NOT NULL ,	
	[In_SecID]							VARCHAR(100) NULL,
	[In_IssuerName]						VARCHAR(100) NULL,
	[In_IssueDesc]						VARCHAR(100) NULL,
	[In_Date]							VARCHAR(100) NULL,
	[In_Source]							VARCHAR(100) NULL,
	[In_Type]							VARCHAR(100) NULL,
	[In_Flag]							VARCHAR(100) NULL,
	[In_HighPrice]						VARCHAR(100) NULL,
	[In_LowPrice]						VARCHAR(100) NULL,
	[In_ClosePrice]						VARCHAR(100) NULL,
	[In_BidPrice]						VARCHAR(100) NULL,
	[In_AskPrice]						VARCHAR(100) NULL,
	[In_YieldToBid]						VARCHAR(100) NULL,
	[In_VolumeTraded]					VARCHAR(100) NULL,
	[In_EntryDate]						VARCHAR(100) NULL,	
	[Out_SecurityCode]					NVARCHAR(100) NOT NULL,
	[Out_PriceDate]						DATETIME2 NOT NULL,
	[Out_PriceType]						NVARCHAR(100) NOT NULL,
	[Out_PriceSource]					NVARCHAR(100)  NOT NULL,
	[Out_StatusFlag]					NVARCHAR(100) NULL,
	[Out_ClosePrice]					NUMERIC (38,20) NULL,
	[Out_BidPrice]						NUMERIC (38,20) NULL,
	[Out_AskPrice]						NUMERIC (38,20) NULL,
	[Out_HighPrice]						NUMERIC (38,20) NULL,
	[Out_LowPrice]						NUMERIC (38,20) NULL,
	[Out_TradingVolume]					INT NULL,
	[Out_Yield]							NUMERIC (38,20) NULL,
	[Out_EntryDate]						DATETIME2 NULL,
	[Out_HKeyPrices]					BINARY(20) NULL,	
	[Out_PricePL]						NVARCHAR(4000) NULL,	
	[Out_HDiffPricePL]					BINARY(20) NULL,	
	[Out_HKeySecID]						BINARY(20) NULL,	
	[Meta_ETLProcessID]					INT NULL,	
	[Meta_RecordSource]					NVARCHAR (1000) NULL,	
	[Meta_LoadDateTime]					DATETIME2 NULL ,
	[Meta_SourceSysExportDateTime]		DATETIME2 NULL, 
	[Meta_EffectFromDateTime]			DATETIME2 NULL,
	[Meta_EffectToDateTime]				DATETIME2 NULL DEFAULT '9999-12-31',
	[Meta_ActiveRow]					BIT NULL DEFAULT 1		-- Identify active record e.g. usually last import
    CONSTRAINT [PK_PACER_Prices] PRIMARY KEY ([ID])
) ON [PRIMARY]