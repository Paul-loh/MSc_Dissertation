CREATE PROCEDURE [InfoMartFinRep].[GetFactSecuritySummary]		@AsOfDateTime	DATETIME2 =	NULL														
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Fact Table in Finrep (Financial Reporting) Information Mart.
	--
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where parameter is <= Meta_LoadEndDateTime													
	--						Grain: 
	--								ReportDate | Security 

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;

	SELECT				
				CAST( 
						HASHBYTES	(	N'SHA1',
									CONCAT_WS	(	
													N'|',
													hs.SecID,														
													CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
												)
								) AS NCHAR(10) 									
						)														AS DimSecurityID				
				,						
					CAST(  					
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
							AS NCHAR(10) ) 										AS DimSecurityMappingID
															   								 
				,10000 * YEAR ( lss.ReportDate ) + 
				100 * MONTH( lss.ReportDate ) + 
				DAY ( lss.ReportDate )											AS ReportDateKey 

				,CAST( lss.ReportDate AS DATE)									AS ReportDate

				,lss.AsOfDateTime 					
				,lss.SecID						-- Type 2 Dim PK value
				,lss.PriceCurrencyCode
				,lss.PriceCurrencyBidPrice					
				,lss.PriceCurrencyFXRateToGBP
				-- ,lss.SettleCurrencyCode
				,ssh.Holding
				,ssh.SumInvestmentCapitalBC
				,ssh.SumInvestmentCapitalLC
				,ssh.SumMoneyInBC
				,ssh.SumMoneyInLC
				,ssh.SumMoneyOutBC
				,ssh.SumMoneyOutLC
				,ssh.Vintage

				,ssv.ValuationBC
				,ssv.ValuationLC
				,lss.Meta_RecordSource
				, CAST( ssh.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Holding_LoadDateTime
				-- ...										

		FROM			bv.LinkSecuritySummary		lss
		
		INNER JOIN		bv.SatSecurityHoldings		ssh
		ON				lss.HKeySecuritySummary		=	ssh.HKeySecuritySummary

		INNER JOIN		bv.SatSecurityValuations	ssv
		ON				lss.HKeySecuritySummary		=	ssv.HKeySecuritySummary
	
		--	Retrieve correct satellite attributes where Load DateTime of link between satellite LoadDateTime and LoadEndDateTime
		INNER JOIN		dv.HubSecurities	hs
		ON				lss.HKeySecurity		= hs.HKeySecurity

		INNER JOIN		dv.SatSecurities	ss
		ON				lss.HKeySecurity		=	ss.HKeySecurity
		AND				lss.Meta_LoadDateTime	BETWEEN ss.Meta_LoadDateTime	AND		ss.Meta_LoadEndDateTime
		
		LEFT JOIN		ref.RefSecurityIdentifierMappings	rsm
		ON				rsm.LeadSystemCode					=	N'PACER'
		AND				rsm.LeadSystemSecurityCode			=	lss.SecID
		AND				lss.Meta_LoadDateTime				BETWEEN rsm.Meta_LoadDateTime AND rsm.Meta_LoadEndDateTime
		
		--  Take only last loaded summarised data for each security per report date 
		WHERE	lss.Meta_LoadDateTime	=				
						(	
							SELECT		MAX( Meta_LoadDateTime )
							FROM		bv.LinkSecuritySummary
							WHERE		ReportDate			=	lss.ReportDate						
							AND			HKeySecurity		=	lss.HKeySecurity							
						) 		
		AND		lss.Meta_LoadDateTime	<=	@AsOfDateTime
	;

