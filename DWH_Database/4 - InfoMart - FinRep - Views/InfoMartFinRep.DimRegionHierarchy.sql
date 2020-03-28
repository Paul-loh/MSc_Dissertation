CREATE VIEW  [InfoMartFinRep].[DimRegionHierarchy]
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20191115
	--	Description:		Dimension Table of Pacer Region sector hierarchy 
	--						in Finrep (Financial Reporting) Information Mart.
	--			
	--						Grain: 
	--								Region Hiearchy Code 
	--		

	WITH CTE_SECTOR_CATEGORIES AS
	(
		/*  Anchor rows	- i.e. with no parent	*/
		SELECT		
					-- CAST( l.RegionChildCode AS NCHAR(10) )		AS DimRegionHierarchyID  
					CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															h.Code,														
															CONVERT( NVARCHAR(30), s.Meta_LoadDateTime, 126 )
														)
										)	AS NCHAR(10)  
						)											AS DimRegionHierarchyID  
						
					, l.HKeyRegionChildCode							AS RegionHierarchyKey
					, l.RegionChildCode								AS RegionHierarchyCode
					, s.SecurityClass								AS RegionLvl1 
					, CAST('' AS NVARCHAR(100))						AS RegionLvl2 
					, CAST('' AS NVARCHAR(100))						AS RegionLvl3 
					, CAST('' AS NVARCHAR(100))						AS RegionLvl4
					, 1 AS Lvl				
		
		FROM		dv.[LinkRegionHierarchy]		l		

		INNER JOIN	dv.[HubRegionHierarchyLevel]	h
		ON			l.HKeyRegionChildCode			=	h.HKeyRegionHierarchyLevel	
		
		INNER JOIN	dv.[SatRegionHierarchyLevel]	s
		ON			h.HKeyRegionHierarchyLevel		=	s.HKeyRegionHierarchyLevel
		AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'

		WHERE		l.HKeyRegionParentCode			=	0x1111111111111111111111111111111111111111	-- Top Level Node
				
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
						)											AS DimRegionHierarchyID  
						
					, l.HKeyRegionChildCode							AS RegionHierarchyKey
					, l.RegionChildCode								AS RegionHierarchyCode
					, r.RegionLvl1, 
					CASE WHEN r.Lvl = 1
					THEN s.SecurityClass
					ELSE r.RegionLvl2 
					END												AS RegionLvl2,
					CASE WHEN r.Lvl = 2 
					THEN s.SecurityClass
					ELSE r.RegionLvl3
					END												AS RegionLvl3,				
					CASE WHEN r.Lvl = 3
					THEN s.SecurityClass
					ELSE r.RegionLvl4
					END												AS RegionLvl4,			
					r.Lvl + 1										AS Lvl

		FROM		CTE_SECTOR_CATEGORIES			r	
		
		INNER JOIN	dv.[LinkRegionHierarchy]		l			
		ON			r.RegionHierarchyKey			=	l.HKeyRegionParentCode

		INNER JOIN	dv.[HubRegionHierarchyLevel]	h
		ON			l.HKeyRegionChildCode			=	h.HKeyRegionHierarchyLevel	

		INNER JOIN	dv.[SatRegionHierarchyLevel]	s
		ON			h.HKeyRegionHierarchyLevel		=	s.HKeyRegionHierarchyLevel
		AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'

		WHERE		r.Lvl			<	4		
	)	
	
	--SELECT DISTINCT		* 
	--FROM				CTE_SECTOR_CATEGORIES			
	--;

	SELECT DISTINCT		DimRegionHierarchyID,		
						RegionHierarchyCode,
						RegionLvl1,
						RegionLvl2,
						RegionLvl3,
						RegionLvl4,
						Lvl
	 
	FROM				CTE_SECTOR_CATEGORIES			
	;
	


