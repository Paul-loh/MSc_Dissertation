CREATE PROCEDURE [etl].[PACER_LoadBVSecuritySummary] (
														@ReportDate		DATE,
														@LoadDateTime	DATETIME2,
														@AsOfDateTime	DATETIME2,
														@ETLProcessID	INT			=	-1
													)
WITH EXECUTE AS OWNER 
AS

-- Not used

/* 
	Author:					Paul Loh
	Business Rule Ref:		TBD: ?????
	Description:			Materialise aggregate financial information from business vault table [bv].[LinkPortfolioSecuritySummary]
							at a higher grain.
	
	Grain:					Security \ Price Currency \ Settlement Currency \ Price \ FXRateToGBP 	
*/

--	DECLARE		@Meta_RecordSource	AS NVARCHAR(100) =	N'BR001b|v.Alpha|Financial summary grain: Security-Price Currency' ;
	

----	Load Link
	
--	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
--	-- (2 values generating same Hash), which we would want to know about. 
--	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

--	INSERT INTO		[bv].[LinkSecuritySummary]
--		(
--			[HKeySecuritySummary]		,			-- Hash of Security Code, Price Currency, Settlement Currency, Price, Price Source, FX Rate, Report Date, AsOf DateTime and Load Datetime
--			[Meta_LoadDateTime]			,
--			[Meta_LastSeenDateTime]		,				-- Last time calculation attempted 
--			[Meta_RecordSource]			,
--			[Meta_ETLProcessID]			,				-- FK to ID of import batch audit table	?

--			[HKeySecurity]				,				--	UIX		-- Driving Key
--			[HKeyPriceCurrency]			,				--	UIX		-- Driving Key
--			-- [HKeySettleCurrency]		,				--	UIX		-- Driving Key		
--			[HKeyPriceCurrencyPrice]		,			--	UIX		 
--			[HKeyPriceCurrencyFXRateToGBP]	,			--	UIX		

--			[ReportDate]				,				--	UIX		-- Driving Key			
--			[AsOfDateTime]				,				--	UIX		-- Snapshot time (different from Load DateTime if doing a re-load)

--			-- Add Natural Business Keys to Link 			
--			[SecID]						,				-- BK
--			[PriceCurrencyCode]			,				-- BK
--			-- [SettleCurrencyCode]		,				-- BK
--			[PriceCurrencyBidPrice]		,
--			[PriceCurrencyFXRateToGBP]	
--		)
			   
--		SELECT DISTINCT 
--					HASHBYTES	( N'SHA1',
--									UPPER(	
--										CONCAT_WS( N'|',
--														lps.SecID,						-- Security ID
--														lps.PriceCurrencyCode,			--	Price currency
--														-- lps.SettleCurrencyCode,			--	Settlement currency
--														CONVERT( NVARCHAR(30), @LoadDateTime, 126),	-- Standardise throughout Datetime format used in Hashing
--														CONVERT( NVARCHAR(30), @ReportDate, 126),	
--														CONVERT( NVARCHAR(30), @AsOfDateTime, 126)	
--												)
--										)
--								)				AS [HKeySecuritySummary],
--					[Meta_LoadDateTime],
--					[Meta_LastSeenDateTime],
--					@Meta_RecordSource,
--					[Meta_ETLProcessID],
--					[HKeySecurity],
--					[HKeyPriceCurrency],
--					-- [HKeySettleCurrency],
--					[HKeyPriceCurrencyPrice],
--					[HKeyPriceCurrencyFXRateToGBP],
--					[ReportDate],
--					[AsOfDateTime],
--					[SecID]						,				-- BK
--					[PriceCurrencyCode]			,				-- BK
--					-- [SettleCurrencyCode]		,				-- BK
--					[PriceCurrencyBidPrice]		,
--					[PriceCurrencyFXRateToGBP]	

--		FROM		[bv].[LinkPortfolioSecuritySummary] lps

--		WHERE		lps.Meta_LoadDateTime	=	@LoadDateTime
--		AND			lps.ReportDate			=	@ReportDate
--		;
		

----	Load Satellites
--	-- Insert new payloads

--	-- Satellite Security Holdings
--	INSERT INTO [bv].[SatSecurityHoldings] 
--		(
--			[HKeySecuritySummary],	
--			[Meta_LoadDateTime]		,
--			[Meta_LoadEndDateTime]	,
--			[Meta_RecordSource]		,
--			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
					
--			[Holding],
--			[Vintage],
--			[SumMoneyInLC],
--			[SumMoneyOutLC],
--			[SumInvestmentCapitalLC],
--			[SumMoneyInBC],
--			[SumMoneyOutBC],
--			[SumInvestmentCapitalBC]
--		)

--		SELECT		lss.HKeySecuritySummary										AS [HKeySecurityHolding],
--					lss.Meta_LoadDateTime										AS Meta_LoadDateTime, 
--					CAST( N'9999-12-31' AS DATETIME2 )							AS Meta_LoadEndDateTime, 
--					@Meta_RecordSource											AS Meta_RecordSource, 
--					lss.Meta_ETLProcessID										AS Meta_ETLProcessID,
--					SUM( COALESCE( sph.Holding, 0.0) )							AS [Holding], 
--					MIN( sph.[Vintage] )										AS [Vintage], 
--					SUM( COALESCE( [SumMoneyInLC], 0.0) )						AS [SumMoneyInLC],
--					SUM( COALESCE( [SumMoneyOutLC], 0.0) )						AS [SumMoneyOutLC],
--					SUM( COALESCE( [SumInvestmentCapitalLC], 0.0) )				AS [SumInvestmentCapitalLC],
--					SUM( COALESCE( [SumMoneyInBC], 0.0) )						AS [SumMoneyInBC],
--					SUM( COALESCE( [SumMoneyOutBC], 0.0) )						AS [SumMoneyOutBC],
--					SUM( COALESCE( [SumInvestmentCapitalBC], 0.0) )				AS [SumInvestmentCapitalBC]
										
--		FROM		[bv].[LinkSecuritySummary]			lss

--		INNER JOIN	bv.LinkPortfolioSecuritySummary		lps
--		ON			lss.Meta_LoadDateTime					=			lps.Meta_LoadDateTime
--		AND			lss.[ReportDate]						=			lps.[ReportDate]		
--		AND			lss.[AsOfDateTime]						=			lps.[AsOfDateTime]
--		AND			lss.[HKeySecurity]						=			lps.[HKeySecurity]
--		AND			lss.[HKeyPriceCurrency]					=			lps.[HKeyPriceCurrency]
--		-- AND			lss.[HKeySettleCurrency]				=			lps.[HKeySettleCurrency]
--		AND			lss.[HKeyPriceCurrencyPrice]			=			lps.[HKeyPriceCurrencyPrice]
--		AND			lss.[HKeyPriceCurrencyFXRateToGBP]		=			lps.[HKeyPriceCurrencyFXRateToGBP]
		
--		INNER JOIN	bv.SatPortfolioSecurityHoldings		sph
--		ON			lps.HKeyPortfolioSecuritySummary		=			sph.HKeyPortfolioSecuritySummary

--		WHERE		lss.Meta_LoadDateTime					=			@LoadDateTime

--		GROUP BY 
--					lss.HKeySecuritySummary				,
--					lss.Meta_LoadDateTime				, 
--					lss.Meta_ETLProcessID						
--		;


--	-- Satellite Financial Summary
--	INSERT INTO [bv].[SatSecurityValuations] 
--		(
--			[HKeySecuritySummary],	
--			[Meta_LoadDateTime]		,
--			[Meta_LoadEndDateTime]	,
--			[Meta_RecordSource]		,
--			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
								
--			[ValuationLC],
--			[ValuationBC]
--		)
	
--		SELECT		lss.HKeySecuritySummary										AS [HKeySecurityHolding],
--					lss.Meta_LoadDateTime										AS Meta_LoadDateTime, 
--					CAST( N'9999-12-31' AS DATETIME2 )							AS Meta_LoadEndDateTime, 
--					@Meta_RecordSource											AS Meta_RecordSource, 
--					lss.Meta_ETLProcessID										AS Meta_ETLProcessID,
--					SUM( COALESCE( spv.[ValuationLC], 0.0) )					AS [ValuationLC], 
--					SUM( COALESCE( spv.[ValuationBC], 0.0) )					AS [ValuationBC]
										
--		FROM		[bv].[LinkSecuritySummary]			lss
		
--		INNER JOIN	bv.LinkPortfolioSecuritySummary		lps
--		ON			lss.Meta_LoadDateTime					=			lps.Meta_LoadDateTime
--		AND			lss.[ReportDate]						=			lps.[ReportDate]		
--		AND			lss.[AsOfDateTime]						=			lps.[AsOfDateTime]
--		AND			lss.[HKeySecurity]						=			lps.[HKeySecurity]
--		AND			lss.[HKeyPriceCurrency]					=			lps.[HKeyPriceCurrency]
--		-- AND			lss.[HKeySettleCurrency]				=			lps.[HKeySettleCurrency]
--		AND			lss.[HKeyPriceCurrencyPrice]			=			lps.[HKeyPriceCurrencyPrice]
--		AND			lss.[HKeyPriceCurrencyFXRateToGBP]		=			lps.[HKeyPriceCurrencyFXRateToGBP]
		
--		INNER JOIN	bv.SatPortfolioSecurityValuations	spv
--		ON			lps.HKeyPortfolioSecuritySummary		=			spv.HKeyPortfolioSecuritySummary

--		WHERE		lss.Meta_LoadDateTime					=			@LoadDateTime

--		GROUP BY 
--					lss.HKeySecuritySummary				,
--					lss.Meta_LoadDateTime				, 					
--					lss.Meta_ETLProcessID								
--		;
	   
GO



