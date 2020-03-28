CREATE VIEW [InfoMartFinRep].[FactPrices]
	AS 
--	Author:				Paul Loh	
--	Creation Date:		20191128
--	Description:		Fact Table in Finrep (Financial Reporting) Information Mart.
--
--						Grain: Calendar Day | Security 

		SELECT 
				 CAST( k.AsAtDate AS DATE) AS AsAtDate
				, CAST( 
						HASHBYTES	(	N'SHA1',
								CONCAT_WS	(	
												N'|',
												 k.SecID,														
												CONVERT( NVARCHAR(30), k.Security_Meta_LoadDateTime, 126 )
											)
							) AS NCHAR(10) 
						)												AS DimSecurityID		 
				 , LEFT( TRIM( k.SecID ), 10)							AS SecID 

				 --, k.HKeySecurity		 						-- TBD:		Do we need this?				 
				 , CAST( b.PriceDate AS DATE )							AS PriceDate
				 , LEFT( TRIM( b.PriceSource ), 3)						AS PriceSource
				 , b.Multiplier 
				 , b.BidPrice
				 -- , b.TradingVolume
				 --, k.Security_Meta_LoadDateTime		 
				 , CAST( b.Price_Meta_LoadDateTime AS SMALLDATETIME )	AS Price_Meta_LoadDateTime
		 
		FROM			
			( 
				-- Limit history 				
				SELECT	rc.CalendarDate			AS AsAtDate, 
						s.HKeySecurity,
						s.SecID,
						s.Security_Meta_LoadDateTime	
						-- , N'D'				AS PriceType 
				FROM							
						ref.RefCalendar	rc 
						, 						
						( 
							SELECT	
									lt.HKeySecurity
									, st.SECID
									, ss.Meta_LoadDateTime							AS Security_Meta_LoadDateTime
									, DATEADD( DAY, -3, MIN( st.TRADDATE ))			AS Min_Date

									,CASE	WHEN SUM( COALESCE( st.[QuantityChange], 0.0) )	= 0.0
											THEN DATEADD( DAY, 3, MAX( st.TRADDATE ))
											ELSE GETDATE() END						AS Max_Date										 

									, SUM( COALESCE( st.[QuantityChange], 0.0) )	AS Holding			

							FROM		dv.LinkTransactions			lt

							INNER JOIN	dv.SatTransactions			st
							ON			lt.HKeyTransaction			=		st.HKeyTransaction
							AND			st.Meta_LoadEndDateTime		=		N'9999-12-31'

							--INNER JOIN	dv.HubSecurities	hs
							--ON			lt.HKeySecurity				=		hs.HKeySecurity

							INNER JOIN	dv.SatSecurities	ss
							ON			lt.HKeySecurity				=		ss.HKeySecurity
							AND			ss.Meta_LoadEndDateTime		=		N'9999-12-31'
							
							WHERE		ss.PrimaryType				NOT IN ( N'X', N'U', N'C') 							
							AND			st.[Status]					=		N'PCR'							
							AND			st.PORTCODE IN				(	N'CC05Q', N'CC30I'	) 	
							AND			ss.SecID					NOT LIKE N'PCASH%'														
							
							GROUP BY	lt.HKeySecurity
										, st.SECID
										, ss.Meta_LoadDateTime
						) s

				WHERE	rc.CalendarDate BETWEEN s.Min_Date AND s.Max_Date
		
				--UNION					
				--SELECT	rc.CalendarDate		AS AsAtDate, 
				--		hs.HKeySecurity,
				--		hs.SecID			AS SecurityCode, 
				--		N'M'				AS PriceType 

				--FROM	ref.RefCalendar rc, 
				--		dv.HubSecurities hs
				--WHERE	rc.CalendarDate		BETWEEN	DATEADD(YEAR, -11, GETDATE()) 	
				--							AND		DATEADD(DAY, 7, GETDATE()) 			
			) k

		OUTER APPLY (		
						SELECT	
								TOP 1
								lp.HKeyPrice 								
								-- ,lp.Meta_LoadDateTime
								-- ,lp.Meta_LastSeenDateTime
								,lp.PriceDate
								,lp.PriceSource
								,lp.PriceType
								,sp.BidPrice 
								--,sp.AskPrice
								--,sp.HighPrice
								--,sp.LowPrice
								-- , sp.TradingVolume
								--, sp.Yield
								, ss.Multiplier
								, sp.Meta_LoadDateTime		AS Price_Meta_LoadDateTime
										
						FROM		dv.LinkPrices		lp
							
						INNER JOIN	dv.SatPrices		sp
						ON			lp.HKeyPrice				=	sp.HKeyPrice
						AND			sp.Meta_LoadEndDateTime		=	N'9999-12-31'
							
						--INNER JOIN	dv.HubSecurities	hs
						--ON			lp.HKeySecurity				=	hs.HKeySecurity

						INNER JOIN	dv.SatSecurities	ss
						ON			lp.HKeySecurity				=	ss.HKeySecurity					-- TBD:		SLOW!!!
						AND			ss.Meta_LoadEndDateTime		=	N'9999-12-31'
							
						INNER JOIN	ref.RefPriceSources	rps											-- TBD:		SLOW!!!
						ON			ISNULL( rps.PrimaryType, ss.PrimaryType)	= ss.PrimaryType
						AND			ISNULL( rps.PriceCcy, ss.PriceCcyISO )		= ss.PriceCcyISO
						AND			ISNULL( rps.Residence, ss.ResidenceCtry)	= ss.ResidenceCtry						
						AND			ISNULL( rps.PriceSource, lp.PriceSource)	= lp.PriceSource
																												
						WHERE		ss.HKeySecurity		=	k.HKeySecurity
						AND			lp.PriceType	=	N'D' -- k.PriceType							-- TBD:		Daily & Month End Prices???
						AND			lp.PriceDate	=	(			
															SELECT		MAX( PriceDate ) 
															FROM		dv.LinkPrices															
															WHERE		PriceDate				<=	k.AsAtDate 															
															AND			PriceType				=	N'D' --k.PriceType															
															AND			HKeySecurity			=	k.HKeySecurity															
														)						

						ORDER BY	rps.RecordPriority,
									rps.PriSrcPriority
					) b
					
		-- WHERE	K.SECID	IN (N'B16GWD5', N'B16GWN5', N'0719210', N'BH4HKS3')
		-- WHERE	K.SecurityCode	= N'B16GWD5'