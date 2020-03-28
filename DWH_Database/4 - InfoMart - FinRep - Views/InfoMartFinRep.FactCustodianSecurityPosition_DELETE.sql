
CREATE VIEW [InfoMartFinRep].[FactCustodianSecurityPosition]
	AS 
	
--	Author:				Paul Loh	
--	Creation Date:		20191018
--	Description:		Main Fact Table of Custodian Holdings in (Financial Reporting) Information Mart.
--
--						Grain: ReportDate | Security 
	
	SELECT				
					-- Add Type 2 Dim PKs 
					HASHBYTES	(	N'SHA1',
								CONCAT_WS	(	
												N'|',
												lcp.ISIN  ,														
												CONVERT( NVARCHAR(30), scs.Meta_LoadDateTime, 126 )
											)
							)				AS SecurityKey

					,HASHBYTES	(	N'SHA1',
								CONCAT_WS	(	
												N'|',
												lcp.SecuritiesAccountNumber  ,														
												CONVERT( NVARCHAR(30), sca.Meta_LoadDateTime, 126 )
											)
							)				AS SecurityAccountNumberKey

					,HASHBYTES	(	N'SHA1',
								CONCAT_WS	(	
												N'|',
												lcp.SecurityCurrency ,														
												CONVERT( NVARCHAR(30), scs.Meta_LoadDateTime, 126 )
											)
							)				AS CurrencyKey

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

					,10000 * YEAR ( lcp.ReportDate ) + 
					100 * MONTH( lcp.ReportDate ) + 
					DAY ( lcp.ReportDate )	AS ReportDateKey 

					,CAST( lcp.ReportDate AS DATE) AS ReportDate

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
					
					,N'BRXXX'					AS Meta_RecordSource		-- Computed dataset so identify source as Business Rule Reference
					-- ...										

		FROM			dv.LinkCustodianPositions	lcp
		
		--	Retrieve correct satellite attributes where Load DateTime of link between satellite LoadDateTime and LoadEndDateTime		
		INNER JOIN		dv.SatCustodianPositions	scp
		ON				lcp.HKeyCustodianPosition			=	scp.HKeyCustodianPosition
		AND				lcp.Meta_LoadDateTime				BETWEEN scp.Meta_LoadDateTime AND scp.Meta_LoadEndDateTime

		INNER JOIN		dv.SatCustodianSecurities	scs
		ON				lcp.HKeyCustodianSecurity			=	scs.HKeyCustodianSecurity
		AND				lcp.Meta_LoadDateTime				BETWEEN scs.Meta_LoadDateTime AND scs.Meta_LoadEndDateTime
		
		INNER JOIN		dv.SatCustodianAccounts		sca
		ON				lcp.HKeyCustodianAccount			=	sca.HKeyCustodianAccount
		AND				lcp.Meta_LoadDateTime				BETWEEN sca.Meta_LoadDateTime AND sca.Meta_LoadEndDateTime

		--	TBD: Currency definition from Pacer ? 
		LEFT JOIN		dv.SatCurrencies			sc
		ON				lcp.HKeyPriceCurrency				=	sc.HKeyCurrency
		AND				lcp.Meta_LoadDateTime				BETWEEN sc.Meta_LoadDateTime AND sc.Meta_LoadEndDateTime

		LEFT JOIN		ref.RefSecurityIdentifierMappings	rsm
		ON				rsm.PartnerSystemCode001			=	N'HSBCNET'
		AND				rsm.PartnerSystemSecurityCode001	=	lcp.ISIN
		AND				lcp.Meta_LoadDateTime				BETWEEN rsm.Meta_LoadDateTime AND rsm.Meta_LoadEndDateTime
		
		--  TBD: Take only last loaded summarised data for each Report Date ?
		WHERE	lcp.Meta_LoadDateTime	=				
						(	
							SELECT		MAX( Meta_LoadDateTime )
							FROM		dv.LinkCustodianPositions
							WHERE		HKeyCustodianPosition		=	lcp.HKeyCustodianPosition
							AND			ReportDate					=	lcp.ReportDate							
						) 
	;
