--	Author:				Paul Loh	
--	Creation Date:		20200213
--	Description:		Indexes for virutalised Dimensional Model query performance improvements.


CREATE NONCLUSTERED INDEX [NIX_RefPriceSources] ON [ref].[RefPriceSources]
(
	[RecordPriority] ASC,
	[PriSrcPriority] ASC	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


--	SECURITIES

CREATE NONCLUSTERED INDEX [NIX_SatSecurities_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatSecurities] 
(
	[Meta_LoadDateTime]		ASC,
	[Meta_LoadEndDateTime]	ASC
) 
GO

CREATE UNIQUE CLUSTERED INDEX [CIX_SatSecurities_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatSecurities]
(
	[HKeySecurity] ASC,
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


-- TRANSACTIONS 

CREATE NONCLUSTERED INDEX [NIX_SatTransactions_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatTransactions] 
(
	[Meta_LoadDateTime]		ASC,
	[Meta_LoadEndDateTime]	ASC
) 
GO

CREATE NONCLUSTERED INDEX [NIX_SatTransactions_Filtered_MetaLoadEndDT_Status] ON [dv].[SatTransactions]
(	
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[HKeyTransaction] ASC
)
INCLUDE ( 	
	[STATUS],
	[PORTCODE],
	[SECID],
	[TRADDATE],
	[TRANTYPE],
	[PriceCcyISO],
	[SettleCcyISO],
	[QuantityChange],
	[FOOTNOTE],
	[TRADTYPE]) 
WHERE ([Status]=N'PCR' AND [Meta_LoadEndDateTime]=N'9999-12-31')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


--	PRICES
CREATE NONCLUSTERED INDEX [NIX_LinkPrices_HKeySecurity_PriceType_PriceDate] ON [dv].[LinkPrices] 
(
	[HKeySecurity]			ASC,
	[PriceType]				ASC,
	[PriceDate]				ASC
) 
GO

CREATE NONCLUSTERED INDEX [NIX_SatPrices_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatPrices] 
(
	[Meta_LoadDateTime]		ASC,
	[Meta_LoadEndDateTime]	ASC
) 
GO

CREATE CLUSTERED INDEX [CIX_SatPrices_HKeyPrice_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatPrices]
(
	[HKeyPrice] ASC,
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC
)
GO



--	FX RATES
CREATE NONCLUSTERED INDEX [NIX_SatFXRates_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatFXRates] 
(
	[Meta_LoadDateTime]		ASC,
	[Meta_LoadEndDateTime]	ASC
) 
GO

CREATE CLUSTERED INDEX [CIX_SatFXRates_HKeyFXRate_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatFXRates]
(
	[HKeyFXRate] ASC,
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

