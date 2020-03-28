CREATE PROCEDURE [InfoMartFinRep].[GetDimAssetHierarchy]	@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200129
--	Description:		Dimension Table of Pacer Asset hierarchy 
--						in Finrep (Financial Reporting) Information Mart.
--			
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where parameter is <= Meta_LoadEndDateTime													
--						Grain: 
--								Asset Hiearchy Code 

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;
		
	WITH CTE_SECTOR_CATEGORIES AS
	(
		/*  Anchor rows	- i.e. with no parent	*/
		SELECT		CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															h.Code,														
															CONVERT( NVARCHAR(30), s.Meta_LoadDateTime, 126 )
														)
										)	AS NCHAR(10)  
						)											AS DimAssetHierarchyID  
						
					, l.HKeyAssetChildCode							AS AssetHierarchyKey
					, l.AssetChildCode								AS AssetHierarchyCode
					, s.Meta_LoadDateTime
					, s.Meta_LoadEndDateTime
					, s.SecurityClass								AS AssetLvl1 
					, CAST('' AS NVARCHAR(100))						AS AssetLvl2 
					, CAST('' AS NVARCHAR(100))						AS AssetLvl3 
					, CAST('' AS NVARCHAR(100))						AS AssetLvl4
					, 1 AS Lvl				
		
		FROM		dv.[LinkAssetHierarchy]		l		

		INNER JOIN	dv.[HubAssetHierarchyLevel]	h
		ON			l.HKeyAssetChildCode			=	h.HKeyAssetHierarchyLevel	
		
		INNER JOIN	dv.[SatAssetHierarchyLevel]	s
		ON			h.HKeyAssetHierarchyLevel	=	s.HKeyAssetHierarchyLevel
		-- AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'
		AND			@AsOfDateTime				<=	s.Meta_LoadEndDateTime
			
		WHERE		l.HKeyAssetParentCode		=	0x1111111111111111111111111111111111111111	-- Top Level Node
				
		UNION ALL
	
		/*  Lower level rows - i.e. with a parent	*/

		SELECT		
					CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															h.Code,														
															CONVERT( NVARCHAR(30), s.Meta_LoadDateTime, 126 )
														)
										)	AS NCHAR(10)  
						)											AS DimAssetHierarchyID  
						
					, l.HKeyAssetChildCode							AS AssetHierarchyKey
					, l.AssetChildCode								AS AssetHierarchyCode
					, s.Meta_LoadDateTime
					, s.Meta_LoadEndDateTime
					, r.AssetLvl1, 
					CASE WHEN r.Lvl = 1
					THEN s.SecurityClass
					ELSE r.AssetLvl2 
					END												AS AssetLvl2,
					CASE WHEN r.Lvl = 2 
					THEN s.SecurityClass
					ELSE r.AssetLvl3
					END												AS AssetLvl3,				
					CASE WHEN r.Lvl = 3
					THEN s.SecurityClass
					ELSE r.AssetLvl4
					END												AS AssetLvl4,			
					r.Lvl + 1										AS Lvl

		FROM		CTE_SECTOR_CATEGORIES			r	
		
		INNER JOIN	dv.[LinkAssetHierarchy]		l			
		ON			r.AssetHierarchyKey				=	l.HKeyAssetParentCode

		INNER JOIN	dv.[HubAssetHierarchyLevel]	h
		ON			l.HKeyAssetChildCode			=	h.HKeyAssetHierarchyLevel	

		INNER JOIN	dv.[SatAssetHierarchyLevel]	s
		ON			h.HKeyAssetHierarchyLevel		=	s.HKeyAssetHierarchyLevel
		--AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'
		AND			@AsOfDateTime					<=	s.Meta_LoadEndDateTime

		WHERE		r.Lvl			<	4		
	)	
	
	SELECT DISTINCT		s.DimAssetHierarchyID, 
						s.AssetHierarchyCode,
						s.AssetLvl1,
						s.AssetLvl2,
						s.AssetLvl3,
						s.AssetLvl4,
						s.Lvl	 
	FROM				CTE_SECTOR_CATEGORIES s			
	WHERE				s.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	CTE_SECTOR_CATEGORIES
							WHERE	AssetHierarchyCode				=				s.AssetHierarchyCode				
							AND		@AsOfDateTime					BETWEEN			Meta_LoadDateTime	
																	AND				Meta_LoadEndDateTime
						)
;

	


