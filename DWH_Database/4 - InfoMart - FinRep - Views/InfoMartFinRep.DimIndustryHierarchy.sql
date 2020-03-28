CREATE VIEW  [InfoMartFinRep].[DimIndustryHierarchy]
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20191115
	--	Description:		Dimension Table of Pacer Industry sector hierarchy 
	--						in Finrep (Financial Reporting) Information Mart.
	--			
	--						Grain: 
	--								Industry Hiearchy Code 
	--		

	WITH CTE_SECTOR_CATEGORIES AS
	(
		/*  Anchor rows	- i.e. with no parent	*/
		SELECT		
					-- CAST( l.IndustryChildCode AS NCHAR(10) )		AS DimIndustryHierarchyID  
					CAST(
							HASHBYTES	(	N'SHA1',
											CONCAT_WS	(	
															N'|',
															h.Code,														
															CONVERT( NVARCHAR(30), s.Meta_LoadDateTime, 126 )
														)
										)	AS NCHAR(10)  
						)											AS DimIndustryHierarchyID  
						
					, l.HKeyIndustryChildCode						AS IndustryHierarchyKey
					, l.IndustryChildCode							AS IndustryHierarchyCode
					, s.SecurityClass								AS IndustryLvl1 
					, CAST('' AS NVARCHAR(100))						AS IndustryLvl2 
					, CAST('' AS NVARCHAR(100))						AS IndustryLvl3 
					, CAST('' AS NVARCHAR(100))						AS IndustryLvl4
					, 1 AS Lvl				
		
		FROM		dv.[LinkIndustryHierarchy]		l		

		INNER JOIN	dv.[HubIndustryHierarchyLevel]	h
		ON			l.HKeyIndustryChildCode			=	h.HKeyIndustryHierarchyLevel	
		
		INNER JOIN	dv.[SatIndustryHierarchyLevel]	s
		ON			h.HKeyIndustryHierarchyLevel	=	s.HKeyIndustryHierarchyLevel
		AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'

		WHERE		l.HKeyIndustryParentCode		=	0x1111111111111111111111111111111111111111	-- Top Level Node
				
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
						)											AS DimIndustryHierarchyID  
						
					, l.HKeyIndustryChildCode						AS IndustryHierarchyKey
					, l.IndustryChildCode							AS IndustryHierarchyCode
					, r.IndustryLvl1, 
					CASE WHEN r.Lvl = 1
					THEN s.SecurityClass
					ELSE r.IndustryLvl2 
					END												AS IndustryLvl2,
					CASE WHEN r.Lvl = 2 
					THEN s.SecurityClass
					ELSE r.IndustryLvl3
					END												AS IndustryLvl3,				
					CASE WHEN r.Lvl = 3
					THEN s.SecurityClass
					ELSE r.IndustryLvl4
					END												AS IndustryLvl4,			
					r.Lvl + 1										AS Lvl

		FROM		CTE_SECTOR_CATEGORIES			r	
		
		INNER JOIN	dv.[LinkIndustryHierarchy]		l			
		ON			r.IndustryHierarchyKey			=	l.HKeyIndustryParentCode

		INNER JOIN	dv.[HubIndustryHierarchyLevel]	h
		ON			l.HKeyIndustryChildCode			=	h.HKeyIndustryHierarchyLevel	

		INNER JOIN	dv.[SatIndustryHierarchyLevel]	s
		ON			h.HKeyIndustryHierarchyLevel	=	s.HKeyIndustryHierarchyLevel
		AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'

		WHERE		r.Lvl			<	4		
	)	
	
	SELECT DISTINCT		DimIndustryHierarchyID,
						IndustryHierarchyCode,
						IndustryLvl1,
						IndustryLvl2,
						IndustryLvl3,
						IndustryLvl4,
						Lvl
	FROM				CTE_SECTOR_CATEGORIES			
	;

	--SELECT DISTINCT		* 
	--FROM				CTE_SECTOR_CATEGORIES			
	--;

	


