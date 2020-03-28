﻿CREATE TABLE [tmp].[PACER_Prices]
(
	[SecID] [varchar](100) NULL,
	[IssuerName] [varchar](100) NULL,
	[IssueDesc] [varchar](100) NULL,
	[Date] [varchar](100) NULL,
	[Source] [varchar](100) NULL,
	[Type] [varchar](100) NULL,
	[Flag] [varchar](100) NULL,
	[HighPrice] [varchar](100) NULL,
	[LowPrice] [varchar](100) NULL,
	[ClosePrice] [varchar](100) NULL,
	[BidPrice] [varchar](100) NULL,
	[AskPrice] [varchar](100) NULL,
	[YieldToBid] [varchar](100) NULL,
	[VolumeTraded] [varchar](100) NULL,
	[EntryDate] [varchar](100) NULL,
	[Meta_ETLProcessID] INT NULL,
	[Meta_LoadDateTime] DATETIME2 NULL
) ON [PRIMARY]
