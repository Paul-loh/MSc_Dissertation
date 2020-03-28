﻿CREATE TABLE [stg].[PACER_Transactions]
(
	[ID]								INT IDENTITY(1,1)	NOT NULL PRIMARY KEY,	
	[In_TRANNUM]						VARCHAR (250) NULL,
	[In_PORTCODE]						VARCHAR (100) NULL,
	[In_SECID]							VARCHAR (100) NULL,
	[In_TRANTYPE]						VARCHAR (100) NULL,
	[In_FOOTNOTE]						VARCHAR (100) NULL,
	[In_CLASS]							VARCHAR (100) NULL,
	[In_STATUS]							VARCHAR (100) NULL,
	[In_TRADDATE]						VARCHAR (100) NULL,
	[In_SHAREPAR]						VARCHAR (100) NULL,
	[In_PRICEU]							VARCHAR (100) NULL,
	[In_PRICCURR]						VARCHAR (100) NULL,
	[In_NETAMTC]						VARCHAR (100) NULL,
	[In_GAINC]							VARCHAR (100) NULL,
	[In_ACCRINTC]						VARCHAR (100) NULL,
	[In_ACCRINTU]						VARCHAR (100) NULL,
	[In_TAXLOT]							VARCHAR (100) NULL,
	[In_ORPARVAL]						VARCHAR (100) NULL,
	[In_SETTDATE]						VARCHAR (100) NULL,
	[In_ACTUSETT]						VARCHAR (100) NULL,
	[In_SETTCURR]						VARCHAR (100) NULL,
	[In_ENTRDATE]						VARCHAR (100) NULL,
	[In_MISC1U]							VARCHAR (100) NULL,
	[In_MISC2U]							VARCHAR (100) NULL,
	[In_MISC3U]							VARCHAR (100) NULL,
	[In_MISC4U]							VARCHAR (100) NULL,
	[In_MISC5U]							VARCHAR (100) NULL,
	[In_MISC6U]							VARCHAR (100) NULL,
	[In_MISCTOTU]						VARCHAR (100) NULL,
	[In_COMMISSU]						VARCHAR (100) NULL,
	[In_COMMISSC]						VARCHAR (100) NULL,
	[In_BROKCODE]						VARCHAR (100) NULL,
	[In_ACQUDATE]						VARCHAR (100) NULL,
	[In_CREDITS]						VARCHAR (100) NULL,
	[In_SUBPORTF]						VARCHAR (100) NULL,
	[In_IMPCOMMC]						VARCHAR (100) NULL,
	[In_COSTOTLC]						VARCHAR (100) NULL,
	[In_CPTYCODE]						VARCHAR (100) NULL,
	[In_ANNOT]							VARCHAR (100) NULL,
	[In_GAINFXC]						VARCHAR (100) NULL,
	[In_TRADTYPE]						VARCHAR (100) NULL,
	[In_BROKFINS]						VARCHAR (100) NULL,
	[In_BROKNAME]						VARCHAR (100) NULL,
	[In_COSTOTLU]						VARCHAR (100) NULL,
	[In_CPTYNAME]						VARCHAR (100) NULL,
	[In_CREDITC]						VARCHAR (100) NULL,
	[In_CREDITU]						VARCHAR (100) NULL,
	[In_DEBITC]							VARCHAR (100) NULL,
	[In_DEBITS]							VARCHAR (100) NULL,
	[In_DEBITU]							VARCHAR (100) NULL,
	[In_DURATION]						VARCHAR (100) NULL,
	[In_EFFEDATE]						VARCHAR (100) NULL,
	[In_ENTRNAME]						VARCHAR (100) NULL,
	[In_ENTROPER]						VARCHAR (100) NULL,
	[In_ENTRTIME]						VARCHAR (100) NULL,
	[In_FORNCASH]						VARCHAR (100) NULL,
	[In_FXRATE]							VARCHAR (100) NULL,
	[In_FXRATEPS]						VARCHAR (100) NULL,
	[In_FXRATESB]						VARCHAR (100) NULL,
	[In_GAINFXU]						VARCHAR (100) NULL,
	[In_GROSAMTC]						VARCHAR (100) NULL,
	[In_GROSAMTU]						VARCHAR (100) NULL,
	[In_IMPCOMMU]						VARCHAR (100) NULL,
	[In_LOCANAME]						VARCHAR (100) NULL,
	[In_LOCATION]						VARCHAR (100) NULL,
	[In_MISC1C]							VARCHAR (100) NULL,
	[In_MISC2C]							VARCHAR (100) NULL,
	[In_MISC3C]							VARCHAR (100) NULL,
	[In_MISC4C]							VARCHAR (100) NULL,
	[In_MISC5C]							VARCHAR (100) NULL,
	[In_MISC6C]							VARCHAR (100) NULL,
	[In_MISCTOTC]						VARCHAR (100) NULL,
	[In_MODIDATE]						VARCHAR (100) NULL,
	[In_MODIOPER]						VARCHAR (100) NULL,
	[In_MODITIME]						VARCHAR (100) NULL,
	[In_ORDRNUM]						VARCHAR (100) NULL,
	[In_PRICEC]							VARCHAR (100) NULL,
	[In_STRATGCD]						VARCHAR (100) NULL,
	[In_STRATGIS]						VARCHAR (100) NULL,
	[In_STRATGMS]						VARCHAR (100) NULL,
	[In_STRATGNM]						VARCHAR (100) NULL,
	[In_STRATGTY]						VARCHAR (100) NULL,
	[In_TRADNUM]						VARCHAR (100) NULL,
	[In_YLDCOST]						VARCHAR (100) NULL,
	[In_YLDTRAN]						VARCHAR (100) NULL,
	[In_NETAMTU]						VARCHAR (100) NULL,
	[In_GAINU]							VARCHAR (100) NULL,
	[In_EXCUM]							VARCHAR (100) NULL,
	[In_EXREFNUM]						VARCHAR (100) NULL,
	[In_MISCCODS]						VARCHAR (100) NULL,

	[Out_TRANNUM]						INT NOT NULL,
	[Out_TRANNUM_Original]				NVARCHAR (100) NULL,
	[Out_PORTCODE]						NVARCHAR (100) NULL,
	[Out_SECID]							NVARCHAR (100) NULL,
	[Out_TRANTYPE]						NVARCHAR (100) NULL,
	[Out_FOOTNOTE]						NVARCHAR (100) NULL,
	[Out_CLASS]							NVARCHAR (100) NULL,
	[Out_TRADDATE]						DATETIME2 NULL,
	[Out_SETTDATE]						DATETIME2 NULL,
	[Out_BROKCODE]						NVARCHAR (100) NULL,	
	[Out_SHAREPAR]						NUMERIC(38,20) NULL,
	
	[Out_PriceCcyISO]					NVARCHAR (100) NULL,
	[Out_SettleCcyISO]					NVARCHAR (100) NULL,

	[Out_FXRATE]						NUMERIC(38,20) NULL,
	[Out_FXRATEPS]						NUMERIC(38,20) NULL,
	[Out_FXRATESB]						NUMERIC(38,20) NULL,
	[Out_PRICEU]						NUMERIC(38,20) NULL,

	[Out_PRICCURR]						NVARCHAR(100) NULL,
	[Out_SETTCURR]						NVARCHAR(100) NULL,
	
	[Out_GROSAMTU]						NUMERIC(38,20) NULL,
	[Out_COMMISSU]						NUMERIC(38,20) NULL,
	[Out_MISCTOTU]						NUMERIC(38,20) NULL,
	[Out_NETAMTU]						NUMERIC(38,20) NULL,
	[Out_COSTOTLU]						NUMERIC(38,20) NULL,
	[Out_GAINU]							NUMERIC(38,20) NULL,
	[Out_GROSAMTC]						NUMERIC(38,20) NULL,
	[Out_COMMISSC]						NUMERIC(38,20) NULL,
	[Out_MISCTOTC]						NUMERIC(38,20) NULL,
	[Out_NETAMTC]						NUMERIC(38,20) NULL,
	[Out_COSTOTLC]						NUMERIC(38,20) NULL,
	[Out_GAINC]							NUMERIC(38,20) NULL,

	[Out_QuantityChange]				NUMERIC(38,20) NULL,
	[Out_CostChangeLC]					NUMERIC(38,20) NULL,
	[Out_CostChangeBC]					NUMERIC(38,20) NULL,
	
	[Out_DEBITU]						NUMERIC(38,20) NULL,
	[Out_CREDITU]						NUMERIC(38,20) NULL,
	[Out_DEBITS]						NUMERIC(38,20) NULL,
	[Out_CREDITS]						NUMERIC(38,20) NULL,
	[Out_DEBITC]						NUMERIC(38,20) NULL,
	[Out_CREDITC]						NUMERIC(38,20) NULL,
	
	[Out_NetCashLC]						NUMERIC(38,20) NULL,
	[Out_NetCashSC]						NUMERIC(38,20) NULL,
	[Out_NetCashBC]						NUMERIC(38,20) NULL,

	[Out_TRADTYPE]						NVARCHAR (100) NULL,
	[Out_ANNOT]							NVARCHAR (100) NULL,
	[Out_EXCUM]							NVARCHAR (100) NULL,
	[Out_EXREFNUM]						INT NULL,
	
	[Out_MISC1U]						NUMERIC(38,20) NULL,
	[Out_MISC2U]						NUMERIC(38,20) NULL,
	[Out_MISC3U]						NUMERIC(38,20) NULL,
	[Out_MISC4U]						NUMERIC(38,20) NULL,
	[Out_MISC5U]						NUMERIC(38,20) NULL,
	[Out_MISC6U]						NUMERIC(38,20) NULL,

	[Out_MISC1C]						NUMERIC(38,20) NULL,
	[Out_MISC2C]						NUMERIC(38,20) NULL,
	[Out_MISC3C]						NUMERIC(38,20) NULL,
	[Out_MISC4C]						NUMERIC(38,20) NULL,
	[Out_MISC5C]						NUMERIC(38,20) NULL,
	[Out_MISC6C]						NUMERIC(38,20) NULL,

	[Out_MISCCODS]						NVARCHAR (100) NULL,
	[Out_STATUS]						NCHAR (3) NULL,
	[Out_ENTRDATE]						DATETIME2 NULL,
	[Out_ENTRTIME]						TIME(7)	NULL,
	[Out_ENTRDATETIME]					DATETIME2 NULL,
	[Out_EFFEDATE]						DATETIME2 NULL,
	[Out_MODIDATE]						DATETIME2 NULL,
	[Out_MODITIME]						TIME(7)	NULL,
	[Out_MODIDATETIME]					DATETIME2 NULL,
	
	[Out_HKeyLinkTransactions]			BINARY(20) NULL,		
	[Out_TransactionPL]					NVARCHAR (4000) NULL,
	[Out_HDiffTransactionPL]			BINARY(20) NULL,		
	[Out_SeqEntryDateTime]				BIGINT NULL,		

	-- Linked Business Key Hashes
	[Out_HKeyPORTCODE]					BINARY(20) NULL,		
	[Out_HKeySECID]						BINARY(20) NULL,		
	[Out_HKeyBROKCODE]					BINARY(20) NULL,		
	[Out_HKeyPriceCcyISO]				BINARY(20) NULL,		
	[Out_HKeySettleCcyISO]				BINARY(20) NULL,		
		
	[Meta_ETLProcessID]					BIGINT	NULL,		
	[Meta_RecordSource]					NVARCHAR (1000) NULL,
	[Meta_LoadDateTime]					DATETIME2 NULL,
	[Meta_SourceSysExportDateTime]		DATETIME2 NULL, 	
	[Meta_EffectFromDateTime]			DATETIME2 NULL,
	[Meta_EffectToDateTime]				DATETIME2 NULL,	
	[Meta_ActiveRow]					BIT	NULL DEFAULT 1		-- Identify active record e.g. usually last import
) 

