CREATE VIEW [InfoMartFinRep].[FactPortfolioSecuritySummary]
	AS 
	
--	Author:				Paul Loh	
--	Creation Date:		20191018
--	Description:		Main Fact Table in Finrep (Financial Reporting) Information Mart.
--
--						Grain: ReportDate | Porfolio | Security 

	SELECT				
					HASHBYTES	(	N'SHA1',
							CONCAT_WS	(	
											N'|',
											hp.PortfCode,														
											CONVERT( NVARCHAR(30), sp.Meta_LoadDateTime, 126 )
										)
						)					AS PortfolioKey
							
					,HASHBYTES	(	N'SHA1',
								CONCAT_WS	(	
												N'|',
												hs.SecID,														
												CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
											)
							)				AS SecurityKey

					,CASE	WHEN	rsm.PartnerSystemCode001 IS NULL
							THEN	0x1111111111111111111111111111111111111111 --	Ghost record of unmatched hash key 
							ELSE	HASHBYTES	(	N'SHA1',
													CONCAT_WS	(	
																	N'|',
																	rsm.LeadSystemCode, 
																	rsm.LeadSystemSecurityCode, 
																	rsm.PartnerSystemCode001, 
																	rsm.PartnerSystemSecurityCode001, 
																	CONVERT( NVARCHAR(30), rsm.Meta_LoadDateTime, 126 )
																)
												) END								AS SecurityMappingKey

					,10000 * YEAR ( lps.ReportDate ) + 
					100 * MONTH( lps.ReportDate ) + 
					DAY ( lps.ReportDate )	AS ReportDateKey 

					,CAST( lps.ReportDate AS DATE) AS ReportDate

					,lps.AsOfDateTime 
					,lps.PortfCode	-- Add Type 2 Dim PK 
					,lps.SecID		-- Add Type 2 Dim PK 
					,lps.PriceCurrencyCode
					,lps.PriceCurrencyBidPrice					
					,lps.PriceCurrencyFXRateToGBP
					,lps.SettleCurrencyCode
					,sph.Holding
					,sph.SumInvestmentCapitalBC
					,sph.SumInvestmentCapitalLC
					,sph.SumMoneyInBC
					,sph.SumMoneyInLC
					,sph.SumMoneyOutBC
					,sph.SumMoneyOutLC
					,sph.Vintage

					,spv.ValuationBC
					,spv.ValuationLC

					,N'BRXXX'					AS Meta_RecordSource		-- Computed dataset so identify source as Business Rule Reference
					-- ...										

		FROM			bv.LinkPortfolioSecuritySummary	lps 

		INNER JOIN		bv.SatPortfolioSecurityHoldings	sph
		ON				lps.HKeyPortfolioSecuritySummary	=	sph.HKeyPortfolioSecuritySummary
		
		INNER JOIN		bv.SatPortfolioSecurityValuations	spv
		ON				lps.HKeyPortfolioSecuritySummary	=	spv.HKeyPortfolioSecuritySummary
	
	
		--	Retrieve correct satellite attributes where Load DateTime of link between satellite LoadDateTime and LoadEndDateTime
		INNER JOIN		dv.HubSecurities	hs
		ON				lps.HKeySecurity		= hs.HKeySecurity

		INNER JOIN		dv.SatSecurities	ss
		ON				lps.HKeySecurity		=	ss.HKeySecurity
		AND				lps.Meta_LoadDateTime	BETWEEN ss.Meta_LoadDateTime	AND		ss.Meta_LoadEndDateTime
		
		INNER JOIN		dv.HubPortfolios	hp
		ON				lps.HKeyPortfolio		=	hp.HKeyPortfolio	

		INNER JOIN		dv.SatPortfolios	sp
		ON				lps.HKeyPortfolio		=	sp.HKeyPortfolio
		AND				lps.Meta_LoadDateTime	BETWEEN sp.Meta_LoadDateTime	AND		sp.Meta_LoadEndDateTime				

		LEFT JOIN		ref.RefSecurityIdentifierMappings	rsm
		ON				rsm.LeadSystemCode					=	N'PACER'
		AND				rsm.LeadSystemSecurityCode			=	lps.SecID
		AND				lps.Meta_LoadDateTime				BETWEEN rsm.Meta_LoadDateTime AND rsm.Meta_LoadEndDateTime

		--  TBD: Take only last loaded summarised data for each Report Date ?
		WHERE	lps.Meta_LoadDateTime	=				
						(	
							SELECT		MAX( Meta_LoadDateTime )
							FROM		bv.LinkPortfolioSecuritySummary
							WHERE		ReportDate						=	lps.ReportDate														
							AND			HKeySecurity					=	lps.HKeySecurity										
							AND			HKeyPortfolio					=	lps.HKeyPortfolio
						) 	
	;
