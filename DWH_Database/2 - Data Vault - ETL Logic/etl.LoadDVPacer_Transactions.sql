CREATE PROC [etl].[PACER_LoadDVTransactions] (
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS

--	Load Business Key Hubs if missing 

	-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.


	-- PRICE CURRENCY 
	UPDATE		[dv].[HubCurrencies] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubCurrencies] h

	INNER JOIN	stg.PACER_Transactions t
	ON			h.HKeyCurrency			=	t.[Out_HKeyPriceCcyISO]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubCurrencies]
			(
				[HKeyCurrency]				,			-- Hash of Price Currency Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[CurrencyCode]							--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeyPriceCcyISO]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_HKeyPriceCcyISO]

	FROM		stg.PACER_Transactions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubCurrencies] h
			WHERE	h.HKeyCurrency		=	t.[Out_HKeyPriceCcyISO]
		) ;
		


	-- SETTLEMENT CURRENCY 
	UPDATE		[dv].[HubCurrencies] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubCurrencies] h

	INNER JOIN	stg.PACER_Transactions t
	ON			h.HKeyCurrency			=	t.[Out_HKeySettleCcyISO]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubCurrencies]
			(
				[HKeyCurrency]				,			-- Hash of Settlement Currency Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[CurrencyCode]							--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeySettleCcyISO]	,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_HKeySettleCcyISO]

	FROM		stg.PACER_Transactions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubCurrencies] h
			WHERE	h.HKeyCurrency		=	t.[Out_HKeySettleCcyISO]
		) ;
		


	-- PORTFOLIO
	UPDATE		[dv].[HubPortfolios] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubPortfolios] h

	INNER JOIN	stg.PACER_Transactions t
	ON			h.HKeyPortfolio			=	t.[Out_HKeyPORTCODE]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubPortfolios]
			(
				[HKeyPortfolio]				,			-- Hash of Portfolio Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[PortfCode]								--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeyPORTCODE]	,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_PORTCODE]

	FROM		stg.PACER_Transactions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubPortfolios] h
			WHERE	h.HKeyPortfolio		=	t.[Out_HKeyPORTCODE]
		) ;
		


	-- SECURITY
	UPDATE		[dv].[HubSecurities] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubSecurities] h

	INNER JOIN	stg.PACER_Transactions t
	ON			h.HKeySecurity			=	t.[Out_HKeySECID]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubSecurities]
			(
				[HKeySecurity]				,			-- Hash of Portfolio Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[SecID]									--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeySECID]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_SECID]

	FROM		stg.PACER_Transactions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubSecurities] h
			WHERE	h.HKeySecurity		=	t.[Out_HKeySECID]
		) ;



	-- BROKER
	UPDATE		[dv].[HubBrokers] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubBrokers] h

	INNER JOIN	stg.PACER_Transactions t
	ON			h.HKeyBroker			=	t.[Out_HKeyBROKCODE]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubBrokers]
			(
				[HKeyBroker]				,			-- Hash of Broker Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[BrokerCode]							--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeyBROKCODE]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_BROKCODE]

	FROM		stg.PACER_Transactions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubBrokers] h
			WHERE	h.HKeyBroker		=	t.[Out_HKeyBROKCODE]
		) ;





--	Load Link 

	-- Check if Link already exists using Business Key hashes 	
	UPDATE		[dv].[LinkTransactions] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[LinkTransactions] h

	INNER JOIN	stg.PACER_Transactions t

	ON			h.[HKeyPortfolio]		=	t.[Out_HKeyPORTCODE]
	AND			h.[HKeySecurity]		=	t.[Out_HKeySECID]
	AND			h.[HKeyBroker]			=	t.[Out_HKeyBROKCODE]
	AND			h.[HKeyPriceCcyISO]		=	t.[Out_HKeyPriceCcyISO]
	AND			h.[HKeySettleCcyISO]	=	t.[Out_HKeySettleCcyISO]
	AND			h.[TRANNUM]				=	t.[Out_TRANNUM]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[LinkTransactions]
			(
				[HKeyTransaction], 
				Meta_LoadDateTime, 
				Meta_RecordSource, 				
				Meta_ETLProcessID,
				Meta_LastSeenDateTime,
				[HKeyPortfolio],		
				[HKeySecurity],	
				[HKeyBroker],	
				[HKeyPriceCcyISO],	
				[HKeySettleCcyISO],	
				[TRANNUM]								--	UIX					
			)
	SELECT DISTINCT
				t.[Out_HKeyLinkTransactions], 
				t.Meta_LoadDateTime, 
				t.Meta_RecordSource, 
				t.Meta_ETLProcessID,
				t.Meta_LoadDateTime,		
				t.[Out_HKeyPORTCODE],
				t.[Out_HKeySECID],
				t.[Out_HKeyBROKCODE],
				t.[Out_HKeyPriceCcyISO],
				t.[Out_HKeySettleCcyISO],
				t.[Out_TRANNUM]

	FROM		stg.PACER_Transactions t
	WHERE		t.Meta_LoadDateTime			=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[LinkTransactions] h
			-- WHERE	h.[HKeyTransaction]		=	t.[Out_HKeyLinkTransactions]
			WHERE 	h.[HKeyPortfolio]		=	t.[Out_HKeyPORTCODE]
			AND		h.[HKeySecurity]		=	t.[Out_HKeySECID]
			AND		h.[HKeyBroker]			=	t.[Out_HKeyBROKCODE]
			AND		h.[HKeyPriceCcyISO]		=	t.[Out_HKeyPriceCcyISO]
			AND		h.[HKeySettleCcyISO]	=	t.[Out_HKeySettleCcyISO]
			AND		h.[TRANNUM]				=	t.[Out_TRANNUM]
		) ;



--	Load Satellite

	-- Insert new pay loads  
	INSERT INTO [dv].[SatTransactions] 
		(
			HKeyTransaction, 
			Meta_LoadDateTime, 
			Meta_LoadEndDateTime,
			SeqEntryDateTime,
			Meta_RecordSource, 
			Meta_ETLProcessID,
			HDiffTransactionPL,
			
			[TRANNUM_Original]				,
			[PORTCODE]						,
			[SECID]							,
			[TRANTYPE]						,
			[FOOTNOTE]						,
			[CLASS]							,
			[TRADDATE]						,
			[SETTDATE]						,
			[BROKCODE]						,	
			[SHAREPAR]						,
	
			[PriceCcyISO]					,				-- Move to BV?
			[SettleCcyISO]					,				-- Move to BV?

			[FXRATE]						,
			[FXRATEPS]						,
			[FXRATESB]						,
			[PRICEU]						,
			[PRICCURR]						,
			[SETTCURR]						,
	
			[GROSAMTU]						,
			[COMMISSU]						,
			[MISCTOTU]						,
			[NETAMTU]						,
			[COSTOTLU]						,
			[GAINU]							,
			[GROSAMTC]						,
			[COMMISSC]						,
			[MISCTOTC]						,
			[NETAMTC]						,
			[COSTOTLC]						,
			[GAINC]							,

			[QuantityChange]				,		-- Move to BV?
			[CostChangeLC]					,		-- Move to BV?
			[CostChangeBC]					,		-- Move to BV?
	
			[DEBITU]						,
			[CREDITU]						,
			[DEBITS]						,
			[CREDITS]						,
			[DEBITC]						,
			[CREDITC]						,
			
			[NetCashLC]						,		-- Move to BV?
			[NetCashSC]						,		-- Move to BV?
			[NetCashBC]						,		-- Move to BV?

			[TRADTYPE]						,
			[ANNOT]							,
			[EXCUM]							,
			[EXREFNUM]						,
	
			[MISC1U]						,
			[MISC2U]						,
			[MISC3U]						,
			[MISC4U]						,
			[MISC5U]						,
			[MISC6U]						,

			[MISC1C]						,
			[MISC2C]						,
			[MISC3C]						,
			[MISC4C]						,
			[MISC5C]						,
			[MISC6C]						,
			[MISCCODS]						,

			[STATUS]						,
			[ENTRDATE]						,
			[ENTRTIME]						,
			[ENTRDATETIME]					,
			[EFFEDATE]						,
			[MODIDATE]						,
			[MODITIME]						,
			[MODIDATETIME]									
		)

	SELECT DISTINCT
			t.[Out_HKeyLinkTransactions],			--	PK
			t.Meta_LoadDateTime,					--	PK
			CAST(N'9999-12-31' AS DATETIME2),		
			t.[Out_SeqEntryDateTime],				--	PK
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,				
			t.[Out_HDiffTransactionPL],

			t.[Out_TRANNUM_Original]			,
			t.[Out_PORTCODE]					,
			t.[Out_SECID]						,
			t.[Out_TRANTYPE]					,
			t.[Out_FOOTNOTE]					,
			t.[Out_CLASS]						,
			t.[Out_TRADDATE]					,
			t.[Out_SETTDATE]					,
			t.[Out_BROKCODE]					,	
			t.[Out_SHAREPAR]					,
	
			t.[Out_PriceCcyISO]					,
			t.[Out_SettleCcyISO]				,

			t.[Out_FXRATE]						,
			t.[Out_FXRATEPS]					,
			t.[Out_FXRATESB]					,
			t.[Out_PRICEU]						,

			t.[Out_PRICCURR]					,
			t.[Out_SETTCURR]					,
	
			t.[Out_GROSAMTU]					,
			t.[Out_COMMISSU]					,
			t.[Out_MISCTOTU]					,
			t.[Out_NETAMTU]						,
			t.[Out_COSTOTLU]					,
			t.[Out_GAINU]						,
			t.[Out_GROSAMTC]					,
			t.[Out_COMMISSC]					,
			t.[Out_MISCTOTC]					,
			t.[Out_NETAMTC]						,
			t.[Out_COSTOTLC]					,
			t.[Out_GAINC]						,

			t.[Out_QuantityChange]				,
			t.[Out_CostChangeLC]				,
			t.[Out_CostChangeBC]				,
	
			t.[Out_DEBITU]						,
			t.[Out_CREDITU]						,
			t.[Out_DEBITS]						,
			t.[Out_CREDITS]						,
			t.[Out_DEBITC]						,
			t.[Out_CREDITC]						,
	
			t.[Out_NetCashLC]					,
			t.[Out_NetCashSC]					,
			t.[Out_NetCashBC]					,

			t.[Out_TRADTYPE]					,
			t.[Out_ANNOT]						,
			t.[Out_EXCUM]						,
			t.[Out_EXREFNUM]					,
	
			t.[Out_MISC1U]						,
			t.[Out_MISC2U]						,
			t.[Out_MISC3U]						,
			t.[Out_MISC4U]						,
			t.[Out_MISC5U]						,
			t.[Out_MISC6U]						,

			t.[Out_MISC1C]						,
			t.[Out_MISC2C]						,
			t.[Out_MISC3C]						,
			t.[Out_MISC4C]						,
			t.[Out_MISC5C]						,
			t.[Out_MISC6C]						,

			t.[Out_MISCCODS]					,
			t.[Out_STATUS]						,
			t.[Out_ENTRDATE]					,
			t.[Out_ENTRTIME]					,
			t.[Out_ENTRDATETIME]				,
			t.[Out_EFFEDATE]					,
			t.[Out_MODIDATE]					,
			t.[Out_MODITIME]					,
			t.[Out_MODIDATETIME]					

	FROM	stg.PACER_Transactions  t
	
	WHERE	t.Meta_LoadDateTime				=	@LoadDateTime 

	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatTransactions] s
			WHERE	s.HKeyTransaction		=	t.Out_HKeyLinkTransactions
			AND		s.HDiffTransactionPL	=	t.Out_HDiffTransactionPL
		) ;



-- End Dating of Previous Satellite Entries 
-- Set last Load datetime for existing records to inactive using past point in time before next load datetime

	UPDATE	[dv].[SatTransactions]
		SET		Meta_LoadEndDateTime		 =	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatTransactions] z
													WHERE	z.HKeyTransaction		=	s.HKeyTransaction
													AND		z.Meta_LoadDateTime		>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatTransactions] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT	* 
					FROM	stg.PACER_Transactions t					
					WHERE	t.Meta_LoadDateTime			=	@LoadDateTime
					AND		t.Out_HKeyLinkTransactions	=	s.HKeyTransaction
					-- AND		s.SeqEntryDateTime			=	t.[Out_SeqEntryDateTime]
				)	;

GO

