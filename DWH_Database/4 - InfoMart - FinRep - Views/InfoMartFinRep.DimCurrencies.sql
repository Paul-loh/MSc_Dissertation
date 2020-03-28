CREATE VIEW [InfoMartFinRep].[DimCurrencies]
AS 
	--	Author:				Paul Loh	
	--	Creation Date:		20191129
	--	Description:		Currencies Dimension Table in Finrep (Financial Reporting) Information Mart.
	--
	--						Grain: Currency ID | Load DateTime
			
		SELECT			
						CAST(
								HASHBYTES	(	N'SHA1',
												CONCAT_WS	(	
																N'|',
																hc.CurrencyCode,														
																CONVERT( NVARCHAR(30), sc.Meta_LoadDateTime, 126 )
															)
											)	AS NCHAR(10) 
							)											AS DimCurrencyID
						
						--, HASHBYTES	(	N'SHA1',
						--				CONCAT_WS	(	
						--								N'|',
						--								hc.CurrencyCode,														
						--								CONVERT( NVARCHAR(30), sc.Meta_LoadDateTime, 126 )
						--							)
						--			)									AS CurrencyKey
						, hc.CurrencyCode
						, sc.SSCCode
						, sc.CurrencyName
						, sc.CurrencyGroup
						, LEFT( TRIM( sc.Meta_RecordSource ), 20 )			AS Meta_Currency_RecordSource
						, CAST( sc.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Currency_LoadDateTime
						--, hc.Meta_LastSeenDateTime							AS Meta_Currency_LastSeenDateTime
		FROM			dv.HubCurrencies			hc				
		INNER JOIN		dv.SatCurrencies			sc
		ON				hc.HKeyCurrency				=	sc.HKeyCurrency
		-- AND 			sc.Meta_LoadEndDateTime		=	N'9999-12-31'
;