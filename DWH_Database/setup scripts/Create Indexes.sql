--	Author:				Paul Loh	
--	Creation Date:		20200213
--	Description:		Indexes for virutalised Dimensional Model query performance improvements.


--	PRICE SOURCES 

CREATE NONCLUSTERED INDEX [NIX_RefPriceSources] ON [ref].[RefPriceSources]
(
	[RecordPriority] ASC,
	[PriSrcPriority] ASC	
) 
INCLUDE ( [Meta_LoadDateTime],	[Meta_LoadEndDateTime], [PrimaryType], [PriceSource], [RecordPriority],	[PriSrcPriority] )
GO


CREATE NONCLUSTERED INDEX [NIX_RefPriceSources_MetaLoadDT_MetaLoadEndDT] ON [ref].[RefPriceSources]
(
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[PrimaryType] ASC,
	[PriceSource] ASC,
	[RecordPriority] ASC,
	[PriSrcPriority] ASC
)
INCLUDE([PriceCcy],[Residence]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO


--	SECURITIES

CREATE NONCLUSTERED INDEX [NIX_SatSecurities_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatSecurities] 
(
	[Meta_LoadDateTime]		ASC,
	[Meta_LoadEndDateTime]	ASC
) 
GO

CREATE UNIQUE CLUSTERED INDEX [CIX_SatSecurities_MetaLoadDT_MetaLoadEndDT_HKey] ON [dv].[SatSecurities]
(
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[HKeySecurity] ASC

)
GO

CREATE NONCLUSTERED INDEX [NIX_SatSecurities_MetaLoadDT_MetaLoadEndDT_HKey] ON [dv].[SatSecurities]
(
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[HKeySecurity] ASC
) 
INCLUDE 
(
	[SecID],
	[PrimaryType],
	[SecondaryType],
	[PriceCcyISO],
	[ResidenceCtry],
	[Multiplier]
)	
GO



-- CURRENCIES 
CREATE UNIQUE CLUSTERED INDEX [CIX_SatCurrencies_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatCurrencies]
(
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[HKeyCurrency] ASC,
	[SSCCode] ASC,
	[CurrencyGroup] ASC
)
GO


-- TRANSACTIONS 
ALTER TABLE [dv].[LinkTransactions] ADD CONSTRAINT [CIX_LinkTransactions] UNIQUE CLUSTERED 
(
	[HKeyTransaction] ASC,
	[HKeyPortfolio] ASC,
	[HKeySecurity] ASC,
	[HKeyBroker] ASC,
	[HKeyPriceCcyISO] ASC,
	[HKeySettleCcyISO] ASC,
	[TRANNUM] ASC
)
GO

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


CREATE NONCLUSTERED INDEX [NIX_SatTransactions_HKeyTransaction]  ON [dv].[SatTransactions]
(
	[HKeyTransaction] ASC,
	[PORTCODE] ASC,
	[STATUS] ASC,
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [CIX_SatTransactions_MetaLoadDT_MetaLoadEndDT_HKey] ON [dv].[SatTransactions]
(
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[HKeyTransaction] ASC
)
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

CREATE NONCLUSTERED INDEX [NIX_LinkFXRates_HKeyFXRate_HKeyCurrency] ON [dv].[LinkFXRates]
(
	[HKeyFXRate] ASC,
	[HKeyCurrency] ASC,
	[CurrencyCode] ASC,
	[RateDate] ASC
)
GO


CREATE NONCLUSTERED INDEX [NIX_SatFXRates_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatFXRates] 
(
	[Meta_LoadDateTime]		ASC,
	[Meta_LoadEndDateTime]	ASC
) 
GO

CREATE CLUSTERED INDEX [CIX_SatFXRates_HKeyFXRate_MetaLoadDT_MetaLoadEndDT] ON [dv].[SatFXRates]
(	
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[HKeyFXRate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



--	CALENDAR


/****** Object:  Index [NIX_RefPriceSources]    Script Date: 28/05/2020 20:12:21 ******/
CREATE NONCLUSTERED INDEX [NIX_RefCalendar] ON [ref].[RefCalendar]
(
	[Meta_LoadDateTime] ASC,
	[Meta_LoadEndDateTime] ASC,
	[CalendarDate] ASC
)
INCLUDE (
			DateKey,
			[Day],
			[Month],
			[Year],
			[Quarter], 
			[DayOfWeek],
			DayOfQuarter,
			[DayOfYear],
			WeekNumISO,
			MonthOfQuarter,
			StartOfMonth,
			EndOfMonth,
			StartOfQuarter, 
			EndOfQuarter,
			StartOfCalYear,
			EndOfCalYear,
			StartOfFinYear
			,[d]
			,[dd]
			,[ddd]
			,[dddd]
			,[m]
			,[mm]
			,[mmm]
			,[mmmm]
			,[q]
			,[qqqq]
			,[yyyy] 
			,[yy]
			,[FY_m]
			,[FY_mm]
			,[FY_q]
			,[FY_qqqq]
			,[FY_yy]
			,[FY_yyyy]			 
			,[IsWeekDay]
			,[IsHolidayUK]
			,[HolidayUK]
)

GO





