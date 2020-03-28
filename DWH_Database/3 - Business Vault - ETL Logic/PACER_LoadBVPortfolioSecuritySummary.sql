CREATE PROCEDURE [etl].[PACER_LoadBVPortfolioSecuritySummary]	(
																	@ReportDate		DATE,
																	@LoadDateTime	DATETIME2,
																	@AsOfDateTime	DATETIME2,
																	@ETLProcessID	INT		=	-1
																)
WITH EXECUTE AS OWNER 
AS
/* 
	Author:					Paul Loh
	Business Rule Ref:		BR001
	Description:			
	
		The As Of DateTime parameter will usually be defaulted to the latest Load DateTime. 
		However, this parameter gives caller ability to calculate positions based on DWH records present 
		at a particular past DateTime. 

		Grain:		Portfolio \ Security \ Price Currency \ Settlement Currency \ Price \ FXRateToGBP 
*/

/*
	With normal load \ calculation uses records currently available in Data Vault at last point-in-time.
	With re-load \ re-calculation uses records available at point-in-time at which re-load is required for.

	3 date parameters:
	
		1. The Report date\time		-	Date up to which summary data is being calculated.
		2. The Data Load date\time
		3. The Data AsOf date\time	-	Date used to filter dependent records on LoadDateTime \ LoadEndDateTime.  
										For normal load this would be the same as @LoadDateTime.
*/

	DECLARE		@Meta_RecordSource	AS NVARCHAR(100) =	N'BR001|Portfolio.Security Summary' ;
	
--	Load Link
	
	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	INSERT INTO		[bv].[LinkPortfolioSecuritySummary]
		(
			[HKeyPortfolioSecuritySummary]	,			-- Hash of Portfolio, Security Code, Price Currency, Settlement Currency, Price, Price Source, FX Rate, Report Date, AsOf DateTime and Load Datetime
			[Meta_LoadDateTime]				,
			[Meta_LastSeenDateTime]		,				-- Last time calculation attempted 
			[Meta_RecordSource]			,
			[Meta_ETLProcessID]			,				-- FK to ID of import batch audit table	?
		
			[HKeyPortfolio]				,				--	UIX		-- Driving Key		
			[HKeySecurity]				,				--	UIX		-- Driving Key
			[HKeyPriceCurrency]			,				--	UIX		-- Driving Key
			[HKeySettleCurrency]		,				--	UIX		-- Driving Key		
			[HKeyPriceCurrencyPrice]		,			--	UIX		 
			[HKeyPriceCurrencyFXRateToGBP]	,			--	UIX		

			-- Natural Business Keys 
			[ReportDate]				,				--	UIX		-- Driving Key			
			[AsOfDateTime]				,				--	UIX		-- Snapshot time (different from Load DateTime if doing a re-load)

			[PortfCode]					,				-- BK
			[SecID]						,				-- BK
			[PriceCurrencyCode]			,				-- BK
			[SettleCurrencyCode]		,				-- BK
			[PriceCurrencyBidPrice]		,
			[PriceCurrencyFXRateToGBP]	
		)

	SELECT 
			HASHBYTES	( N'SHA1',
							UPPER(	
								CONCAT_WS( N'|',
												hp.PortfCode,
												hs.SecID,
												hpc.CurrencyCode,							--	Price currency
												hsc.CurrencyCode,							--	Settlement currency
												CONVERT( NVARCHAR(30), @LoadDateTime, 126),	--	Standardise throughout Datetime format used in Hashing
												CONVERT( NVARCHAR(30), @ReportDate, 23),	
												CONVERT( NVARCHAR(30), @AsOfDateTime, 126)	
										)
								)
						)				AS [HKeyPortfolioSecuritySummary],
			@LoadDateTime				AS [Meta_LoadDateTime],
			@LoadDateTime				AS [Meta_LastSeenDateTime],			-- TBD: Is this redundant?
			@Meta_RecordSource			AS [Meta_RecordSource],
			@ETLProcessID				AS [Meta_ETLProcessID],

			-- TBD: Insert Ghost records if no actual record delivered in the data vault 

			hp.HKeyPortfolio			,									--	UIX
			hs.HKeySecurity				,									--	UIX				
			h.HKeyPriceCcyISO			AS [HKeyPriceCurrency],				--	UIX
			h.HKeySettleCcyISO			AS [HKeySettleCurrency],			--	UIX
			
			CASE WHEN p.HKeyPrice IS NULL 
				THEN	0x1111111111111111111111111111111111111111	--	Ghost Record
				ELSE	p.HKeyPrice					
				END						AS [HKeyPriceLC],					--	UIX		

			CASE WHEN f.HKeyFXRate IS NULL 
				THEN	0x1111111111111111111111111111111111111111	--	Ghost Record
				ELSE	f.HKeyFXRate					
				END						AS [HKeyFXRateToGBP],					--	UIX		
							
			@ReportDate					AS [ReportDate],						--	UIX						
			@AsOfDateTime				AS [AsOfDateTime],						--	UIX
			hp.PortfCode,														--	BK
			hs.SecID,															--	BK
			hpc.CurrencyCode			AS [PriceCurrencyCode], 				--	BK					
			hsc.CurrencyCode			AS [SettleCurrencyCode], 				--	BK					
			p.BidPrice					AS [PriceCurrencyBidPrice],
			f.RateToGBP					AS [PriceCurrencyFXRateToGBP]

	FROM		
		(
			SELECT	
						lt.HKeyPortfolio,
						lt.HKeySecurity,
						lt.HKeyPriceCcyISO, 
						lt.HKeySettleCcyISO						
	
			FROM		dv.LinkTransactions lt
			INNER JOIN	dv.SatTransactions st
			ON			lt.HKeyTransaction	=	st.HKeyTransaction
	
			WHERE		@AsOfDateTime	BETWEEN	st.Meta_LoadDateTime AND st.Meta_LoadEndDateTime													
			AND			st.[STATUS]		=		N'PCR'

			/*
					********************			TBD!!!!!!!				********************			
					Maintain Effectivity Satellites on Hubs + Links so we can run queries \ calculations and specify: 
										
							1. Data as it was at specific time-point AND \ OR
							2. Information as it should be at specific time-point ???

						If a As Of Datetime is not specified, then the default would be to use the current Load Datetime. 
								
						If a As Of Datetime is specified then this can be used to re-run queries \ calculations using the 
						data as it was at that time. This can be used for re-loading calculations due to load errors and auditability purposes.					
			*/
									   
			GROUP BY	lt.HKeyPortfolio,
						lt.HKeySecurity,
						lt.HKeyPriceCcyISO,
						lt.HKeySettleCcyISO

			HAVING		ROUND( SUM( COALESCE( st.[QuantityChange], 0.0) ), 1) 	<>	0.0

		)	AS h

		INNER JOIN	dv.HubPortfolios	hp
		ON			h.HKeyPortfolio		=	hp.HKeyPortfolio

		INNER JOIN	dv.SatPortfolios	sp
		ON			hp.HKeyPortfolio	=	sp.HKeyPortfolio
		
		INNER JOIN	dv.HubSecurities	hs
		ON			h.HKeySecurity		=	hs.HKeySecurity 

		INNER JOIN	dv.SatSecurities	ss
		ON			hs.HKeySecurity		=	ss	.HKeySecurity 

		INNER JOIN	dv.HubCurrencies	hpc
		ON			h.HKeyPriceCcyISO	=	hpc.HKeyCurrency
			
		INNER JOIN	dv.SatCurrencies	spc
		ON			hpc.HKeyCurrency	=	spc.HKeyCurrency
				
		INNER JOIN	dv.HubCurrencies	hsc
		ON			h.HKeySettleCcyISO	=	hsc.HKeyCurrency

		INNER JOIN	dv.SatCurrencies	ssc
		ON			hsc.HKeyCurrency	=	ssc.HKeyCurrency


	--	Get Security Price available at AsOf Datetime
		LEFT JOIN 
			(
				-- TBD: Return Price Ghost Record if none available at Load DateTime 

					--	TBD: Need to agree Business rule to determine highest priority price. NOTE: here I've order by Trading Volume too?

				SELECT		lp.HKeyPrice, 
							lp.HKeySecurity, 							
							ROW_NUMBER() OVER(	PARTITION BY	lp.HKeySecurity, lp.PriceDate, lp.PriceType																				
												ORDER BY		RecordPriority ASC , PriSrcPriority ASC, TradingVolume DESC		
												)																		AS PriceRowNo ,		
							lp.PriceDate, 
							lp.PriceSource, 
							lp.PriceType, 
							sp.Meta_LoadDateTime	AS Price_LoadDatetTime, 
							ss.Meta_LoadDateTime	AS Security_LoadDateTime,
							sp.BidPrice
																											
				FROM		dv.LinkPrices	lp

				INNER JOIN	dv.SatPrices	sp
				ON			lp.HKeyPrice	=	sp.HKeyPrice

				INNER JOIN	dv.SatSecurities ss
				ON			lp.HKeySecurity	=	ss.HKeySecurity
			
				--	Priority
				LEFT JOIN	ref.RefPriceSources rp
				-- ON			ISNULL( rp.PrimaryType, LEFT(ss.SecondaryType, 1) )	=	LEFT( ss.SecondaryType, 1 )
				ON			ISNULL( rp.PrimaryType, ss.PrimaryType )			=	ss.PrimaryType 
				AND			ISNULL( rp.PriceCcy,	ss.PriceCcy )				=	ss.PriceCcy
				AND			ISNULL( rp.Residence,	ss.ResidenceCtry)			=	ss.ResidenceCtry
				AND			ISNULL( rp.PriceSource, lp.PriceSource)				=	lp.PriceSource

				AND			@AsOfDateTime BETWEEN	rp.Meta_LoadDateTime	AND		rp.Meta_LoadEndDateTime

				WHERE		lp.PriceDate	= 
							(
									SELECT	MAX( PriceDate ) AS LastPriceDate 
									FROM	dv.LinkPrices	s
									WHERE	s.PriceDate			<=	@ReportDate		
									AND		s.HKeySecurity		=	lp.HKeySecurity
							)

				AND			@AsOfDateTime	BETWEEN sp.Meta_LoadDateTime	AND	sp.Meta_LoadEndDateTime	--	Active record at time of load
				AND			@AsOfDateTime	BETWEEN ss.Meta_LoadDateTime	AND ss.Meta_LoadEndDateTime		

				--		Check Price Type to use 
				--		If AsOfDateTime is the end-of-month date use Price Type 'M' else use 'D'				
				
					--	TBD:	Need to default to Price Type 'D' if Price Type 'M' is not available 
				AND			lp.PriceType		=		( 
															SELECT	CASE	
																	WHEN  rc.CalendarDate	=	rc.EndOfMonth
																	THEN	N'M'
																	ELSE	N'D'	END			
															FROM	ref.RefCalendar rc
															WHERE	CalendarDate	=	@ReportDate 
															AND		@AsOfDateTime	BETWEEN rc.Meta_LoadDateTime 
																					AND		rc.Meta_LoadEndDateTime
														)														
			)	AS p

			ON		p.HKeySecurity	=	h.HKeySecurity		


		--	Get FX Rate reference to use 
		LEFT JOIN	
			(
				-- TBD: Return FX rate Ghost Record if none available at Load DateTime 					
				SELECT		lf.HKeyCurrency,
							lf.HKeyFXRate,							
							lf.RateDate,
							sf.RateToGBP
				FROM		dv.LinkFXRates	lf
				INNER JOIN	dv.SatFXRates	sf
				ON			lf.HKeyFXRate				=	sf.HKeyFXRate
				WHERE		lf.RateDate					=	
														(
																SELECT	MAX( s.RateDate ) AS LastPriceDate 
																FROM	dv.LinkFXRates	s
																WHERE	s.RateDate			<=	@ReportDate
																AND		s.HKeyCurrency		=	lf.HKeyCurrency
														)							
				AND			@AsOfDateTime	BETWEEN		sf.Meta_LoadDateTime	AND sf.Meta_LoadEndDateTime
			)	AS f

		ON	h.HKeyPriceCcyISO		=	f.HKeyCurrency

	WHERE	ISNULL(p.PriceRowNo, 1)	=	1		-- Highest prioritised price 	
	
	-- Filter on avalailable descriptive data in Sattelites at AsOfDate
	AND		@AsOfDateTime	BETWEEN sp.Meta_LoadDateTime	AND	sp.Meta_LoadEndDateTime
	AND		@AsOfDateTime	BETWEEN ss.Meta_LoadDateTime	AND	ss.Meta_LoadEndDateTime
	AND		@AsOfDateTime	BETWEEN spc.Meta_LoadDateTime	AND	spc.Meta_LoadEndDateTime
	AND		@AsOfDateTime	BETWEEN ssc.Meta_LoadDateTime	AND	ssc.Meta_LoadEndDateTime
	

	-- TBD: Include only Quoted and Income Pool Portfolios 
	
	
	-- The link record shouldn't already exist, otherwise we'll get PK violation
	AND NOT EXISTS 
		(
			SELECT		*
			FROM		[bv].[LinkPortfolioSecuritySummary] sub			
			WHERE		sub.HKeyPortfolio		=	h.HKeyPortfolio
			AND			sub.HKeySecurity		=	h.HKeySecurity
			AND			sub.HKeyPriceCurrency	=	h.HKeyPriceCcyISO
			AND			sub.HKeySettleCurrency	=	h.HKeySettleCcyISO
			AND			sub.ReportDate			=	@ReportDate
			AND			sub.Meta_LoadDateTime	=	@LoadDateTime		
			AND			sub.AsOfDateTime		=	@AsOfDateTime			
		) 	
	;
	


--	Load Satellites
	-- Insert new payloads

	-- Satellite Security Holdings
	INSERT INTO [bv].[SatPortfolioSecurityHoldings] 
		(
			[HKeyPortfolioSecuritySummary],	
			[Meta_LoadDateTime]		,
			[Meta_LoadEndDateTime]	,
			[Meta_RecordSource]		,
			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
					
			[Holding],
			[Vintage],
			[SumMoneyInLC],
			[SumMoneyOutLC],
			[SumInvestmentCapitalLC],
			[SumMoneyInBC],
			[SumMoneyOutBC],
			[SumInvestmentCapitalBC]
		)

		SELECT		LP.HKeyPortfolioSecuritySummary								AS [HKeyPortfolioSecurityHolding],
					@LoadDateTime												AS Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2 )							AS Meta_LoadEndDateTime, 
					@Meta_RecordSource											AS Meta_RecordSource, 
					@ETLProcessID												AS Meta_ETLProcessID,

					[Holding],
					[Vintage], 
					[SumMoneyInLC],
					[SumMoneyOutLC],
					[SumInvestmentCapitalLC],
					[SumMoneyInBC],
					[SumMoneyOutBC], 
					[SumInvestmentCapitalBC]
										
		FROM		[bv].[LinkPortfolioSecuritySummary] lp
		INNER JOIN 		
		(
				SELECT		lt.HKeyPortfolio,
							lt.HKeySecurity,							
							lt.HKeyPriceCcyISO,
							lt.HKeySettleCcyISO,
							SUM( COALESCE( st.[QuantityChange], 0.0) )	AS [Holding],
							
							-- TBD:		Should be last date where running share count = 0 and Transaction Type = 'B' ?
							MIN( st.TRADDATE )							AS [Vintage],
							
							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'B') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTU		 
											ELSE	0 END
								)										AS SumMoneyInLC,

							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'S', N'FD', N'DV', N'IN', N'FI') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTU		 
											ELSE	0 END
								)										AS SumMoneyOutLC,

							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'B') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTU		 
											ELSE	0 END
								)										
							+
							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'S', N'FD', N'DV', N'IN', N'FI') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTU		 
											ELSE	0 END
								)										AS SumInvestmentCapitalLC,
															   
							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'B') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTC		 
											ELSE	0 END
								)										AS SumMoneyInBC, 

							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'S', N'FD', N'DV', N'IN', N'FI') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTC		 
											ELSE	0 END
								)										AS SumMoneyOutBC,

							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'B') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTC		 
											ELSE	0 END
								)										
							+
							SUM (
									CASE	WHEN	st.TRANTYPE IN (N'S', N'FD', N'DV', N'IN', N'FI') AND st.FOOTNOTE <> N'SE' 
											THEN	st.NETAMTC		 
											ELSE	0 END
								)										AS SumInvestmentCapitalBC
								
				FROM		dv.LinkTransactions lt
				INNER JOIN	dv.SatTransactions	st
				ON			lt.HKeyTransaction	=	st.HKeyTransaction
	

				-- TBD: TEST
				WHERE	@AsOfDateTime	BETWEEN	st.Meta_LoadDateTime AND st.Meta_LoadEndDateTime	-- Get only the Active transaction record at the specific datetime 
				-- @LoadDateTime	BETWEEN	st.Meta_LoadDateTime AND st.Meta_LoadEndDateTime	-- Get only the Active transaction record at the specific datetime 
				AND			st.[STATUS]		=	N'PCR'				
		
				-- If re-running for a past report date only included transactions with a trade date later than the report date 
				AND			st.TRADDATE		<=	@ReportDate
				
				/*
						********************			TBD!!!!!!!				********************			
						Need to maintain Effectivity Satellites on Hubs + Links so we can run 
						queries \ calculations and specify, BOTH: 										
				*/

				GROUP BY	lt.HKeyPortfolio,
							lt.HKeySecurity,
							lt.HKeyPriceCcyISO,
							lt.HKeySettleCcyISO

				HAVING		SUM( COALESCE( st.[QuantityChange], 0.0) )	<> 0.0

		) AS ts
		ON			lp.HKeyPortfolio		=	ts.HKeyPortfolio
		AND			lp.HKeySecurity			=	ts.HKeySecurity
		AND			lp.HKeyPriceCurrency	=	ts.HKeyPriceCcyISO
		AND			lp.HKeySettleCurrency	=	ts.HKeySettleCcyISO
			   
		INNER JOIN	dv.HubPortfolios hp
		ON			ts.HKeyPortfolio		=	hp.HKeyPortfolio

		INNER JOIN	dv.HubSecurities hs
		ON			ts.HKeySecurity			=	hs.HKeySecurity 
		
		-- Populate satellite for last set of link table records inserted
		WHERE		lp.Meta_LoadDatetime		=	@LoadDateTime 
		-- WHERE		lp.Meta_LoadDateTime	<=	@AsOfDateTime		
		; 
		

	-- Satellite Financial Summary
	INSERT INTO [bv].[SatPortfolioSecurityValuations] 
		(
			[HKeyPortfolioSecuritySummary],	
			[Meta_LoadDateTime]		,
			[Meta_LoadEndDateTime]	,
			[Meta_RecordSource]		,
			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
								
			[ValuationLC],
			[ValuationBC]
		)
		
	SELECT				
				sh.HKeyPortfolioSecuritySummary								AS [HKeyPortfolioSecuritySummary],
				sh.Meta_LoadDateTime										AS Meta_LoadDateTime, 
				CAST( N'9999-12-31' AS DATETIME2 )							AS Meta_LoadEndDateTime, 
				@Meta_RecordSource											AS Meta_RecordSource, 
				sh.Meta_ETLProcessID										AS Meta_ETLProcessID,

				(sh.Holding * sp.BidPrice) / ss.Multiplier					AS [ValuationLC],
				(sh.Holding * sp.BidPrice / ss.Multiplier) * sf.RateToGBP	AS [ValuationBC]

	FROM		[bv].[LinkPortfolioSecuritySummary]		lh

	INNER JOIN 	[bv].[SatPortfolioSecurityHoldings]		sh
	ON			lh.HKeyPortfolioSecuritySummary		=	sh.HKeyPortfolioSecuritySummary
		
	INNER JOIN	dv.SatSecurities						ss
	ON			lh.HKeySecurity						=	ss.HKeySecurity
	
	INNER JOIN	dv.SatPrices							sp
	ON			lh.HKeyPriceCurrencyPrice			=	sp.HKeyPrice
	
	--	Local Currency FX rate to GBP 
	INNER JOIN	dv.SatFXRates							sf
	ON			lh.HKeyPriceCurrencyFXRateToGBP		=	sf.HKeyFXRate
	

	-- TBD: TEST
	 WHERE		lh.Meta_LoadDateTime				=	@LoadDateTime 	
	-- WHERE		lh.Meta_LoadDateTime				<=	@AsOfDateTime
	-- AND			sh.Meta_LoadDateTime				=	@LoadDateTime 		
	
	-- AND			sh.Meta_LoadDateTime				 BETWEEN	ss.Meta_LoadDateTime AND ss.Meta_LoadEndDateTime
	AND			@AsOfDateTime				BETWEEN	ss.Meta_LoadDateTime AND ss.Meta_LoadEndDateTime
	AND			@AsOfDateTime				BETWEEN	sp.Meta_LoadDateTime AND sp.Meta_LoadEndDateTime
	AND			@AsOfDateTime				BETWEEN	sf.Meta_LoadDateTime AND sf.Meta_LoadEndDateTime
	;

GO



