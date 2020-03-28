﻿CREATE TABLE [tmp].[PACER_Transactions](
	[PORTCODE] [varchar](100) NULL,
	[SECID] [varchar](100) NULL,
	[TRANTYPE] [varchar](100) NULL,
	[FOOTNOTE] [varchar](100) NULL,
	[CLASS] [varchar](100) NULL,
	[STATUS] [varchar](100) NULL,
	[TRADDATE] [varchar](100) NULL,
	[SHAREPAR] [varchar](100) NULL,
	[PRICEU] [varchar](100) NULL,
	[PRICCURR] [varchar](100) NULL,
	[NETAMTC] [varchar](100) NULL,
	[GAINC] [varchar](100) NULL,
	[ACCRINTC] [varchar](100) NULL,
	[ACCRINTU] [varchar](100) NULL,
	[TAXLOT] [varchar](100) NULL,
	[ORPARVAL] [varchar](100) NULL,
	[SETTDATE] [varchar](100) NULL,
	[ACTUSETT] [varchar](100) NULL,
	[SETTCURR] [varchar](100) NULL,
	[ENTRDATE] [varchar](100) NULL,
	[MISC1U] [varchar](100) NULL,
	[MISC2U] [varchar](100) NULL,
	[MISC3U] [varchar](100) NULL,
	[MISC4U] [varchar](100) NULL,
	[MISC5U] [varchar](100) NULL,
	[MISC6U] [varchar](100) NULL,
	[MISCTOTU] [varchar](100) NULL,
	[COMMISSU] [varchar](100) NULL,
	[COMMISSC] [varchar](100) NULL,
	[BROKCODE] [varchar](100) NULL,
	[ACQUDATE] [varchar](100) NULL,
	[CREDITS] [varchar](100) NULL,
	[SUBPORTF] [varchar](100) NULL,
	[IMPCOMMC] [varchar](100) NULL,
	[COSTOTLC] [varchar](100) NULL,
	[CPTYCODE] [varchar](100) NULL,
	[ANNOT] [varchar](100) NULL,
	[GAINFXC] [varchar](100) NULL,
	[TRADTYPE] [varchar](100) NULL,
	[BROKFINS] [varchar](100) NULL,
	[BROKNAME] [varchar](100) NULL,
	[COSTOTLU] [varchar](100) NULL,
	[CPTYNAME] [varchar](100) NULL,
	[CREDITC] [varchar](100) NULL,
	[CREDITU] [varchar](100) NULL,
	[DEBITC] [varchar](100) NULL,
	[DEBITS] [varchar](100) NULL,
	[DEBITU] [varchar](100) NULL,
	[DURATION] [varchar](100) NULL,
	[EFFEDATE] [varchar](100) NULL,
	[ENTRNAME] [varchar](100) NULL,
	[ENTROPER] [varchar](100) NULL,
	[ENTRTIME] [varchar](100) NULL,
	[FORNCASH] [varchar](100) NULL,
	[FXRATE] [varchar](100) NULL,
	[FXRATEPS] [varchar](100) NULL,
	[FXRATESB] [varchar](100) NULL,
	[GAINFXU] [varchar](100) NULL,
	[GROSAMTC] [varchar](100) NULL,
	[GROSAMTU] [varchar](100) NULL,
	[IMPCOMMU] [varchar](100) NULL,
	[LOCANAME] [varchar](100) NULL,
	[LOCATION] [varchar](100) NULL,
	[MISC1C] [varchar](100) NULL,
	[MISC2C] [varchar](100) NULL,
	[MISC3C] [varchar](100) NULL,
	[MISC4C] [varchar](100) NULL,
	[MISC5C] [varchar](100) NULL,
	[MISC6C] [varchar](100) NULL,
	[MISCTOTC] [varchar](100) NULL,
	[MODIDATE] [varchar](100) NULL,
	[MODIOPER] [varchar](100) NULL,
	[MODITIME] [varchar](100) NULL,
	[ORDRNUM] [varchar](100) NULL,
	[PRICEC] [varchar](100) NULL,
	[STRATGCD] [varchar](100) NULL,
	[STRATGIS] [varchar](100) NULL,
	[STRATGMS] [varchar](100) NULL,
	[STRATGNM] [varchar](100) NULL,
	[STRATGTY] [varchar](100) NULL,
	[TRADNUM] [varchar](100) NULL,
	[YLDCOST] [varchar](100) NULL,
	[YLDTRAN] [varchar](100) NULL,
	[NETAMTU] [varchar](100) NULL,
	[GAINU] [varchar](100) NULL,
	[EXCUM] [varchar](100) NULL,
	[EXREFNUM] [varchar](100) NULL,
	[MISCCODS] [varchar](100) NULL,
	[TRANNUM] [varchar](250) NULL,
	[Meta_ETLProcessID] INT NULL, 
    [Meta_LoadDateTime] DATETIME2 NULL
)	ON [PRIMARY]
