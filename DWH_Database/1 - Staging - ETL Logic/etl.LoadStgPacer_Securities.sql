CREATE PROCEDURE [etl].[PACER_LoadStgSecurities] (
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS

	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load Pacer Securities Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN

	BEGIN TRY
	
		DECLARE @TranCount		INT;

		
		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_Securities] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;


		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Securities] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Securities] t
		WHERE		t.Meta_LoadDateTime				<>	@LoadDateTime;		

		INSERT INTO [stg].[PACER_Securities] 
							(
								[In_SecID]					,
								[In_IssuerName]				,
								[In_IssueDesc]				,
								[In_Ticker]					,
								[In_PrimaryType]			,
								[In_SecondaryType]			,
								[In_TertiaryType]			,
								[In_IsFloatingRate]			,
								[In_IsFwdBwdSecID]			,
								[In_IncomePayFreq]			,
								[In_IncomeStatus]			,
								[In_PriceCcy]				,
								[In_IncomeCcy]				,
								[In_EarningsCcy]			,
								[In_ResidenceCtry]			,
								[In_AnnualIncome]			,
								[In_CurrentExDate]			,
								[In_LastAdjDate]			,
								[In_SplitRate]				,
								[In_FirstInterestDate]		,
								[In_Latest12MthEPS]			,
								[In_FxDealRate]				,
								[In_AccrualDate]			,
								[In_PaymentStream]			,
								[In_FRSUSchCode]			,
								[In_VotingCode]				,
								[In_SettleDTCEligible]		,
								[In_StdIndustryClass]		,
								[In_IssueDate]				,
								[In_RedeemDate]				,
								[In_AltRedeemDate]			,
								[In_ConstPrepayRate]		,
								[In_OutstandingShares]		,
								[In_BondIssuerType]			,
								[In_NextCallDate]			,
								[In_Multiplier]				,
								[In_NextCallPrice]			,
								[In_SecCategory]			,
								[In_IssuerCode]				,
								[In_CompoundingFreq]		,
								[In_LastUpdate]				,
								[In_EntryDate]				,
								[In_DbSource]				,
								[In_ExchangeCtry]			,

								[Out_SecID]					,
								[Out_IssuerName]			,
								[Out_IssueDesc]				,
								[Out_Ticker]				,
								[Out_PrimaryType]			,
								[Out_SecondaryType]			,
								[Out_TertiaryType]			,
								[Out_IsFloatingRate]		,
								[Out_IsFwdBwdSecID]			,
								[Out_IncomePayFreq]			,
								[Out_IncomeStatus]			,
								[Out_PriceCcy]				,
								[Out_IncomeCcy]				,
								[Out_EarningsCcy]			,

								/*		
										ISO currency conversion 
										Strictly speaking loading from staging layer to DWH should only deal with raw data from source system
								*/
								[Out_PriceCcyISO],
								[Out_IncomeCcyISO],
								[Out_EarningsCcyISO],

								[Out_ResidenceCtry]			,
								[Out_AnnualIncome]			,
								[Out_CurrentExDate]			,
								[Out_LastAdjDate]			,
								[Out_SplitRate]				,
								[Out_FirstInterestDate]		,
								[Out_Latest12MthEPS]		,
								[Out_FxDealRate]			,
								[Out_AccrualDate]			,
								[Out_PaymentStream]			,
								[Out_FRSUSchCode]			,
								[Out_VotingCode]			,
								[Out_SettleDTCEligible]		,
								[Out_StdIndustryClass]		,
								[Out_IssueDate]				,
								[Out_RedeemDate]			,
								[Out_AltRedeemDate]			,
								[Out_ConstPrepayRate]		,
								[Out_OutstandingShares]		,
								[Out_BondIssuerType]		,
								[Out_NextCallDate]			,
								[Out_Multiplier]			,
								[Out_NextCallPrice]			,
								[Out_SecCategory]			,
								[Out_IssuerCode]			,
								[Out_CompoundingFreq]		,
								[Out_LastUpdate]			,
								[Out_EntryDate]				,
								[Out_DbSource]				,
								[Out_ExchangeCtry]			

								-- ,[Out_HKeyHubSecurities]
								,[Out_SecurityPL]
								-- ,[Out_HDiffSecurityPL]

								,[Meta_ETLProcessID]	
								,[Meta_RecordSource]
								,[Meta_LoadDateTime]
								,[Meta_SourceSysExportDateTime]
								,[Meta_EffectFromDateTime]
								,[Meta_EffectToDateTime]
								,[Meta_ActiveRow]			  
							 )

		SELECT 

			-- INPUTS
				[SecID],
				[IssuerName],
				[IssueDesc],
				[Ticker],
				[PrimaryType],
				[SecondaryType],
				[TertiaryType],
				[IsFloatingRate],
				[IsFwdBwdSecID],
				[IncomePayFreq],
				[IncomeStatus],
				[PriceCcy],
				[IncomeCcy],
				[EarningsCcy],
				[ResidenceCtry],
				[AnnualIncome],
				[CurrentExDate],
				[LastAdjDate],
				[SplitRate],
				[FirstInterestDate],
				[Latest12MthEPS],
				[FxDealRate],
				[AccrualDate],
				[PaymentStream],
				[FRSUSchCode],
				[VotingCode],
				[SettleDTCEligible],
				[StdIndustryClass],
				[IssueDate],
				[RedeemDate],
				[AltRedeemDate],
				[ConstPrepayRate],
				[OutstandingShares],
				[BondIssuerType],
				[NextCallDate],
				[Multiplier],
				[NextCallPrice],
				[SecCategory],
				[IssuerCode],
				[CompoundingFreq],
				[LastUpdate],
				[EntryDate],
				[DbSource],
				[ExchangeCtry]

			-- OUTPUTS
				,TRIM(SecID)				as SecurityID
				,TRIM(IssuerName)			as IssuerName
				,TRIM(IssueDesc)			as IssueDesc
				,TRIM(Ticker)				as Ticker
				,TRIM(PrimaryType)			as PrimaryType
				,TRIM(SecondaryType)		as SecondaryType
				,TRIM(TertiaryType)			as TertiaryType
				,TRIM(IsFloatingRate)		AS IsFloatingRate
				,TRIM(IsFwdBwdSecID)		AS IsFwdBwdSecID
				,TRIM(IncomePayFreq)		AS IncomePayFreq
				,TRIM(IncomeStatus)			AS IncomeStatus
				,TRIM(PriceCcy)				AS PriceCcy
				,TRIM(IncomeCcy)			AS IncomeCcy
				,TRIM(EarningsCcy)			AS EarningsCcy

				-- ISO currency conversion - strictly speaking loading from staging layer to DWH should only deal with raw data from source systems?
				,c1.CurrencyCode			AS PriceCcyISO
				,c2.CurrencyCode			AS IncomeCcyISO
				,c3.CurrencyCode			AS EarningsCcyISO

				,(case when TRIM(ResidenceCtry) != N'' then TRIM(ResidenceCtry) else N'ZZ' end)		AS ResidenceCtry		-- TBD: GHOST RECORD INSTEAD IN REFERENCE TABLES?
				,CAST(TRIM(AnnualIncome) AS NUMERIC(38, 20))										AS AnnualIncome
				
				,CAST((	CASE	WHEN TRIM(sec.[CurrentExDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[CurrentExDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[CurrentExDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[CurrentExDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[CurrentExDate] ), 5, 2) 
								END ) AS DATETIME2 )																		AS CurrentExDate		

				,CAST((	CASE	WHEN TRIM(sec.[LastAdjDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[LastAdjDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[LastAdjDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[LastAdjDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[LastAdjDate] ), 5, 2) 
								END ) AS DATETIME2 )																		AS LastAdjDate		

				,CAST(TRIM(SplitRate) AS NUMERIC(38, 20))			AS SplitRate

				,CAST((	CASE	WHEN TRIM(sec.[FirstInterestDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[FirstInterestDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[FirstInterestDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[FirstInterestDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[FirstInterestDate] ), 5, 2) 
								END ) AS DATETIME2 )																		AS FirstInterestDate		
												
				,CAST(TRIM(Latest12MthEPS) AS NUMERIC(38, 20))		AS Latest12MthEPS
				,CAST(TRIM(FxDealRate) AS NUMERIC(38, 20))			AS FxDealRate

				,CAST((	CASE	WHEN TRIM(sec.[AccrualDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[AccrualDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[AccrualDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[AccrualDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[AccrualDate] ), 5, 2) 
								END ) AS DATETIME2 )																			AS AccrualDate		


				,TRIM(PaymentStream)								AS PaymentStream
				,TRIM(FRSUSchCode)									AS FRSUSchCode
				,TRIM(VotingCode)									AS VotingCode
				,TRIM(SettleDTCEligible)							AS SettleDTCEligible
				,TRIM(StdIndustryClass)								AS StdIndustryClass

				,CAST((	CASE	WHEN TRIM(sec.[IssueDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[IssueDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[IssueDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[IssueDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[IssueDate] ), 5, 2) 
								END ) AS DATETIME2 )																			AS IssueDate		

				,CAST((	CASE	WHEN TRIM(sec.[RedeemDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[RedeemDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[RedeemDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[RedeemDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[RedeemDate] ), 5, 2) 
								END ) AS DATETIME2 )																			AS RedeemDate	

				,CAST((	CASE	WHEN TRIM(sec.[AltRedeemDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[AltRedeemDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[AltRedeemDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[AltRedeemDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[AltRedeemDate] ), 5, 2) 
								END ) AS DATETIME2 )																			AS AltRedeemDate	
				
				,CAST(TRIM(ConstPrepayRate) AS NUMERIC(38, 20))																	AS ConstPrepayRate
				,CAST(TRIM(OutstandingShares) AS NUMERIC(38, 20))																AS OutstandingShares
				,TRIM(BondIssuerType)																							AS BondIssuerType

				,CAST((	CASE	WHEN TRIM(sec.[NextCallDate]) = N'' 
								THEN N'1901-01-01' 
								ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[NextCallDate] ), 1, 2) > 60 
												THEN N'19' ELSE N'20' END ) 
										+ SUBSTRING( TRIM( sec.[NextCallDate] ), 1, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[NextCallDate] ), 3, 2) + '-' 
										+ SUBSTRING( TRIM( sec.[NextCallDate] ), 5, 2) 
								END ) AS DATETIME2 )																			AS NextCallDate	

				,CAST(TRIM(Multiplier) AS NUMERIC(38, 20))				AS Multiplier
				,CAST(TRIM(NextCallPrice) AS NUMERIC(38, 20))			AS NextCallPrice
				,TRIM(SecCategory)										AS SecCategory
				,TRIM(IssuerCode)										AS IssuerCode
				,TRIM(CompoundingFreq)									AS CompoundingFreq
				,CAST(TRIM(LastUpdate) AS DATETIME2)					AS LastUpdate				
				,CAST(TRIM(EntryDate) AS DATETIME2)						AS EntryDate				
				,TRIM(DbSource)											AS DbSource
				,TRIM(ExchangeCtry)										AS ExchangeCtry

			---- Hash value of Business Key 
			--	,HASHBYTES(N'SHA1', UPPER(TRIM( ISNULL(sec.SecID, N'')))) AS HKeyHubSecurities

			-- Payload
				,CONCAT_WS( N'|', 
								TRIM(ISNULL([SecID], N'')),  
								TRIM(ISNULL([IssuerName], N'')),  
								TRIM(ISNULL([IssueDesc], N'')),				
								TRIM(ISNULL([Ticker], N'')),				
								TRIM(ISNULL([PrimaryType], N'')),				
								TRIM(ISNULL([SecondaryType], N'')),				
								TRIM(ISNULL([TertiaryType], N'')),				
								TRIM(ISNULL([IsFloatingRate], N'')),				
								TRIM(ISNULL([IsFwdBwdSecID], N'')),				
								TRIM(ISNULL([IncomePayFreq], N'')),				
								TRIM(ISNULL([IncomeStatus], N'')),				
								TRIM(ISNULL([PriceCcy], N'')),				
								TRIM(ISNULL([IncomeCcy], N'')),				
								TRIM(ISNULL([EarningsCcy], N'')),				
								TRIM(ISNULL([ResidenceCtry], N'')),				
								TRIM(ISNULL([AnnualIncome], N'')),				
								TRIM(ISNULL([CurrentExDate], N'')),				
								TRIM(ISNULL([LastAdjDate], N'')),				
								TRIM(ISNULL([SplitRate], N'')),				
								TRIM(ISNULL([FirstInterestDate], N'')),				
								TRIM(ISNULL([Latest12MthEPS], N'')),				
								TRIM(ISNULL([FxDealRate], N'')),				
								TRIM(ISNULL([AccrualDate], N'')),				
								TRIM(ISNULL([PaymentStream], N'')),				
								TRIM(ISNULL([FRSUSchCode], N'')),				
								TRIM(ISNULL([VotingCode], N'')),				
								TRIM(ISNULL([SettleDTCEligible], N'')),				
								TRIM(ISNULL([StdIndustryClass], N'')),				
								TRIM(ISNULL([IssueDate], N'')),				
								TRIM(ISNULL([RedeemDate], N'')),				
								TRIM(ISNULL([AltRedeemDate], N'')),				
								TRIM(ISNULL([ConstPrepayRate], N'')),				
								TRIM(ISNULL([OutstandingShares], N'')),				
								TRIM(ISNULL([BondIssuerType], N'')),				
								TRIM(ISNULL([NextCallDate], N'')),				
								TRIM(ISNULL([Multiplier], N'')),				
								TRIM(ISNULL([NextCallPrice], N'')),				
								TRIM(ISNULL([SecCategory], N'')),				
								TRIM(ISNULL([IssuerCode], N'')),				
								TRIM(ISNULL([CompoundingFreq], N'')),				
								TRIM(ISNULL([LastUpdate], N'')),				
								TRIM(ISNULL([EntryDate], N'')),				
								TRIM(ISNULL([DbSource], N'')),				
								TRIM(ISNULL([ExchangeCtry], N''))
							) AS SecurityPL

			---- Payload HASH VALUE - including the Business Key components
			--	,HASHBYTES(N'SHA1', 
			--				CONCAT_WS(N'|', 
			--					TRIM(ISNULL([SecID], N'')),  
			--					TRIM(ISNULL([IssuerName], N'')),  
			--					TRIM(ISNULL([IssueDesc], N'')),				
			--					TRIM(ISNULL([Ticker], N'')),				
			--					TRIM(ISNULL([PrimaryType], N'')),				
			--					TRIM(ISNULL([SecondaryType], N'')),				
			--					TRIM(ISNULL([TertiaryType], N'')),				
			--					TRIM(ISNULL([IsFloatingRate], N'')),				
			--					TRIM(ISNULL([IsFwdBwdSecID], N'')),				
			--					TRIM(ISNULL([IncomePayFreq], N'')),				
			--					TRIM(ISNULL([IncomeStatus], N'')),				
			--					TRIM(ISNULL([PriceCcy], N'')),				
			--					TRIM(ISNULL([IncomeCcy], N'')),				
			--					TRIM(ISNULL([EarningsCcy], N'')),				
			--					TRIM(ISNULL([ResidenceCtry], N'')),				
			--					TRIM(ISNULL([AnnualIncome], N'')),				
			--					-- TRIM(ISNULL([CurrentExDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[CurrentExDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[CurrentExDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[CurrentExDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[CurrentExDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[CurrentExDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 

			--					-- TRIM(ISNULL([LastAdjDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[LastAdjDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[LastAdjDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[LastAdjDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[LastAdjDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[LastAdjDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 

			--					TRIM(ISNULL([SplitRate], N'')),				
								
			--					--TRIM(ISNULL([FirstInterestDate], N'')),			
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[FirstInterestDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[FirstInterestDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[FirstInterestDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[FirstInterestDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[FirstInterestDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 

			--					TRIM(ISNULL([Latest12MthEPS], N'')),				
			--					TRIM(ISNULL([FxDealRate], N'')),				
								
			--					-- TRIM(ISNULL([AccrualDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[AccrualDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[AccrualDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[AccrualDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[AccrualDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[AccrualDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 

			--					TRIM(ISNULL([PaymentStream], N'')),				
			--					TRIM(ISNULL([FRSUSchCode], N'')),				
			--					TRIM(ISNULL([VotingCode], N'')),				
			--					TRIM(ISNULL([SettleDTCEligible], N'')),				
			--					TRIM(ISNULL([StdIndustryClass], N'')),				
								
			--					-- TRIM(ISNULL([IssueDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[IssueDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[IssueDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[IssueDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[IssueDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[IssueDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 
											
			--					-- TRIM(ISNULL([RedeemDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[RedeemDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[RedeemDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[RedeemDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[RedeemDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[RedeemDate] ), 5, 2) 
			--												END ) AS DATETIME2 )											
			--								, 126), 

			--					-- TRIM(ISNULL([AltRedeemDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[AltRedeemDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[AltRedeemDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[AltRedeemDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[AltRedeemDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[AltRedeemDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 

			--					TRIM(ISNULL([ConstPrepayRate], N'')),				
			--					TRIM(ISNULL([OutstandingShares], N'')),				
			--					TRIM(ISNULL([BondIssuerType], N'')),				
								
			--					-- TRIM(ISNULL([NextCallDate], N'')),				
			--					CONVERT(	NVARCHAR(30), 
			--								CAST((	CASE	WHEN TRIM(sec.[NextCallDate]) = N'' 
			--												THEN N'1901-01-01' 
			--												ELSE (	CASE	WHEN SUBSTRING (TRIM( sec.[NextCallDate] ), 1, 2) > 60 
			--																THEN N'19' ELSE N'20' END ) 
			--														+ SUBSTRING( TRIM( sec.[NextCallDate] ), 1, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[NextCallDate] ), 3, 2) + '-' 
			--														+ SUBSTRING( TRIM( sec.[NextCallDate] ), 5, 2) 
			--												END ) AS DATETIME2 )
			--								, 126), 

			--					TRIM(ISNULL([Multiplier], N'')),				
			--					TRIM(ISNULL([NextCallPrice], N'')),				
			--					TRIM(ISNULL([SecCategory], N'')),				
			--					TRIM(ISNULL([IssuerCode], N'')),				
			--					TRIM(ISNULL([CompoundingFreq], N'')),				
			--					-- TRIM(ISNULL([LastUpdate], N'')),		
			--					CONVERT( NVARCHAR(30), CAST(TRIM([LastUpdate]) AS DATETIME2), 126 ), 
			--					-- TRIM(ISNULL([EntryDate], N'')),				
			--					CONVERT( NVARCHAR(30), CAST(TRIM([EntryDate]) AS DATETIME2), 126 ), 
			--					TRIM(ISNULL([DbSource], N'')),				
			--					TRIM(ISNULL([ExchangeCtry], N''))																			
			--				))	AS PLHashDiff
														
				,sec.[Meta_ETLProcessID]
				,N'PACER.SEC'							AS [RecordSource]
				,sec.[Meta_LoadDateTime]				AS [Meta_LoadDateTime]
				,NULL									AS [SourceSysExportDateTime]
				,sec.[Meta_LoadDateTime]				AS [Meta_EffectFromDateTime]	
				,CAST( N'9999-12-31' AS DATETIME2 )		AS [Meta_EffectToDateTime]
				,1										AS [Meta_ActiveRow]
	
			FROM tmp.PACER_Securities sec

			LEFT JOIN (
							SELECT		h.HKeyCurrency, h.CurrencyCode, s.SSCCode
							FROM		dv.HubCurrencies h
							LEFT JOIN	dv.SatCurrencies s
							ON			h.HKeyCurrency = s.HKeyCurrency
							WHERE		COALESCE( s.Meta_LoadEndDateTime, CAST(N'9999-12-31' AS DATETIME2)) = CAST(N'9999-12-31' AS DATETIME2)
						) AS c1
			ON	c1.[SSCCode] = TRIM(sec.PriceCcy)

			LEFT JOIN (
							SELECT		h.HKeyCurrency, h.CurrencyCode, s.SSCCode
							FROM		dv.HubCurrencies h
							LEFT JOIN	dv.SatCurrencies s
							ON			h.HKeyCurrency = s.HKeyCurrency
							WHERE		COALESCE( s.Meta_LoadEndDateTime, CAST(N'9999-12-31' AS DATETIME2)) = CAST(N'9999-12-31' AS DATETIME2)
						) AS c2
			ON	c2.[SSCCode] = TRIM(sec.IncomeCcy)

			LEFT JOIN (
							SELECT		h.HKeyCurrency, h.CurrencyCode, s.SSCCode
							FROM		dv.HubCurrencies h
							LEFT JOIN	dv.SatCurrencies s
							ON			h.HKeyCurrency = s.HKeyCurrency
							WHERE		COALESCE( s.Meta_LoadEndDateTime, CAST(N'9999-12-31' AS DATETIME2)) = CAST(N'9999-12-31' AS DATETIME2)
						) AS c3
			ON	c3.[SSCCode] = TRIM(sec.EarningsCcy)

			WHERE	sec.Meta_LoadDateTime		=	@LoadDateTime 



		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE	stg.PACER_Securities

			-- Hash value of Business Key 
			SET	Out_HKeyHubSecurities	=	HASHBYTES(N'SHA1', UPPER(TRIM( ISNULL( [Out_SecID] , N'')))) 
				
			-- Payload HASH VALUE - including the Business Key components
				,Out_HDiffSecurityPL	=	HASHBYTES(N'SHA1', UPPER(TRIM( ISNULL( [Out_SecurityPL], N'')))) 

		FROM	stg.PACER_Securities
		WHERE	Meta_LoadDateTime	=	@LoadDateTime;
		
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgSecurities : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO