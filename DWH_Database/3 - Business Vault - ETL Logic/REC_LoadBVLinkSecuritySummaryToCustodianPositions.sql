
CREATE PROCEDURE [etl].[LoadBVLinkSecuritySummaryToCustodianPosition]	(													
																			@ReportDate		DATE,
																			@LoadDateTime	DATETIME2,
																			@AsOfDateTime	DATETIME2,
																			@ETLProcessID	INT			=	-1													
																		)
WITH EXECUTE AS OWNER 
AS
	
	--INSERT INTO [bv].[LinkSecuritySummaryToCustodianPosition]
	--(
	--	[HKeySecuritySummaryToCustodianPosition]	,		
	--	[Meta_LoadDateTime]							,
	--	[Meta_RecordSource]							,
	--	[Meta_ETLProcessID]							,				--	FK to ID of import batch 		
	--	[HKeySecuritySummary]						,
	--	[HKeyCustodianPosition]						,		
	--	[ReportDate]								,				--	UIX				
	--	[AsOfDateTime]								,				--	UIX		
	--	[SecID]										,				--	BK - UIX			
	--	[Custodian_SecID]							,				--	BK - UIX			
	--	[MappedLeadSystemSecurityCode]				,				--	UIX
	--	[MappedPartnerSystemSecurityCode]							--	UIX
	--)
	
	---- Records on Internal system side (e.g. Pacer)
	--SELECT		HASHBYTES	( N'SHA1', CONCAT_WS	( N'|', 
	--													CONVERT( NVARCHAR(30), @LoadDateTime, 126 ), 													
	--													CONVERT( NVARCHAR(30), @ReportDate, 126 ), 													
	--													CONVERT( NVARCHAR(30), @AsOfDateTime, 126 ), 													
	--													lss.SecID, 
	--													COALESCE( lcp.ISIN, N'' )
	--												))												AS [HKeySecuritySummaryToCustodianPosition],
	--			@LoadDateTime																		AS LoadDateTime, 				
	--			N'BR003b|v.Alpha|Holdings Reconciliation at grain: Security'						AS RecordSource, 
	--			@ETLProcessID																		AS ETLProcessID,
	--			lss.HKeySecuritySummary,
	--			COALESCE( lcp.HKeyCustodianPosition, 0x1111111111111111111111111111111111111111 )	AS HKeyCustodianPosition,
	--			@ReportDate																			AS ReportDate, 
	--			@AsOfDateTime																		AS AsOfDateTime, 
	--			lss.SecID, 				
	--			CASE	WHEN	( COALESCE( lcp.ISIN, N'' ) = N'' )
	--					THEN	N'Unknown' 								
	--					ELSE	lcp.ISIN	END														AS [Custodian_SecID],						

	--			CASE	WHEN	( COALESCE( rsm.LeadSystemSecurityCode, N'') = N'' )
	--					THEN	N'Not Mapped' 								
	--					ELSE	rsm.LeadSystemSecurityCode	END										AS MappedLeadSystemSecurityCode,

	--			CASE	WHEN	( COALESCE( rsm.PartnerSystemSecurityCode001, N'') = N'' )
	--					THEN	N'Not Mapped' 								
	--					ELSE	rsm.PartnerSystemSecurityCode001	END								AS MappedPartnerSystemSecurityCode
		
	--FROM		bv.LinkSecuritySummary				lss

	--INNER JOIN  bv.SatSecurityValuations			ssv
	--ON			lss.HKeySecuritySummary				=	ssv.HKeySecuritySummary				
	
	--LEFT JOIN	ref.RefSecurityIdentifierMappings	rsm
	--ON			rsm.LeadSystemSecurityCode			=	lss.SecID
		
	--LEFT JOIN	dv.LinkCustodianPositions			lcp
	--ON			rsm.PartnerSystemSecurityCode001	=	lcp.ISIN
	--AND			lss.ReportDate						=	lcp.ReportDate
	--AND			lcp.Meta_LoadDateTime				=	(
	--														SELECT	MAX( Meta_LoadDateTime ) 
	--														FROM	dv.LinkCustodianPositions			
	--														WHERE	ISIN		=	rsm.PartnerSystemSecurityCode001
	--														AND		ReportDate	=	lss.ReportDate
	--													)							-- Select last position received from Custodian on Report Date

	--WHERE		lss.Meta_LoadDateTime				=	( SELECT MAX( Meta_LoadDateTime ) FROM bv.LinkSecuritySummary WHERE ReportDate = @ReportDate )
	---- AND			lss.AsOfDateTime					=	@AsOfDateTime	
	--AND			lss.ReportDate						=	@ReportDate
		

	--UNION ALL 


	---- Records on Custodian side where we don't have a record from the Internal system ( i.e. a holdings break )

	--SELECT		HASHBYTES	( N'SHA1', CONCAT_WS	( N'|', 
	--													CONVERT( NVARCHAR(30), @LoadDateTime, 126 ), 													
	--													CONVERT( NVARCHAR(30), @ReportDate, 126 ), 													
	--													CONVERT( NVARCHAR(30), @AsOfDateTime, 126 ), 													
	--													COALESCE( lss.SecID, '' ), 
	--													lcp.ISIN
	--												))												AS [HKeySecuritySummaryToCustodianPosition],
	--			@LoadDateTime, 				
	--			N'BR003b|v.Alpha|Holdings Reconciliation at grain: Security'						AS RecordSource, 
	--			@ETLProcessID,				
	--			COALESCE( lss.HKeySecuritySummary, 0x1111111111111111111111111111111111111111)		AS HKeySecuritySummary,
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
	--AND			lcp.Meta_LoadDateTime				=	(	SELECT	MAX( Meta_LoadDateTime ) 
	--														FROM	dv.LinkCustodianPositions 
	--														WHERE	ReportDate = @ReportDate ) 
	--AND			lss.SecID IS NULL 
	--;

RETURN @@ROWCOUNT

