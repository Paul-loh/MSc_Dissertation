CREATE VIEW  [InfoMartFinRep].[DimCustodianSecurity]
AS 

	--	Author:				Paul Loh	
	--	Creation Date:		20191024
	--	Description:		Custodian Securities Dimension Table in Finrep (Financial Reporting) Information Mart.
	--
	--						Grain: Account Code | Load DateTime
			
			
	SELECT			
						HASHBYTES	(	N'SHA1',
										CONCAT_WS	(	
														N'|',
														hs.ISIN,														
														CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
													)
									)										AS CustodianSecurityKey
						
						, CAST( ss.Meta_LoadDateTime AS SMALLDATETIME)		AS Meta_Cust_LoadDateTime

						-- ,ss.Meta_LoadEndDateTime
						,ss.HKeyCustodianSecurity
						,hs.ISIN
						,ss.SecurityDescription
						,ss.SEDOL
						,ss.IssueType
						,ss.IssueTypeDescription
						,ss.SecurityCurrency
						
		FROM			dv.HubCustodianSecurities		hs

		INNER JOIN		dv.SatCustodianSecurities		ss
		ON				hs.HKeyCustodianSecurity		=		ss.HKeyCustodianSecurity
;

