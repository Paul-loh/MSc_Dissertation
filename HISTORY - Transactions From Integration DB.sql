-- Source:			Production Copy of Integration DB
-- Destination:		Temp transactions table 

--			select * from DWH.tmp.PACER_Transactions;

	DECLARE		@LoadDateTime	AS DATETIME2;

	--	Set LoadDatetime to date \ time of last transaction trade date?

		/*	
			SELECT	MAX( EntryDate ) AS Last_EntryDate, 
					MAX( ISNULL( ModifiedDate, '1900-01-01' )) AS Last_ModifiedDate
			FROM	[CAL_JBETL_PROD_COPY].inv.Transactions 		
		*/


	SET		@LoadDateTime	=	'2019-10-01 00:00:30.000'			--	NOTE!!! MUST INCLUDE A TIME PART i.e. not all 0's

	PRINT @LoadDateTime;

	TRUNCATE TABLE DWH.tmp.PACER_Transactions;

	INSERT INTO		DWH.tmp.PACER_Transactions
		(
		  [PORTCODE]
		  ,[SECID]
		  ,[TRANTYPE]
		  ,[FOOTNOTE]
		  ,[CLASS]
		  ,[STATUS]
		  ,[TRADDATE]
		  ,[SHAREPAR]
		  ,[PRICEU]
		  ,[PRICCURR]
		  ,[NETAMTC]
		  ,[GAINC]
		  ,[ACCRINTC]
		  ,[ACCRINTU]
		  ,[TAXLOT]
		  ,[ORPARVAL]
		  ,[SETTDATE]
		  ,[ACTUSETT]
		  ,[SETTCURR]
		  ,[ENTRDATE]
		  ,[MISC1U]
		  ,[MISC2U]
		  ,[MISC3U]
		  ,[MISC4U]
		  ,[MISC5U]
		  ,[MISC6U]
		  ,[MISCTOTU]
		  ,[COMMISSU]
		  ,[COMMISSC]
		  ,[BROKCODE]
		  ,[ACQUDATE]

		  ,[CREDITS]

		  ,[SUBPORTF]
		  ,[IMPCOMMC]
		  ,[COSTOTLC]
		  ,[CPTYCODE]
		  ,[ANNOT]
		  ,[GAINFXC]
		  ,[TRADTYPE]
		  ,[BROKFINS]
		  ,[BROKNAME]
		  ,[COSTOTLU]
		  ,[CPTYNAME]

		  ,[CREDITC]
		  ,[CREDITU]
		  ,[DEBITC]
		  ,[DEBITS]
		  ,[DEBITU]

		  ,[DURATION]
		  ,[EFFEDATE]
		  ,[ENTRNAME]
		  ,[ENTROPER]
		  ,[ENTRTIME]
		  ,[FORNCASH]
		  ,[FXRATE]
		  ,[FXRATEPS]
		  ,[FXRATESB]
		  ,[GAINFXU]
		  ,[GROSAMTC]
		  ,[GROSAMTU]
		  ,[IMPCOMMU]
		  ,[LOCANAME]
		  ,[LOCATION]
		  ,[MISC1C]
		  ,[MISC2C]
		  ,[MISC3C]
		  ,[MISC4C]
		  ,[MISC5C]
		  ,[MISC6C]
		  ,[MISCTOTC]
		  ,[MODIDATE]
		  ,[MODIOPER]
		  ,[MODITIME]
		  ,[ORDRNUM]
		  ,[PRICEC]
		  ,[STRATGCD]
		  ,[STRATGIS]
		  ,[STRATGMS]
		  ,[STRATGNM]
		  ,[STRATGTY]
		  ,[TRADNUM]
		  ,[YLDCOST]
		  ,[YLDTRAN]
		  ,[NETAMTU]
		  ,[GAINU]
		  ,[EXCUM]
		  ,[EXREFNUM]
		  ,[MISCCODS]
		  ,[TRANNUM]
		  ,Meta_ETLProcessID
		  ,Meta_LoadDateTime
		)

		--	Integration DB table columns reversed to Pacer Transactions file order 
			-- The NULL values are columns dropped from the the original import ;-(((
				

	SELECT	
		[PortfolioCode] ,
		[SecurityCode],
		[TransType],
		[FOOTNOTE],
		'' AS [CLASS],
		[STATUS],
		SUBSTRING ( CONVERT( VARCHAR, TRADEDATE , 112 ) , 3, 6)  AS [TRADDATE],		
		QUANTITY AS [SHAREPAR],
		PriceLC,
		c1.SSCCode AS [PRICCURR], 	
		NetAmountBC AS [NETAMTC],
		GainLossBC AS [GAINC],
		'' AS [ACCRINTC],
		'' AS [ACCRINTU],
		'' AS [TAXLOT],
		'' AS [ORPARVAL],
		SUBSTRING ( CONVERT( VARCHAR, SettleDate , 112 ) , 3, 6) AS [SETTDATE],
		'' AS [ACTUSETT],
		c2.SSCCode AS [SETTCURR],
		SUBSTRING ( CONVERT( VARCHAR, EntryDate , 112 ) , 3, 6) AS  [ENTRDATE],
		MiscChg1LC AS [MISC1U],
		MiscChg2LC AS [MISC2U],
		MiscChg3LC AS [MISC3U],
		MiscChg4LC AS [MISC4U],
		MiscChg5LC AS [MISC5U],
		MiscChg6LC AS [MISC6U],
		MiscChgsLC AS [MISCTOTU],
		CommissionLC AS [COMMISSU],
		CommissionBC AS [COMMISSC],
		BrokerCode AS [BROKCODE],
		'' AS [ACQUDATE],
		NULL	AS [CREDITS],		-- NEED THIS 
		'' AS [SUBPORTF],
		'' AS [IMPCOMMC],
		BkCostSoldBC AS [COSTOTLC],
		'' AS [CPTYCODE],
		Annotation AS [ANNOT],
		'' AS [GAINFXC],
		TradeType AS [TRADTYPE],
		'' AS [BROKFINS],
		'' AS [BROKNAME],

		BkCostSoldLC AS [COSTOTLU],
		'' AS [CPTYNAME],

		NULL AS [CREDITC],		-- NEED THIS
		NULL AS [CREDITU],		-- NEED THIS	
		NULL AS [DEBITC],		-- NEED THIS
		NULL AS [DEBITS],		-- NEED THIS
		NULL AS [DEBITU],		-- NEED THIS

		'' AS [DURATION],

		SUBSTRING ( CONVERT( VARCHAR, EffectiveDate , 112 ) , 3, 6)  AS [EFFEDATE],	
		'' AS [ENTRNAME],
		'' AS [ENTROPER],
		SUBSTRING( CAST(TransSeq AS VARCHAR), 9, 2) + ':' + 
		SUBSTRING( CAST(TransSeq AS VARCHAR), 11, 2) + ':' + 
		SUBSTRING( CAST(TransSeq AS VARCHAR), 13, 2) AS [ENTRTIME],
	
		'' AS [FORNCASH],
		FxRateLtoB AS [FXRATE],
		FxRateLtoS AS [FXRATEPS],
		FxRateStoB AS [FXRATESB],
		'' AS [GAINFXU],
		GrossAmtBC AS [GROSAMTC],
		GrossAmtLC AS [GROSAMTU],
		'' AS [IMPCOMMU],
		'' AS [LOCANAME],
		'' AS [LOCATION],

		MiscChg1BC AS [MISC1C],
		MiscChg2BC AS [MISC2C],
		MiscChg3BC AS [MISC3C],
		MiscChg4BC AS [MISC4C],
		MiscChg5BC AS [MISC5C],
		MiscChg6BC AS [MISC6C],
		MiscChgsBC AS [MISCTOTC],

		CASE	WHEN ModifiedDate IS NULL	
				THEN ''
				ELSE
					SUBSTRING ( CONVERT( VARCHAR, ModifiedDate, 112 ) , 3, 6)  
				END	AS [MODIDATE],		

		'' AS [MODIOPER],

		CASE	WHEN ModifiedDate IS NULL	
				THEN ''
				ELSE
					SUBSTRING ( CONVERT( VARCHAR, ModifiedDate , 120 ) , 12, 8)		
				END AS [MODITIME],
			
		--SUBSTRING( CAST(ModifiedDate AS VARCHAR), 9, 2) + ':' + 
		--SUBSTRING( CAST(TransSeq AS VARCHAR), 11, 2) + ':' + 
		--SUBSTRING( CAST(TransSeq AS VARCHAR), 13, 2) AS [MODITIME],

		'0' AS [ORDRNUM],	
		'0.0' AS [PRICEC],
		'' AS [STRATGCD],
		'' AS [STRATGIS],
		'' AS [STRATGMS],
		'' AS [STRATGNM],

		'' AS [STRATGTY],
		'' AS [TRADNUM],
		'' AS [YLDCOST],
		'' AS [YLDTRAN],

		NetAmountLC AS [NETAMTU],
		GainLossLC AS [GAINU],
		SpecPriceInd AS [EXCUM],
		ExtRefNum AS [EXREFNUM],
		MiscChgCodes AS [MISCCODS],
		TransNum AS [TRANNUM],
		-1,
		@LoadDateTime	
	
	FROM	[CAL_JBETL_PROD_COPY].inv.Transactions t
	left join [CAL_JBETL_PROD_COPY].inv.Currencies c1 on t.PriceCcy		 = c1.CurrencyCode
	left join [CAL_JBETL_PROD_COPY].inv.Currencies c2 on t.SettleCcy	 = c2.CurrencyCode
	;


	/*
	EXEC [etl].[PACER_LoadStgTransactions]	@LoadDateTime;
	EXEC [etl].[PACER_LoadDVTransactions] @LoadDateTime;
	*/

	/* 

		truncate table DWH.tmp.PACER_Transactions

		SELECT * FROM DWH.tmp.PACER_Transactions

		SELECT * FROM DWH.stg.PACER_Transactions;

		SELECT * FROM DWH.dv.LinkTransactions; 

		SELECT * FROM DWH.dv.SatTransactions; 



		SELECT  
		ModifiedDate,
		CONVERT( VARCHAR, ModifiedDate , 112 ) as Mod2,
		CONVERT( VARCHAR, ModifiedDate , 120 ) as Mod3,
		CASE	WHEN ModifiedDate IS NULL	
				THEN ''
				ELSE
					SUBSTRING ( CONVERT( VARCHAR, ModifiedDate, 112 ) , 3, 6)  
				END	AS [MODIDATE],		

		CASE	WHEN ModifiedDate IS NULL	
				THEN ''
				ELSE
					SUBSTRING ( CONVERT( VARCHAR, ModifiedDate , 120 ) , 12, 8)		
				END AS [MODITIME]
			
		FROM 	[CAL_JBETL_PROD_COPY].inv.Transactions
		WHERE	TransNum	=	169570;

	*/


	--DECLARE  @LoadDateTime AS DATETIME2 = '2019-09-23 11:05:54.9361339';
	--PRINT @LoadDateTime
	--EXEC [etl].[PACER_LoadStgTransactions] @LoadDateTime;


	--EXEC [etl].[PACER_LoadStgTransactions] CAST( @LoadDateTime	AS NVARCHAR() );



