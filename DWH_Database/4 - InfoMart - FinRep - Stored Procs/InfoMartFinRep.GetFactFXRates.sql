CREATE PROCEDURE [InfoMartFinRep].[GetFactFXRates]
														@AsOfDateTime	DATETIME2	=	NULL,
														@YearsHistory	INT			=	NULL
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200129
--	Description:		Get FX rates Fact Table in Finrep (Financial Reporting) Information Mart.
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter <= Meta_LoadEndDateTime													
--
--						Grain: Date | Currency


		IF ( @AsOfDateTime IS NULL )  
		BEGIN 
			SET @AsOfDateTime = SYSDATETIME()
		END 
		
		IF ( @YearsHistory IS NULL )
		BEGIN 
			SET @YearsHistory = 2 
		END 
		
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
							-- AND			@AsOfDateTime				<=		st.Meta_LoadEndDateTime
							--AND			(
							--				@AsOfDateTime				BETWEEN	st.Meta_LoadDateTime	
							--											AND		st.Meta_LoadEndDateTime
							--			)
							AND		st.Meta_LoadEndDateTime	=	
														(
															SELECT	MAX( Meta_LoadEndDateTime )
															FROM	dv.SatTransactions
															WHERE	HKeyTransaction		=				st.HKeyTransaction				
															AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
																						AND				Meta_LoadEndDateTime
														)							

							INNER JOIN	dv.SatSecurities	ss
							ON			lt.HKeySecurity				=		ss.HKeySecurity

							-- AND			@AsOfDateTime				<=		ss.Meta_LoadEndDateTime
							-- AND			(
							--				@AsOfDateTime				BETWEEN	ss.Meta_LoadDateTime	
							--											AND		ss.Meta_LoadEndDateTime
							--			)

							AND		ss.Meta_LoadEndDateTime	=	
												(
													SELECT	MAX( Meta_LoadEndDateTime )
													FROM	dv.SatSecurities
													WHERE	HKeySecurity		=				ss.HKeySecurity				
													AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
																				AND				Meta_LoadEndDateTime
												)							

							WHERE		ss.PrimaryType				NOT IN	( N'X', N'U', N'C') 							
							AND			st.[Status]					=		N'PCR'							
							AND			st.PORTCODE					IN		( N'CC05Q', N'CC30I' ) 				
							AND			ss.SecID					NOT LIKE N'PCASH%'														
							
							GROUP BY	lt.HKeyPriceCcyISO, 
										st.PriceCcyISO
					) pc
						
				WHERE	rc.CalendarDate		BETWEEN pc.Min_Date AND pc.Max_Date

				-- LIMIT HISTORY 
				AND		(	
							rc.CalendarDate		BETWEEN		DATEADD( YEAR, -@YearsHistory, @AsOfDateTime ) 
												AND			DATEADD( MONTH, 1, @AsOfDateTime )
						)						
				-- SELECT CALENDAR EFFECTIVE AT AS OF DATETIME
				AND		(
							@AsOfDateTime		BETWEEN			rc.Meta_LoadDateTime	
												AND				rc.Meta_LoadEndDateTime
						)						
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

						--AND				@AsOfDateTime					<=	sfx.Meta_LoadEndDateTime
						--AND				(
						--					@AsOfDateTime				BETWEEN	sfx.Meta_LoadDateTime	
						--												AND		sfx.Meta_LoadEndDateTime
						--				)						
						AND				sfx.Meta_LoadEndDateTime	=	
																(
																	SELECT	MAX( Meta_LoadEndDateTime )
																	FROM	dv.SatFXRates
																	WHERE	HKeyFXRate			=				sfx.HKeyFXRate				
																	AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
																								AND				Meta_LoadEndDateTime
																)		
						
						INNER JOIN		dv.HubCurrencies	hc
						ON				lfx.HKeyCurrency				=	hc.HKeyCurrency
		
						INNER JOIN		dv.SatCurrencies	sc
						ON				hc.HKeyCurrency					=	sc.HKeyCurrency
						-- AND				@AsOfDateTime					<=	sc.Meta_LoadEndDateTime
						--AND				(
						--					@AsOfDateTime				BETWEEN	sc.Meta_LoadDateTime	
						--												AND		sc.Meta_LoadEndDateTime
						--				)							
						AND		sc.Meta_LoadEndDateTime	=	
												(
													SELECT	MAX( Meta_LoadEndDateTime )
													FROM	dv.SatCurrencies
													WHERE	HKeyCurrency		=				sc.HKeyCurrency				
													AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
																				AND				Meta_LoadEndDateTime
												)		
																												
						WHERE			lfx.HKeyCurrency	=	c.HKeyPriceCcyISO						
						AND				lfx.RateDate		=	(			
																	SELECT			MAX( RateDate ) 
																	FROM			dv.LinkFXRates	lfx2														
																	INNER JOIN		dv.SatFXRates	sfx2	
																	ON				lfx2.HKeyFXRate			=		sfx2.HKeyFXRate
																	--AND				@AsOfDateTime					<=	dv.SatFXRates.Meta_LoadEndDateTime																	
																	--AND				(
																	--					@AsOfDateTime				BETWEEN	dv.SatFXRates.Meta_LoadDateTime	
																	--												AND		dv.SatFXRates.Meta_LoadEndDateTime
																	--				)																			
																	AND				sfx2.Meta_LoadEndDateTime	=	
																					(
																						SELECT	MAX( Meta_LoadEndDateTime )
																						FROM	dv.SatFXRates
																						WHERE	HKeyFXRate			=				sfx2.HKeyFXRate				
																						AND		@AsOfDateTime		BETWEEN			Meta_LoadDateTime	
																													AND				Meta_LoadEndDateTime
																					)	

																	WHERE		lfx2.RateDate				<=	c.AsAtDate 																																																									
																	AND			lfx2.HKeyCurrency			=	c.HKeyPriceCcyISO																
																)						
						-- ORDER BY		lfx.RateDate DESC
					) b

		-- TBD: Not sure why we get NULL but filter out for now 
		WHERE		b.HKeyFXRate	IS NOT NULL
;

RETURN 0
