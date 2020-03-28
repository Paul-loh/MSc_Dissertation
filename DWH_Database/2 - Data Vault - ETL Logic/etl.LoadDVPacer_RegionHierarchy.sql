CREATE PROCEDURE [etl].[PACER_LoadDVRegionHierarchyLevels]	(
																	@LoadDateTime	DATETIME2
																)
WITH EXECUTE AS OWNER 
AS

	/*
			Author:			Paul Loh
			Date:			2019-12-12
			Description:	Load Pacer Region Hierarchy master data to Data Vault layer
			Changes:		
	*/	


----	Load Link
	
--	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
--	-- (2 values generating same Hash), which we would want to know about. 
--	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[LinkRegionHierarchy] 
		SET		Meta_LastSeenDateTime			=	t.Meta_LoadDateTime
	FROM		[dv].[LinkRegionHierarchy]	l

	INNER JOIN	stg.PACER_RegionHierarchy t
	ON			l.HKeyRegionParentCode		=	t.Out_HKeyRegionParentCode
	AND			l.HKeyRegionChildCode			=	t.Out_HKeyHubCode

	WHERE		t.Meta_LoadDateTime				=	@LoadDateTime ;
	  	 

	INSERT INTO [dv].[LinkRegionHierarchy]
		(
			[HKeyLinkRegionHierarchy]
			,[Meta_LoadDateTime]
			,[Meta_LastSeenDateTime]
			,[Meta_RecordSource]
			,[Meta_ETLProcessID]
			,[HKeyRegionParentCode]
			,[HKeyRegionChildCode]
			,[RegionParentCode]
			,[RegionChildCode]
		)
	
	SELECT 					
			t.Out_HKeyLinkRegionHierarchy								AS [HKeyLinkRegionHierarchy]					
			,t.Meta_LoadDateTime
			,t.Meta_LoadDateTime
			,t.Meta_RecordSource
			,t.Meta_ETLProcessID
			,t.Out_HKeyRegionParentCode								AS HKeyRegionParentCode
			,t.Out_HKeyHubCode											AS HKeyRegionChildCode				
			,t.Out_ParentCode											AS [RegionParentCode]
			,t.Out_Code													AS [RegionChildCode]	
	FROM	stg.PACER_RegionHierarchy t
	WHERE		t.Meta_LoadDateTime			=	@LoadDateTime 
	AND	NOT EXISTS 
			(
				SELECT		*	
				FROM		[dv].[LinkRegionHierarchy]	h
				WHERE		h.HKeyRegionParentCode	=	t.Out_HKeyRegionParentCode
				AND			h.HKeyRegionChildCode		=	t.Out_HKeyHubCode				
			) 
	;
	
			   					 

--	Load Hub
	
		-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
		-- (2 values generating same Hash), which we would want to know about. 
		-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubRegionHierarchyLevel] 
		SET		Meta_LastSeenDateTime			=	t.Meta_LoadDateTime
	FROM		[dv].[HubRegionHierarchyLevel] h

	INNER JOIN	stg.PACER_RegionHierarchy t
	ON			h.HKeyRegionHierarchyLevel	=	t.Out_HKeyHubCode
	
	WHERE		t.Meta_LoadDateTime				=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubRegionHierarchyLevel]
			(
				[HKeyRegionHierarchyLevel]	,			--	Hash of hierarchy level 
				[Meta_LoadDateTime]				,
				[Meta_LastSeenDateTime]			,			--	As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]				,
				[Meta_ETLProcessID]				,			--	FK to ID of import batch audit table	?
		
				[Code]										--	UIX	
			)
	SELECT 
				t.[Out_HKeyHubCode]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_Code]

	FROM		stg.PACER_RegionHierarchy t
	WHERE		t.Meta_LoadDateTime						=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubRegionHierarchyLevel] h
			WHERE	h.[HKeyRegionHierarchyLevel]		=	t.[Out_HKeyHubCode]
		) ;
		
		

--	Load Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatRegionHierarchyLevel] 
		(
					HKeyRegionHierarchyLevel, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,
					SecurityClass, 
					HDiffHierarchyLevelPL
		)

	SELECT
					t.Out_HKeyHubCode, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2),	
					t.Meta_RecordSource, 
					t.Meta_ETLProcessID,				
					t.Out_SecurityClass, 
					t.Out_HDiffHierarchyLevelPL
			
	FROM	stg.PACER_RegionHierarchy  t
	WHERE	t.Meta_LoadDateTime		=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatRegionHierarchyLevel] s
			WHERE	s.HKeyRegionHierarchyLevel			=	t.Out_HKeyHubCode
			AND		s.HDiffHierarchyLevelPL					=	t.Out_HDiffHierarchyLevelPL
		) ;
	
	

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatRegionHierarchyLevel] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.SatRegionHierarchyLevel z
													WHERE	z.HKeyRegionHierarchyLevel		=	s.HKeyRegionHierarchyLevel
													AND		z.Meta_LoadDateTime					>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatRegionHierarchyLevel] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_RegionHierarchy t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubCode			=	s.HKeyRegionHierarchyLevel
				)
	;


GO


