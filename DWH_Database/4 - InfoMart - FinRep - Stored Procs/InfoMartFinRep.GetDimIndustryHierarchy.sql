CREATE PROCEDURE [InfoMartFinRep].[GetDimIndustryHierarchy]		@AsOfDateTime	DATETIME2	=	NULL														
WITH EXECUTE AS OWNER
AS

--	Author:				Paul Loh	
--	Creation Date:		20200129
--	Description:		Dimension Table of Pacer Industry sector hierarchy 
--						in Finrep (Financial Reporting) Information Mart.
--			
--
--						Parameters:
--								@AsOfDateTime	:	Date\time records are retrieved for.
--													Used to find records where parameter is <= Meta_LoadEndDateTime													
--						Grain: 
--								Industry Hiearchy Code 

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;
	
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
					, s.Meta_LoadDateTime
					, s.Meta_LoadEndDateTime
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
		-- AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'
		AND			@AsOfDateTime					<=	s.Meta_LoadEndDateTime

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
					, s.Meta_LoadDateTime
					, s.Meta_LoadEndDateTime
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
		--AND			s.Meta_LoadEndDateTime			=	N'9999-12-31'
		AND			@AsOfDateTime					<=	s.Meta_LoadEndDateTime

		WHERE		r.Lvl			<	4		
	)	
	
	SELECT DISTINCT		s.DimIndustryHierarchyID,
						s.IndustryHierarchyCode,
						s.IndustryLvl1,
						s.IndustryLvl2,
						s.IndustryLvl3,
						s.IndustryLvl4,
						s.Lvl
	FROM				CTE_SECTOR_CATEGORIES s
	WHERE				Meta_LoadEndDateTime	=	
						(
							SELECT	MAX( Meta_LoadEndDateTime )
							FROM	CTE_SECTOR_CATEGORIES
							WHERE	IndustryHierarchyCode			=				s.IndustryHierarchyCode				
							AND		@AsOfDateTime					BETWEEN			Meta_LoadDateTime	
																	AND				Meta_LoadEndDateTime
						)	
	;

	--SELECT DISTINCT		* 
	--FROM				CTE_SECTOR_CATEGORIES			
	--;

