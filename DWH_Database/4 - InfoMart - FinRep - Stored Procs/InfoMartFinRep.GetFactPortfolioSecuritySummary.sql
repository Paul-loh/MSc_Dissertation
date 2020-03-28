CREATE PROCEDURE [InfoMartFinRep].[GetFactPortfolioSecuritySummary]		@AsOfDateTime	DATETIME2 =	NULL														
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Main Fact Table in Finrep (Financial Reporting) Information Mart.
	--
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where parameter is <= Meta_LoadEndDateTime													
	--						Grain: 
	--								ReportDate | Porfolio | Security 

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;

	SELECT				
					CAST( 
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hp.PortfCode,														
															CONVERT( NVARCHAR(30), sp.Meta_LoadDateTime, 126 )
														)
										) AS NCHAR(10) 									
						)																			AS DimPortfolioID
							
					,CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hs.SecID,														
															CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
														)
										) AS NCHAR(10)														
						)																			AS DimSecurityID

					,CAST(
							CASE	WHEN	rsm.PartnerSystemCode001 IS NULL
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
														) 
									END				
							 AS NCHAR(10)									
						)																			AS DimSecurityMappingID

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
					,lps.Meta_RecordSource
					, CAST( sph.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Holding_LoadDateTime

		FROM			bv.LinkPortfolioSecuritySummary	lps 

		INNER JOIN		bv.SatPortfolioSecurityHoldings	sph
		ON				lps.HKeyPortfolioSecuritySummary	=	sph.HKeyPortfolioSecuritySummary
		
		INNER JOIN		bv.SatPortfolioSecurityValuations	spv
		ON				lps.HKeyPortfolioSecuritySummary	=	spv.HKeyPortfolioSecuritySummary
		
		--	Retrieve correct satellite attributes where Load DateTime of link between satellite LoadDateTime and LoadEndDateTime
		LEFT JOIN		dv.HubSecurities	hs
		ON				lps.HKeySecurity		= hs.HKeySecurity

		LEFT JOIN		dv.SatSecurities	ss
		ON				lps.HKeySecurity		=	ss.HKeySecurity
		AND				lps.Meta_LoadDateTime	BETWEEN ss.Meta_LoadDateTime	AND		ss.Meta_LoadEndDateTime
		
		LEFT JOIN		dv.HubPortfolios	hp
		ON				lps.HKeyPortfolio		=	hp.HKeyPortfolio	

		LEFT JOIN		dv.SatPortfolios	sp
		ON				lps.HKeyPortfolio		=	sp.HKeyPortfolio
		AND				lps.Meta_LoadDateTime	BETWEEN sp.Meta_LoadDateTime	AND		sp.Meta_LoadEndDateTime				

		LEFT JOIN		ref.RefSecurityIdentifierMappings	rsm
		ON				rsm.LeadSystemCode					=	N'PACER'
		AND				rsm.LeadSystemSecurityCode			=	lps.SecID
		AND				lps.Meta_LoadDateTime				BETWEEN rsm.Meta_LoadDateTime AND rsm.Meta_LoadEndDateTime
		
			-- Mast \ subsidiary relationships
		LEFT JOIN		[dv].[LinkPortfolioMasterSubsidiary]	lpms
		ON				lpms.HKeySubsidiaryPortfolioCode		=	sp.HKeyPortfolio

		LEFT JOIN		[dv].SatPortfolioMasterType				spms
		ON				lpms.HKeyMasterPortfolioCode			=	spms.HKeyPortfolio
		AND				lps.Meta_LoadDateTime					BETWEEN spms.Meta_LoadDateTime AND spms.Meta_LoadEndDateTime
		

		--  Take only last loaded summarised data for each Report Date ?
		WHERE	lps.Meta_LoadDateTime	=				
						(	
							SELECT		MAX( Meta_LoadDateTime )
							FROM		bv.LinkPortfolioSecuritySummary
							WHERE		ReportDate						=	lps.ReportDate														
							AND			HKeySecurity					=	lps.HKeySecurity										
							AND			HKeyPortfolio					=	lps.HKeyPortfolio
						) 	
		AND		lps.Meta_LoadDateTime	<=	@AsOfDateTime		

		--	Calculate only QUOTED + INCOME pools (or unknown)
		AND		(	
					lpms.MasterPortfolioCode	IN	(N'CM01QTD', N'CM02IGP')
					OR
					lpms.MasterPortfolioCode	IS NULL
				)		
	;
