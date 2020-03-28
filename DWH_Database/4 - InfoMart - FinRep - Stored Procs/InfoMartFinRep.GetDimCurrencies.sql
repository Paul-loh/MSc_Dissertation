CREATE PROCEDURE [InfoMartFinRep].[GetDimCurrencies]	@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Currencies Dimension Table in Finrep (Financial Reporting) Information Mart.
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter is between 
--													Meta_LoadDateTime + Meta_LoadEndDateTime	
--
--						Grain: Currency ID | Load DateTime

		IF ( @AsOfDateTime IS NULL )  
		BEGIN 
			SET @AsOfDateTime = SYSDATETIME()
		END;
					
		SELECT			
						CAST(
								HASHBYTES	(	N'SHA1',
												CONCAT_WS	(	
																N'|',
																hc.CurrencyCode,														
																CASE	WHEN sc.Meta_LoadDateTime IS NULL 
																		THEN 
																			N''
																		ELSE	
																			CONVERT( NVARCHAR(30), sc.Meta_LoadDateTime, 126 )
																		END
															)
											)	AS NCHAR(10) 
							)												AS DimCurrencyID						

						, hc.CurrencyCode

					--	If a Business Entity is seen for first time in transaction record and there's no associated
					--	attribute data, i.e. only the Hub exists, default attribute values to 'UNKNOWN'.

						,	CASE WHEN sc.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE
								sc.SSCCode
							END												AS SSCCode

						,	CASE WHEN sc.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE
								sc.CurrencyName
							END												AS CurrencyName

						,	CASE WHEN sc.Meta_LoadDateTime IS NULL
							THEN
								N'UNKNOWN'
							ELSE
								sc.CurrencyGroup
							END												AS CurrencyGroup
							
						, LEFT( TRIM( sc.Meta_RecordSource ), 20 )			AS Meta_Currency_RecordSource
						, CAST( sc.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Currency_LoadDateTime
						--, hc.Meta_LastSeenDateTime							AS Meta_Currency_LastSeenDateTime

		FROM			dv.HubCurrencies			hc				
		INNER JOIN		dv.SatCurrencies			sc
		ON				hc.HKeyCurrency				=		sc.HKeyCurrency
		--AND				@AsOfDateTime				<=		sc.Meta_LoadEndDateTime
		--AND 			sc.Meta_LoadEndDateTime		=	N'9999-12-31'
		AND				sc.Meta_LoadEndDateTime		=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.[SatCurrencies]
							WHERE	HKeyCurrency				=				sc.HKeyCurrency				
							AND		@AsOfDateTime				BETWEEN			Meta_LoadDateTime	
																AND				Meta_LoadEndDateTime
						)
;




