﻿CREATE PROCEDURE [InfoMartFinRep].[GetFactCustodianSecurityPosition]	@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Main Fact Table of Custodian Holdings in (Financial Reporting) Information Mart.
--						
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter is between 
--													Meta_LoadDateTime + Meta_LoadEndDateTime	
--
--						Grain: ReportDate | Security | LoadDateTime

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;

	SELECT				
					-- Add Type 2 Dim PKs 
					CAST(
							HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														lcp.ISIN  ,														
														CONVERT( NVARCHAR(30), scs.Meta_LoadDateTime, 126 )
													)
									)				
							AS NCHAR(10) ) 									AS DimCustodianSecurityID							
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
								AS NCHAR(10) ) 								AS DimSecurityMappingID
					,
						CAST(  
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
														N'|',
														lcp.SecuritiesAccountNumber  ,														
														CONVERT( NVARCHAR(30), sca.Meta_LoadDateTime, 126 )
														)
										) AS NCHAR(10) 
							) 												AS DimCustodianAccountID					
					,CAST(  
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															lcp.SecurityCurrency ,														
															CONVERT( NVARCHAR(30), scs.Meta_LoadDateTime, 126 )
														)
										) AS NCHAR(10) 
							)												AS DimCurrencyID
								
					,10000 * YEAR ( lcp.ReportDate ) + 
					100 * MONTH( lcp.ReportDate ) + 
					DAY ( lcp.ReportDate )									AS ReportDateKey 

					,CAST( lcp.ReportDate AS DATE )							AS ReportDate

					, lcp.AsOfDateTime
					, lcp.ISIN
					, lcp.SecuritiesAccountNumber
					, lcp.SecurityCurrency

					, scp.AvailableBalance
					, scp.ExchangeRate
					, scp.SecurityPrice
					, scp.SettledAggregate
					, scp.SettledAggregateValue_AccountCurrency
					, scp.SettledAggregateValue_SecurityCurrency
					, scp.TradedAggregate
					, scp.TradedValue_AccountCurrency
					, scp.TradedValue_SecurityCurrency
					
					, CAST( scp.Meta_LoadDateTime AS SMALLDATETIME )	AS Meta_LoadDateTime 
					, scp.Meta_RecordSource								AS Meta_RecordSource		

		FROM			dv.LinkCustodianPositions	lcp
		
		--	Retrieve correct satellite attributes where Load DateTime of link between satellite LoadDateTime and LoadEndDateTime		
		INNER JOIN		dv.SatCustodianPositions	scp
		ON				lcp.HKeyCustodianPosition			=	scp.HKeyCustodianPosition
		--	AND				lcp.Meta_LoadDateTime				BETWEEN scp.Meta_LoadDateTime AND scp.Meta_LoadEndDateTime
		AND				scp.Meta_LoadDateTime				=
																(
																	SELECT	MAX ( Meta_LoadDateTime ) 
																	FROM	dv.SatCustodianPositions
																	WHERE	@AsOfDateTime	BETWEEN		Meta_LoadDateTime	
																							AND			Meta_LoadEndDateTime	
																	AND		HKeyCustodianPosition	=	lcp.HKeyCustodianPosition																	
																)	

		INNER JOIN		dv.SatCustodianSecurities	scs
		ON				lcp.HKeyCustodianSecurity			=	scs.HKeyCustodianSecurity
		-- AND				lcp.Meta_LoadDateTime				BETWEEN scs.Meta_LoadDateTime AND scs.Meta_LoadEndDateTime
		AND				scs.Meta_LoadDateTime				=
																(
																	SELECT	MAX ( Meta_LoadDateTime ) 
																	FROM	dv.SatCustodianSecurities
																	WHERE	@AsOfDateTime	BETWEEN		Meta_LoadDateTime	
																							AND			Meta_LoadEndDateTime	
																	AND		HKeyCustodianSecurity	=	lcp.HKeyCustodianSecurity																	
																)		

		INNER JOIN		dv.SatCustodianAccounts		sca
		ON				lcp.HKeyCustodianAccount			=	sca.HKeyCustodianAccount
		--AND				lcp.Meta_LoadDateTime				BETWEEN sca.Meta_LoadDateTime AND sca.Meta_LoadEndDateTime
		AND				sca.Meta_LoadDateTime				=
																(
																	SELECT	MAX ( Meta_LoadDateTime ) 
																	FROM	dv.SatCustodianAccounts
																	WHERE	@AsOfDateTime	BETWEEN		Meta_LoadDateTime	
																							AND			Meta_LoadEndDateTime																		
																	AND		HKeyCustodianAccount	=	lcp.HKeyCustodianAccount
																)

		--	TBD: Currency definition from Pacer ? 
		LEFT JOIN		dv.SatCurrencies			sc
		ON				lcp.HKeyPriceCurrency				=	sc.HKeyCurrency
		-- AND				lcp.Meta_LoadDateTime				BETWEEN sc.Meta_LoadDateTime AND sc.Meta_LoadEndDateTime
		AND				sc.Meta_LoadDateTime				=	
																(
																	SELECT	MAX ( Meta_LoadDateTime ) 
																	FROM	dv.SatCurrencies
																	WHERE	@AsOfDateTime	BETWEEN		Meta_LoadDateTime	
																							AND			Meta_LoadEndDateTime	
																	AND		HKeyPriceCurrency		=	sc.HKeyCurrency
																)

		LEFT JOIN		ref.RefSecurityIdentifierMappings	rsm
		ON				rsm.PartnerSystemCode001			=	N'HSBCNET' 
		AND				rsm.PartnerSystemSecurityCode001	=	lcp.ISIN
		AND				rsm.Meta_LoadDateTime				=	
																(
																	SELECT	MAX ( Meta_LoadDateTime ) 
																	FROM	ref.RefSecurityIdentifierMappings
																	WHERE	@AsOfDateTime	BETWEEN		Meta_LoadDateTime	
																							AND			Meta_LoadEndDateTime
																	AND		PartnerSystemCode001			=	N'HSBCNET' 
																	AND		PartnerSystemSecurityCode001	=	lcp.ISIN
																)
			
		--	AND				lcp.Meta_LoadDateTime				BETWEEN rsm.Meta_LoadDateTime AND rsm.Meta_LoadEndDateTime
		

		--  TBD: Take only last loaded summarised data for each Report Date ?
		WHERE	lcp.Meta_LoadDateTime	=				
						(	
							SELECT		MAX( Meta_LoadDateTime )
							FROM		dv.LinkCustodianPositions
							WHERE		HKeyCustodianPosition		=	lcp.HKeyCustodianPosition
							AND			ReportDate					=	lcp.ReportDate							
						) 

		AND		lcp.Meta_LoadDateTime	<=	@AsOfDateTime		
	;
