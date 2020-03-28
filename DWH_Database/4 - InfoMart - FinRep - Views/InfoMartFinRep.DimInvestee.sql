CREATE VIEW [InfoMartFinRep].[DimInvestee]
AS 
	--	Author:				Paul Loh	
	--	Creation Date:		20191202
	--	Description:		Investee Dimension Table in Finrep (Financial Reporting) Information Mart.
	--						The Investee is the Backer Name if available otherwise the Issuer Name for each security  
	--						Grain: Security ID | Load DateTime

	SELECT			
					CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hs.SecID,														
															CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
														)
										)		AS NCHAR(10) 
						)												AS DimSecurityID
	
					, CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hs.SecID,															
															UPPER( CASE	WHEN hb.BackerCode IS NULL
																		THEN N'MISSING_BK' 
																		ELSE hb.BackerCode END ) ,  

															UPPER( CASE	WHEN hb.BackerCode IS NULL
																		THEN N'1900-01-01' 
																		ELSE CONVERT( NVARCHAR(30), lsb.Meta_LoadDateTime, 126 ) END )  															
														)
										)	AS NCHAR(10) 
							)											AS DimInvesteeID

					, hs.SecID
					, COALESCE( sb.ShortName, ss.IssuerName) 		AS Investee 				

					, lsb.HKeyBacker
					, lsb.BackerCode					
					, sb.ShortName									AS BackerName
					, ss.IssuerName									AS SecurityIssuerName		
					
	FROM			dv.HubSecurities		hs
	
	INNER JOIN		dv.SatSecurities		ss
	ON				hs.HKeySecurity			=	ss.HKeySecurity
	AND				ss.Meta_LoadEndDateTime	=	N'9999-12-31'

	LEFT JOIN		dv.LinkSecurityBackers	lsb
	ON				hs.HKeySecurity			=	lsb.HKeySecurity		
		
	LEFT JOIN		dv.HubBackers			hb
	ON				lsb.HKeyBacker			=	hb.HKeyBacker

	LEFT JOIN		dv.SatBackers			sb
	ON				hb.HKeyBacker			=	sb.HKeyBacker			
	AND				sb.Meta_LoadEndDateTime	=	N'9999-12-31'	
;




