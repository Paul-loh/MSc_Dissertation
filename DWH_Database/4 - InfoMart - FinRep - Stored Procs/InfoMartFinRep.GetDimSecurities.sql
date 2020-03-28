CREATE PROCEDURE [InfoMartFinRep].[GetDimSecurities]	@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Securities Dimension Table in Finrep (Financial Reporting) Information Mart.
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter is between 
--													Meta_LoadDateTime + Meta_LoadEndDateTime	
--
--						Grain: Security | Load DateTime

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
															CASE WHEN ss.Meta_LoadDateTime IS NULL 
															THEN 
																N''
															ELSE
																CONVERT( NVARCHAR(30), ss.Meta_LoadDateTime, 126 )
															END
														)
										)	AS NCHAR(10)  
						)											AS DimSecurityID  
						
					, CAST( ss.Meta_LoadDateTime AS SMALLDATETIME) AS Meta_Security_LoadDateTime

					, hs.SecID

					--	If a Business Entity is seen for first time in transaction record and there's no associated
					--	attribute data, i.e. only the Hub exists, default attribute values to 'UNKNOWN'.

					,	CASE WHEN ss.Meta_LoadDateTime IS NULL
						THEN
							N'UNKNOWN'
						ELSE 
							ss.IssuerCode
						END											AS IssuerCode
					
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL
						THEN
							N'UNKNOWN'
						ELSE 
							ss.IssuerName
						END											AS IssuerName

					, ss.IssueDate
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL
						THEN
							N'UNKNOWN'
						ELSE 
							ss.IssueDesc	
						END											AS IssueDesc	

					-- De-normalise the Investees dimension into the Securities dimension 
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE 						
							COALESCE( sb.ShortName, ss.IssuerName) 		
						END											AS Investee 
					
					, lsb.BackerCode					
					
					,	CASE WHEN sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE 
							sb.ShortName									
						END											AS BackerName
					
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL
						THEN
							N'UNKNOWN'
						ELSE 
							ss.IncomeCcyISO
						END											AS IncomeCcyISO

					,ss.CurrentExDate
					,ss.AccrualDate

					,	CASE WHEN ss.Meta_LoadDateTime IS NULL
						THEN
							N'UNKNOWN'
						ELSE 
							ss.EarningsCcyISO
						END											AS EarningsCcyISO

					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.ExchangeCtry
						END											AS ExchangeCtry
					,	ss.Latest12MthEPS
					,	ss.Multiplier
					,	ss.OutstandingShares
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.PriceCcyISO
						END											AS PriceCcyISO	
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.PrimaryType
						END											AS PrimaryType
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.SecondaryType
						END											AS SecondaryType
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.TertiaryType
						END											AS TertiaryType
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.Ticker
						END											AS Ticker
					,	CASE WHEN ss.Meta_LoadDateTime IS NULL AND sb.ShortName IS NULL 
						THEN
							N'UNKNOWN'
						ELSE
							ss.VotingCode
						END											AS VotingCode

					, CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hih.Code,		
															CASE WHEN sih.Meta_LoadDateTime IS NULL 
															THEN 
																N''
															ELSE
																CONVERT( NVARCHAR(30), sih.Meta_LoadDateTime, 126 )
															END
														)
										)	AS NCHAR(10)  
						)											AS DimIndustryHierarchyID  
						
					-- , lsc.HKeyIndustryHierarchyLevel

					, hih.Code										AS IndustryHierarchyCode

					, CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hrh.Code,	
															CASE WHEN srh.Meta_LoadDateTime IS NULL 
															THEN 
																N''
															ELSE
																CONVERT( NVARCHAR(30), srh.Meta_LoadDateTime, 126 )
															END
														)
										)	AS NCHAR(10)  
						)											AS DimRegionHierarchyID  
						
					, hrh.Code										AS RegionHierarchyCode

					, CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															hah.Code,														
															CASE WHEN sah.Meta_LoadDateTime IS NULL 
															THEN 
																N''
															ELSE	
																CONVERT( NVARCHAR(30), sah.Meta_LoadDateTime, 126 )
															END
														)
										)	AS NCHAR(10)  
						)											AS DimAssetHierarchyID  
						
					, hah.Code										AS AssetHierarchyCode
					
	FROM			dv.HubSecurities	hs
		
	LEFT JOIN		dv.SatSecurities	ss
	ON				hs.HKeySecurity						=	ss.HKeySecurity
	--AND				@AsOfDateTime						<=	ss.Meta_LoadEndDateTime
	AND				ss.Meta_LoadEndDateTime				=
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	dv.[SatSecurities]
							WHERE	HKeySecurity				=				ss.HKeySecurity				
							AND		@AsOfDateTime				BETWEEN			Meta_LoadDateTime	
																AND				Meta_LoadEndDateTime
						)
				
	--	Link securities to their repsective Industry, Region & Asset Hierarchy Nodes
	LEFT JOIN		dv.LinkSecurityClassification	lsc
	ON				hs.HKeySecurity						=	lsc.HKeySecurity
			
	-- Industry Hierarchy Node Link ( Data Source = Pacer IMS ) 
	LEFT JOIN		dv.[HubIndustryHierarchyLevel]	hih
	ON				lsc.HKeyIndustryHierarchyLevel		=	hih.HKeyIndustryHierarchyLevel	
		
	LEFT JOIN		dv.[SatIndustryHierarchyLevel]	sih
	ON				hih.HKeyIndustryHierarchyLevel		=	sih.HKeyIndustryHierarchyLevel	
	AND				sih.Meta_LoadEndDateTime	=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.[SatIndustryHierarchyLevel]
						WHERE	HKeyIndustryHierarchyLevel		=				sih.HKeyIndustryHierarchyLevel				
						AND		@AsOfDateTime					BETWEEN			Meta_LoadDateTime	
																AND				Meta_LoadEndDateTime
					)	

	-- Region Hierarchy Node Link ( Data Source = Pacer IMS ) 		
	LEFT JOIN		dv.[HubRegionHierarchyLevel]	hrh
	ON				lsc.HKeyRegionHierarchyLevel		=	hrh.HKeyRegionHierarchyLevel	
		
	LEFT JOIN		dv.[SatRegionHierarchyLevel]	srh
	ON				hrh.HKeyRegionHierarchyLevel		=	srh.HKeyRegionHierarchyLevel	
	AND				srh.Meta_LoadEndDateTime	=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.[SatRegionHierarchyLevel]
						WHERE	HKeyRegionHierarchyLevel		=				srh.HKeyRegionHierarchyLevel				
						AND		@AsOfDateTime					BETWEEN			Meta_LoadDateTime	
																AND				Meta_LoadEndDateTime
					)	

	-- Asset Hierarchy Node Link ( Data Source = Pacer IMS ) 
	LEFT JOIN		dv.[HubAssetHierarchyLevel]		hah
	ON				lsc.HKeyAssetHierarchyLevel			=	hah.HKeyAssetHierarchyLevel	
		
	LEFT JOIN		dv.[SatAssetHierarchyLevel]		sah
	ON				hah.HKeyAssetHierarchyLevel			=	sah.HKeyAssetHierarchyLevel
	AND				sah.Meta_LoadEndDateTime	=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.[SatAssetHierarchyLevel]
						WHERE	HKeyAssetHierarchyLevel			=				sah.HKeyAssetHierarchyLevel				
						AND		@AsOfDateTime					BETWEEN			Meta_LoadDateTime	
																AND				Meta_LoadEndDateTime
					)	

	-- Tables to determine Investee ( Data Source = Pacer IMS ) 
	LEFT JOIN		dv.LinkSecurityBackers			lsb
	ON				hs.HKeySecurity					=	lsb.HKeySecurity		
		
	LEFT JOIN		dv.HubBackers					hb
	ON				lsb.HKeyBacker					=	hb.HKeyBacker

	LEFT JOIN		dv.SatBackers					sb
	ON				hb.HKeyBacker					=	sb.HKeyBacker		
	AND				sb.Meta_LoadEndDateTime	=	
					(
						SELECT	MAX( Meta_LoadEndDateTime )
						FROM	dv.SatBackers
						WHERE	HKeyBacker					=				sb.HKeyBacker				
						AND		@AsOfDateTime				BETWEEN			Meta_LoadDateTime	
															AND				Meta_LoadEndDateTime
					)	
;

