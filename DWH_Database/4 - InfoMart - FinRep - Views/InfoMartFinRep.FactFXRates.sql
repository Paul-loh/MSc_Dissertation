CREATE VIEW [InfoMartFinRep].[FactFXRates]
	AS
	
--	Author:				Paul Loh	
--	Creation Date:		20191129
--	Description:		Fact Table in Finrep (Financial Reporting) Information Mart.
--
--						Grain: Date | Currency

		SELECT				 
				10000 * YEAR ( c.AsAtDate ) + 
				100 * MONTH( c.AsAtDate ) + 
				DAY ( c.AsAtDate )										AS FXRateDateKey 
				, c.AsAtDate 
				, CAST(  
						HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														b.CurrencyCode,														
														CONVERT( NVARCHAR(30), b.Meta_Currency_LoadDateTime, 126 )
													)
									) AS NCHAR(10) 
						)												AS DimCurrencyID
				, b.RateDate
				
				--, b.HKeyFXRate 	
				--, b.HKeyCurrency	
				
				, LEFT( TRIM( b.CurrencyCode ), 3) 						AS CurrencyCode
				, b.RateToGBP					

				--, b.Meta_Currency_RecordSource
				--, b.Meta_Currency_LoadDateTime
				-- , b.Meta_FXRate_RecordSource
				, CAST( b.Meta_FXRate_LoadDateTime	AS SMALLDATETIME)	AS Meta_FXRate_LoadDateTime	
				
		FROM			
		-- Limit history 	
			(
				SELECT 
					CAST( rc.CalendarDate AS DATE)	AS AsAtDate
					-- rc.CalendarDate			AS AsAtDate
					, pc.HKeyPriceCcyISO
					, pc.PriceCcyISO

				FROM 
					ref.RefCalendar	rc 
					, 						
					( 
							SELECT	
									lt.HKeyPriceCcyISO									
									, st.PriceCcyISO
									, DATEADD( DAY, -3, MIN( st.TRADDATE ))			AS Min_Date
									, CASE	WHEN SUM( COALESCE( st.[QuantityChange], 0.0) )	= 0.0
											THEN DATEADD( DAY, 3 , MAX( st.TRADDATE ))
											ELSE GETDATE() END						AS Max_Date										 

							FROM		dv.LinkTransactions			lt

							INNER JOIN	dv.SatTransactions			st
							ON			lt.HKeyTransaction			=		st.HKeyTransaction
							AND			st.Meta_LoadEndDateTime		=		N'9999-12-31'

							INNER JOIN	dv.SatSecurities	ss
							ON			lt.HKeySecurity				=		ss.HKeySecurity
							AND			ss.Meta_LoadEndDateTime		=		N'9999-12-31'
							
							WHERE		ss.PrimaryType				NOT IN	( N'X', N'U', N'C') 							
							AND			st.[Status]					=		N'PCR'							
							AND			st.PORTCODE					IN		( N'CC05Q', N'CC30I' ) 				
							AND			ss.SecID					NOT LIKE N'PCASH%'														
							
							GROUP BY	lt.HKeyPriceCcyISO, 
										st.PriceCcyISO
					) pc
						
				WHERE	rc.CalendarDate		BETWEEN pc.Min_Date AND pc.Max_Date
			)	c	
		
		OUTER APPLY (		
						SELECT	
								TOP 1
								lfx.HKeyFXRate 								
								, lfx.HKeyCurrency
								-- , lfx.RateDate		
								, CAST( lfx.RateDate AS DATE) AS RateDate
								, lfx.CurrencyCode
								, sfx.RateToGBP								
								, sc.Meta_RecordSource		AS Meta_Currency_RecordSource
								, sc.Meta_LoadDateTime		AS Meta_Currency_LoadDateTime
								, sfx.Meta_RecordSource		AS Meta_FXRate_RecordSource
								, sfx.Meta_LoadDateTime		AS Meta_FXRate_LoadDateTime
																		
						FROM			dv.LinkFXRates		lfx
							
						INNER JOIN		dv.SatFXRates		sfx
						ON				lfx.HKeyFXRate					=	sfx.HKeyFXRate
						AND				sfx.Meta_LoadEndDateTime		=	N'9999-12-31'
						
						INNER JOIN		dv.HubCurrencies	hc
						ON				lfx.HKeyCurrency				=	hc.HKeyCurrency
		
						INNER JOIN		dv.SatCurrencies	sc
						ON				hc.HKeyCurrency					=	sc.HKeyCurrency
						AND				sc.Meta_LoadEndDateTime			=	N'9999-12-31'
																												
						WHERE			lfx.HKeyCurrency	=	c.HKeyPriceCcyISO						
						AND				lfx.RateDate		=	(			
																	SELECT		MAX( RateDate ) 
																	FROM		dv.LinkFXRates															
																	WHERE		RateDate				<=	c.AsAtDate 																																																									
																	AND			HKeyCurrency			=	c.HKeyPriceCcyISO																
																)						
						ORDER BY		lfx.RateDate DESC
					) b

		-- TBD: Not sure why we get NULL but filter out for now 
		WHERE		b.HKeyFXRate	IS NOT NULL
;


