﻿CREATE TABLE [tmp].[PACER_Securities](
	[SecID] [varchar](100) NULL,
	[IssuerName] [varchar](100) NULL,
	[IssueDesc] [varchar](100) NULL,
	[Ticker] [varchar](100) NULL,
	[PrimaryType] [varchar](100) NULL,
	[SecondaryType] [varchar](100) NULL,
	[TertiaryType] [varchar](100) NULL,
	[IsFloatingRate] [varchar](100) NULL,
	[IsFwdBwdSecID] [varchar](100) NULL,
	[IncomePayFreq] [varchar](100) NULL,
	[IncomeStatus] [varchar](100) NULL,
	[PriceCcy] [varchar](100) NULL,
	[IncomeCcy] [varchar](100) NULL,
	[EarningsCcy] [varchar](100) NULL,
	[ResidenceCtry] [varchar](100) NULL,
	[AnnualIncome] [varchar](100) NULL,
	[CurrentExDate] [varchar](100) NULL,
	[LastAdjDate] [varchar](100) NULL,
	[SplitRate] [varchar](100) NULL,
	[FirstInterestDate] [varchar](100) NULL,
	[Latest12MthEPS] [varchar](100) NULL,
	[FxDealRate] [varchar](100) NULL,
	[AccrualDate] [varchar](100) NULL,
	[PaymentStream] [varchar](100) NULL,
	[FRSUSchCode] [varchar](100) NULL,
	[VotingCode] [varchar](100) NULL,
	[SettleDTCEligible] [varchar](100) NULL,
	[StdIndustryClass] [varchar](100) NULL,
	[IssueDate] [varchar](100) NULL,
	[RedeemDate] [varchar](100) NULL,
	[AltRedeemDate] [varchar](100) NULL,
	[ConstPrepayRate] [varchar](100) NULL,
	[OutstandingShares] [varchar](100) NULL,
	[BondIssuerType] [varchar](100) NULL,
	[NextCallDate] [varchar](100) NULL,
	[Multiplier] [varchar](100) NULL,
	[NextCallPrice] [varchar](100) NULL,
	[SecCategory] [varchar](100) NULL,
	[IssuerCode] [varchar](100) NULL,
	[CompoundingFreq] [varchar](100) NULL,
	[LastUpdate] [varchar](100) NULL,
	[EntryDate] [varchar](100) NULL,
	[DbSource] [varchar](100) NULL,
	[ExchangeCtry] [varchar](100) NULL, 
	[Meta_ETLProcessID] INT NULL,
	[Meta_LoadDateTime] DATETIME2 NULL
)	ON [PRIMARY]


