-- Source:			Production Copy of Integration DB
-- Destination:		Temp PACER_FXRates table 

	DECLARE		@LoadDateTime	AS DATETIME2;

	--		SELECT	COUNT(*)	FROM	inv.FxRates;
	--		SELECT	*			FROM	inv.FxRates;

	--		SELECT	*			FROM	DWH.tmp.PACER_Transactions;
	--		SELECT	*			FROM	DWH.tmp.PACER_FXRates;
	--		SELECT	*			FROM	DWH.stg.PACER_FXRates;
	
		-- Not in inv.Currencies ( only used up to 991231)
				--	CurrencyCode
				--		SDD
				--		XAF
				
						--SELECT MAX(RateDate) -- DISTINCT t.CurrencyCode 
						--FROM 
						--(
						--		SELECT	
						--		c1.SSCCode AS CcyCode
						--		, F.CurrencyCode
						--		,[RateToGBP]
						--		-- ,[RateDate]
						--		, SUBSTRING ( CONVERT( VARCHAR, [RateDate], 112 ) , 3, 6) 	AS [RateDate]	
						--		-- ,-1 
						--		-- ,@LoadDateTime	
						--		FROM		[CAL_JBETL_PROD_COPY].inv.FXRates f
						--		LEFT JOIN	[CAL_JBETL_PROD_COPY].inv.Currencies c1 on f.CurrencyCode	=	c1.CurrencyCode
						--		WHERE	c1.SSCCode IS NULL
						--)  t;
									
	--	Set LoadDatetime to date \ time of last transaction trade date?
	SET		@LoadDateTime	=	'2019-10-01 00:00:30.000'			--	NOTE!!! MUST INCLUDE A TIME PART i.e. not all 0's
	
		--		exec etl.PACER_LoadStgPrices @LoadDateTime

	PRINT @LoadDateTime;

	TRUNCATE TABLE DWH.tmp.PACER_FXRates;

	INSERT INTO		DWH.tmp.PACER_FXRates
	(
		[CcyCode]
		,[RateToGBP]
		,[RateDate]
		,[Meta_ETLProcessID]
		,[Meta_LoadDateTime]
	)

	SELECT	
		c1.SSCCode AS CcyCode
		,[RateToGBP]	
		, SUBSTRING ( CONVERT( VARCHAR, [RateDate], 112 ) , 3, 6) 	AS [RateDate]	
		,-1
		,@LoadDateTime	
	FROM		[CAL_JBETL_PROD_COPY].inv.FXRates f
	LEFT JOIN	[CAL_JBETL_PROD_COPY].inv.Currencies c1 on f.CurrencyCode	=	c1.CurrencyCode
	WHERE		f.CurrencyCode NOT IN ( 'SDD', 'XAF' )		
				-- No equivalent to translate these codes in inv.Currencies but haven't existed since 1999-12-31
	;


	/*
	SELECT	* 
	FROM	DWH.tmp.PACER_FXRates;

	SELECT	* 
	FROM	DWH.stg.PACER_FXRates;

	SELECT * 
	FROM	DWH.dv.LinkFXRates		lfx

	INNER JOIN DWH.dv.SatFXRates	sfx
	ON		lfx.HKeyFXRate	=	sfx.HKeyFXRate
	;
	*/




