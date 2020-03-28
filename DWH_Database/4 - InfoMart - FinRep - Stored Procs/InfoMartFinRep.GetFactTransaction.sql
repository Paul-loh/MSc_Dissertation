CREATE PROCEDURE [InfoMartFinRep].[GetFactTransaction]
														@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Get Transactions Fact Table in Finrep (Financial Reporting) Information Mart.
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter is between 
--													Meta_LoadDateTime + Meta_LoadEndDateTime													
--
--						Grain: 
--								Transaction Number
--		
--	Change History:		Date		Changed By			Notes	
--						20200226	Paul Loh			Added Broker dimension ID


	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END 

	SELECT		
					lt.TRANNUM							
					, CAST( 
							HASHBYTES	(	N'SHA1',
									CONCAT_WS	(	
													N'|',
													hp.PortfCode,														
													CASE WHEN sp.Meta_LoadDateTime IS NULL 
													THEN 
														N''
													ELSE
														CONVERT( NVARCHAR(30), sp.Meta_LoadDateTime, 126 )
													END
												)
								) AS NCHAR(10) 
							)															AS DimPortfolioID

					, CAST( 
							HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														hs.SecID,														
														CASE WHEN ss.Meta_LoadDateTime IS NULL 
														THEN 
															N''
														ELSE
															CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
														END
													)
									) AS NCHAR(10) 									
							)															AS DimSecurityID							

					, CAST( 
							HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														hb.BrokerCode,														
														CASE WHEN sb.Meta_LoadDateTime IS NULL 
														THEN 
															N''
														ELSE
															CONVERT( NVARCHAR(30), sb.Meta_LoadDateTime, 126 )
														END
													)
									) AS NCHAR(10) 									
							)															AS DimBrokerID	
							
					, CAST(  
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hpc.CurrencyCode,														
															CASE WHEN spc.Meta_LoadDateTime IS NULL 
															THEN 
																N''
															ELSE																														
																CONVERT( NVARCHAR(30), spc.Meta_LoadDateTime, 126 )
															END
														)
										) AS NCHAR(10) 
							)															AS DimPriceCcyID

					, CAST(  
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hsc.CurrencyCode,		
															CASE WHEN ssc.Meta_LoadDateTime IS NULL 
															THEN 
																N''
															ELSE															
																CONVERT( NVARCHAR(30), ssc.Meta_LoadDateTime, 126 )
															END
														)
										) AS NCHAR(10) 
							)															AS DimSettleCcyID
														
					--, st.STATUS
					, st.SeqEntryDateTime
					-- , st.TRANNUM_Original
					, st.PORTCODE
					, st.SECID
					, st.TRANTYPE
					, st.FOOTNOTE
					--, st.CLASS
					, st.TRADDATE

					--, st.SETTDATE
					--, st.BROKCODE
					, st.SHAREPAR
					, st.PriceCcyISO 

					--, st.SettleCcyISO 

					, st.FXRATE
					-- , st.FXRATEPS 
					-- , st.FXRATESB 
					, st.PRICEU 
					--, st.PRICCURR 
					--, st.SETTCURR 
					, st.GROSAMTU
					, st.COMMISSU
					, st.MISCTOTU
					, st.NETAMTU
					, st.COSTOTLU
					, st.GAINU
					, st.GROSAMTC
					, st.COMMISSC
					, st.MISCTOTC
					, st.NETAMTC
					, st.COSTOTLC
					, st.GAINC
					, st.QuantityChange
					, st.CostChangeLC
					, st.CostChangeBC
					, st.DEBITU
					, st.CREDITU
					, st.DEBITS
					, st.CREDITS
					, st.DEBITC
					, st.CREDITC
					, st.NetCashLC
					, st.NetCashSC
					, st.NetCashBC
					, st.TRADTYPE
					--, st.ANNOT
					, st.EXCUM
					--, st.EXREFNUM

					--, st.MISC1U
					--, st.MISC2U
					--, st.MISC3U
					--, st.MISC4U
					--, st.MISC5U
					--, st.MISC6U

					--, st.MISC1C
					--, st.MISC2C
					--, st.MISC3C
					--, st.MISC4C
					--, st.MISC5C
					--, st.MISC6C 

					--, st.MISCCODS
										
					-- , st.ENTRDATE
					-- , st.ENTRTIME
					--, st.ENTRDATETIME
					
					-- , st.EFFEDATE
					-- , st.MODIDATE
					-- , st.MODITIME
					--, st.MODIDATETIME
				
					, CASE	WHEN ( st.[TRANTYPE] = N'S' AND st.[FOOTNOTE] = N'CO' )
							THEN st.[COSTOTLC] + st.[GAINC]
							ELSE st.[NETAMTC] END 														
																							AS [Net Amount BC] 
							
					, CASE	WHEN ( st.[TRANTYPE] = N'S' AND st.[FOOTNOTE] = N'CO' )
							THEN st.[COSTOTLU] + st.[GAINU]
							ELSE st.[NETAMTU] END 													
																							AS [Net Amount LC]

					, rtm.Meta_LoadDateTime									AS Meta_TranRefAnalysis_LoadEndDateTime
					, rtm.To_Trans_Category									AS [Transaction Category Text]
					, rtm.To_Unit_Category									AS [Unit Category Text]
					, rtm.To_Cash_Category									AS [Cash Category Text]
					
					,	CASE UPPER(TRIM(COALESCE( rtm.To_Trans_Category, N'' )))
						WHEN	N''			THEN 0
						WHEN	N'BUY'		THEN 1
						WHEN	N'CASH'		THEN 2
						WHEN	N'COST'		THEN 3
						WHEN	N'EXCHANGE'	THEN 4
						WHEN	N'INCOME'	THEN 5
						WHEN	N'SELL'		THEN 6																		
						END													AS [Transaction Category]

					,	CASE UPPER(TRIM(COALESCE( rtm.To_Unit_Category, N'' )))
						WHEN	N''			THEN 0
						WHEN	N'UNIT'		THEN 1
						END													AS [Unit Category]
						
					,	CASE UPPER(TRIM(COALESCE( rtm.To_Cash_Category, N'' ))) 
						WHEN	N''			THEN 0
						WHEN	N'CASH'		THEN 1
						WHEN	N'OTHER'	THEN 2																								
						END													AS [Cash Category]

					, st.Meta_ETLProcessID									AS Meta_ETLProcessID
					, CAST( st.Meta_LoadDateTime AS SMALLDATETIME)			AS Meta_Tran_LoadDateTime

		FROM			dv.LinkTransactions			lt

		INNER JOIN		dv.SatTransactions			st
		ON				lt.HKeyTransaction			=	st.HKeyTransaction
		AND				st.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.SatTransactions
							WHERE	st.HKeyTransaction			=		HKeyTransaction									
							AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
														AND				Meta_LoadEndDateTime
							AND		[STATUS]					=		N'PCR'
						)


	--	Retrieve last loaded satellite attributes for transaction fact dimensions 
	
		-- Securities
		INNER JOIN		dv.HubSecurities	hs
		ON				lt.HKeySecurity				=	hs.HKeySecurity
		
		LEFT JOIN		dv.SatSecurities	ss
		ON				lt.HKeySecurity				=	ss.HKeySecurity		
		AND				ss.Meta_LoadEndDateTime		=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.SatSecurities
							WHERE	ss.HKeySecurity		=				HKeySecurity									
							AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
														AND				Meta_LoadEndDateTime							
						)
					
		-- Portfolios
		INNER JOIN		dv.HubPortfolios	hp
		ON				lt.HKeyPortfolio			=	hp.HKeyPortfolio	

		LEFT JOIN		dv.SatPortfolios	sp
		ON				lt.HKeyPortfolio			=	sp.HKeyPortfolio
		AND				sp.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.SatPortfolios
							WHERE	sp.HKeyPortfolio		=				HKeyPortfolio									
							AND		@AsOfDateTime			BETWEEN			Meta_LoadDateTime	
															AND				Meta_LoadEndDateTime							
						)

		-- Brokers		
		INNER JOIN		dv.HubBrokers		hb
		ON				lt.HKeyBroker		=	hb.HKeyBroker

		LEFT JOIN		dv.SatBrokers		sb
		ON				lt.HKeyBroker				=	sb.HKeyBroker
		AND				sb.Meta_LoadEndDateTime		=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.SatBrokers
							WHERE	sb.HKeyBroker	=				HKeyBroker									
							AND		@AsOfDateTime	BETWEEN			Meta_LoadDateTime	
													AND				Meta_LoadEndDateTime							
						)

		-- Price Currency 
		INNER JOIN		dv.HubCurrencies		hpc
		ON				lt.HKeyPriceCcyISO			=	hpc.HKeyCurrency	
		
		LEFT JOIN		dv.SatCurrencies		spc
		ON				lt.HKeyPriceCcyISO			=	spc.HKeyCurrency
		AND				spc.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.SatCurrencies
							WHERE	spc.HKeyCurrency		=				HKeyCurrency									
							AND		@AsOfDateTime			BETWEEN			Meta_LoadDateTime	
															AND				Meta_LoadEndDateTime							
						)
						
		-- Settle Currency 
		INNER JOIN		dv.HubCurrencies		hsc
		ON				lt.HKeySettleCcyISO			=	hsc.HKeyCurrency	
		
		LEFT JOIN		dv.SatCurrencies		ssc
		ON				lt.HKeySettleCcyISO			=	ssc.HKeyCurrency
		AND				ssc.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.SatCurrencies
							WHERE	ssc.HKeyCurrency		=				HKeyCurrency									
							AND		@AsOfDateTime			BETWEEN			Meta_LoadDateTime	
															AND				Meta_LoadEndDateTime							
						)		
		
		-- Transaction Analysis Mapping category 
		LEFT JOIN		ref.RefTransactionAnalysisMapping	rtm
		ON				rtm.From_TransType			=	st.TRANTYPE
		AND				rtm.From_TradeType			=	st.TRADTYPE
		AND				rtm.From_FootNote			=	st.FOOTNOTE
		
		AND				rtm.From_PrimaryType		=	CASE	WHEN ss.PrimaryType = N'X'
																THEN ss.PrimaryType		
																ELSE rtm.From_PrimaryType END															

		AND				rtm.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	ref.RefTransactionAnalysisMapping
							WHERE	@AsOfDateTime			BETWEEN			Meta_LoadDateTime	
															AND				Meta_LoadEndDateTime							
						)		


		WHERE			st.[STATUS]					=	N'PCR'
		AND				hs.SecID					NOT LIKE N'PCASH%'
		AND				hs.SecID					NOT IN ( N'WMFSHARESC')
		AND 			hs.SecID					NOT LIKE N'CFX%'
	;
