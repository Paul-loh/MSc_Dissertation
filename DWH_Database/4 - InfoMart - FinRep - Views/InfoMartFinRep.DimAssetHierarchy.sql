CREATE VIEW  [InfoMartFinRep].[DimAssetHierarchy]
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20191115
	--	Description:		Dimension Table of Pacer Asset sector hierarchy 
	--						in Finrep (Financial Reporting) Information Mart.
	--		
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where the parameter is between 
	--													Meta_LoadDateTime + Meta_LoadEndDateTime													
	--						Grain: 
	--								Asset Hiearchy Code 
	
	WITH CTE_SECTOR_CATEGORIES AS
	(
		/*  Anchor rows	- i.e. with no parent	*/
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
		AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'

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
		AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'

		WHERE		r.Lvl			<	4		
	)	
	
	SELECT DISTINCT		DimAssetHierarchyID, 
						AssetHierarchyCode,
						AssetLvl1,
						AssetLvl2,
						AssetLvl3,
						AssetLvl4,
						Lvl	 
	FROM				CTE_SECTOR_CATEGORIES			

	--SELECT DISTINCT		* 
	--FROM				CTE_SECTOR_CATEGORIES			
	;

	


