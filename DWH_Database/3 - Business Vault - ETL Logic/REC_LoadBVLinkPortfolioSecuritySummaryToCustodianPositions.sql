
CREATE PROCEDURE [etl].[LoadBVLinkPortfolioSecuritySummaryToCustodianPosition]	(													
																					@ReportDate		DATE,
																					@LoadDateTime	DATETIME2,
																					@AsOfDateTime	DATETIME2,
																					@ETLProcessID	INT			=	-1													
																				)
WITH EXECUTE AS OWNER 
AS

--	Author:				Paul Loh	
--	Creation Date:		20191018
--	Description:		Exploratory Link Table to linking the calculated summary positions of lead system to
--						partner custodian position 
--
--						Note:	Difference in Grain between the 2 linked datasets
--								Lead system data is available at Portfolio \ Security grain but 
--								custodian data already aggregated at higher Security only grain.

	--INSERT INTO [bv].[LinkPortfolioSecuritySummaryToCustodianPosition]
	--(
	--	[HKeyPortfolioSecuritySummaryToCustodianPosition]	,		
	--	[Meta_LoadDateTime]									,
	--	[Meta_RecordSource]									,
	--	[Meta_ETLProcessID]									,			--	FK to ID of import batch 		
	--	[HKeyPortfolioSecuritySummary]						,
	--	[HKeyCustodianPosition]								,		
	--	[ReportDate]										,			--	UIX				
	--	[AsOfDateTime]										,			--	UIX		
	--	[PortfCode]											,			--	BK  - UIX		
	--	[SecID]												,			--	BK	- UIX			
	--	[Custodian_SecID]									,			--	BK	- UIX			
	--	[MappedLeadSystemSecurityCode]						,			--	UIX
	--	[MappedPartnerSystemSecurityCode]								--	UIX
	--)
	
	---- Records on Internal system side (e.g. Pacer)
	--SELECT		HASHBYTES	( N'SHA1', CONCAT_WS	( N'|', 
	--													CONVERT( NVARCHAR(30), @LoadDateTime, 126 ), 													
	--													CONVERT( NVARCHAR(30), @ReportDate, 126 ), 													
	--													CONVERT( NVARCHAR(30), @AsOfDateTime, 126 ), 													
	--													lps.PortfCode, 
	--													lps.SecID, 
	--													COALESCE( lcp.ISIN, N'' )
	--												))												AS [HKeyPortfolioSecuritySummaryToCustodianPosition],
	--			@LoadDateTime																		AS LoadDateTime, 				
	--			N'BR003c|v.Alpha|Holdings Reconciliation at grain: ???'								AS RecordSource, 
	--			@ETLProcessID																		AS ETLProcessID,
	--			lps.HKeyPortfolioSecuritySummary,
	--			COALESCE( lcp.HKeyCustodianPosition, 0x1111111111111111111111111111111111111111 )	AS HKeyCustodianPosition,
	--			@ReportDate																			AS ReportDate, 
	--			@AsOfDateTime																		AS AsOfDateTime, 
	--			lps.PortfCode,
	--			lps.SecID, 				
	--			CASE	WHEN	( COALESCE( lcp.ISIN, N'' ) = N'' )
	--					THEN	N'Unknown' 								
	--					ELSE	lcp.ISIN	END														AS [Custodian_SecID],						

	--			CASE	WHEN	( COALESCE( rsm.LeadSystemSecurityCode, N'') = N'' )
	--					THEN	N'Not Mapped' 								
	--					ELSE	rsm.LeadSystemSecurityCode	END										AS MappedLeadSystemSecurityCode,

	--			CASE	WHEN	( COALESCE( rsm.PartnerSystemSecurityCode001, N'') = N'' )
	--					THEN	N'Not Mapped' 								
	--					ELSE	rsm.PartnerSystemSecurityCode001	END								AS MappedPartnerSystemSecurityCode
		
	--FROM		bv.LinkPortfolioSecuritySummary			lps

	--INNER JOIN  bv.SatPortfolioSecurityValuations		psv
	--ON			lps.HKeyPortfolioSecuritySummary		=	psv.HKeyPortfolioSecuritySummary				
	
	--LEFT JOIN	ref.RefSecurityIdentifierMappings		rsm
	--ON			rsm.LeadSystemSecurityCode				=	lps.SecID
		
	--LEFT JOIN	dv.LinkCustodianPositions			lcp
	--ON			rsm.PartnerSystemSecurityCode001	=	lcp.ISIN
	--AND			lps.ReportDate						=	lcp.ReportDate
	--AND			lcp.Meta_LoadDateTime				=	(
	--														SELECT	MAX( Meta_LoadDateTime ) 
	--														FROM	dv.LinkCustodianPositions			
	--														WHERE	ISIN		=	rsm.PartnerSystemSecurityCode001
	--														AND		ReportDate	=	lps.ReportDate
	--													)							-- Select last position received from Custodian on Report Date

	--WHERE		lps.Meta_LoadDateTime				=	(	SELECT	MAX( Meta_LoadDateTime ) 
	--														FROM	bv.LinkSecuritySummary 
	--														WHERE	ReportDate = @ReportDate )
	---- AND			lss.AsOfDateTime					=	@AsOfDateTime	
	--AND			lps.ReportDate						=	@ReportDate

		
	--UNION ALL 


	--INSERT INTO [bv].[LinkPortfolioSecuritySummaryToCustodianPosition]
	--(
	--	[HKeyPortfolioSecuritySummaryToCustodianPosition]	,		
	--	[Meta_LoadDateTime]									,
	--	[Meta_RecordSource]									,
	--	[Meta_ETLProcessID]									,			--	FK to ID of import batch 		
	--	[HKeyPortfolioSecuritySummary]						,
	--	[HKeyCustodianPosition]								,		
	--	[ReportDate]										,			--	UIX				
	--	[AsOfDateTime]										,			--	UIX		
	--	[PortfCode]											,			--	BK  - UIX		
	--	[SecID]												,			--	BK	- UIX			
	--	[Custodian_SecID]									,			--	BK	- UIX			
	--	[MappedLeadSystemSecurityCode]						,			--	UIX
	--	[MappedPartnerSystemSecurityCode]								--	UIX
	--)
	

	---- Records on Custodian side where we don't have a record from the Internal system ( i.e. a holdings break )

	--SELECT		HASHBYTES	( N'SHA1', CONCAT_WS	( N'|', 
	--													CONVERT( NVARCHAR(30), @LoadDateTime, 126 ), 													
	--													CONVERT( NVARCHAR(30), @ReportDate, 126 ), 													
	--													CONVERT( NVARCHAR(30), @AsOfDateTime, 126 ), 													
	--													COALESCE( lss.SecID, '' ), 
	--													lcp.ISIN
	--												))												AS [HKeySecuritySummaryToCustodianPosition],
	--			@LoadDateTime, 				
	--			N'BR003c|v.Alpha|Holdings Reconciliation at grain: Security'						AS RecordSource, 
	--			@ETLProcessID,				
	--			--	Custodian data only available at Security grain 
	--			--	i.e. does not include portfolio so indicate this with Hash Key representing an optional value.
	--			0x1111111111111111111111111111111111111111											AS HKeyPortfolioSecuritySummary,	
	--			CASE	WHEN lss.HKeySecuritySummary IS NULL 
	--					THEN 0x1111111111111111111111111111111111111111
	--					ELSE lss.HKeySecuritySummary END											AS HKeySecuritySummary,
	--			lcp.HKeyCustodianPosition,
	--			@ReportDate																			AS ReportDate, 
	--			@AsOfDateTime																		AS AsOfDateTime,

	--			CASE	WHEN	( COALESCE( lss.SecID, N'' ) = N'' )
	--					THEN	N'Unknown' 								
	--					ELSE	lss.SecID	END														AS SecID,		

	--			lcp.ISIN,
	--			CASE	WHEN	( COALESCE( rsm.LeadSystemSecurityCode, N'') = N'' )
	--					THEN	N'Not Mapped' 								
	--					ELSE	rsm.LeadSystemSecurityCode	END										AS MappedLeadSystemSecurityCode,

	--			CASE	WHEN	( COALESCE( rsm.PartnerSystemSecurityCode001, N'') = N'' )
	--					THEN	N'Not Mapped' 								
	--					ELSE	rsm.PartnerSystemSecurityCode001	END								AS MappedPartnerSystemSecurityCode

	--FROM		dv.LinkCustodianPositions			lcp
	
	--LEFT JOIN	ref.RefSecurityIdentifierMappings	rsm
	--ON			rsm.PartnerSystemSecurityCode001	=	lcp.ISIN
		
	--LEFT JOIN	bv.LinkSecuritySummary				lss
	--ON			rsm.LeadSystemSecurityCode			=	lss.SecID

	--WHERE		lcp.ReportDate						=	@ReportDate
	--AND			lcp.Meta_LoadDateTime				=	(	
	--														SELECT	MAX( Meta_LoadDateTime ) 
	--														FROM	dv.LinkCustodianPositions 
	--														WHERE	ReportDate = @ReportDate 
	--													) 
	--AND			lss.SecID IS NULL 
	--;

RETURN @@ROWCOUNT

