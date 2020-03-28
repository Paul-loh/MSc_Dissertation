CREATE PROCEDURE [InfoMartFinRep].[GetDimRegionHierarchy]		@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200130
--	Description:		Dimension Table of Pacer Region sector hierarchy
--						in Finrep (Financial Reporting) Information Mart.
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where the parameter is between 
--													Meta_LoadDateTime + Meta_LoadEndDateTime	
--
--						Grain: Region Hiearchy Code | Load DateTime

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;

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
					, s.Meta_LoadDateTime
					, s.Meta_LoadEndDateTime
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
		--AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'
		AND			@AsOfDateTime					<=	s.Meta_LoadEndDateTime

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
					, s.Meta_LoadDateTime
					, s.Meta_LoadEndDateTime
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
		--AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'
		AND			@AsOfDateTime					<=	s.Meta_LoadEndDateTime

		WHERE		r.Lvl			<	4		
	)	
	
	SELECT DISTINCT		s.DimRegionHierarchyID,		
						s.RegionHierarchyCode,
						s.RegionLvl1,
						s.RegionLvl2,
						s.RegionLvl3,
						s.RegionLvl4,
						s.Lvl
	 
	FROM				CTE_SECTOR_CATEGORIES s			
	WHERE				s.Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	CTE_SECTOR_CATEGORIES
							WHERE	RegionHierarchyCode				=				s.RegionHierarchyCode				
							AND		@AsOfDateTime					BETWEEN			Meta_LoadDateTime	
																	AND				Meta_LoadEndDateTime
						)
	;
	


