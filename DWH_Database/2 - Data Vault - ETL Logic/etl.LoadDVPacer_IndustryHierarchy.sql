CREATE PROCEDURE [etl].[PACER_LoadDVIndustryHierarchyLevels]	(
																	@LoadDateTime	DATETIME2
																)
WITH EXECUTE AS OWNER 
AS

	/*
			Author:			Paul Loh
			Date:			2019-12-12
			Description:	Load Pacer Industry Hierarchy master data to Data Vault layer
			Changes:		
	*/	

----	Load Link
	
--	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
--	-- (2 values generating same Hash), which we would want to know about. 
--	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[LinkIndustryHierarchy] 
		SET		Meta_LastSeenDateTime			=	t.Meta_LoadDateTime
	FROM		[dv].[LinkIndustryHierarchy]	l

	INNER JOIN	stg.PACER_IndustryHierarchy t
	ON			l.HKeyIndustryParentCode		=	t.Out_HKeyIndustryParentCode
	AND			l.HKeyIndustryChildCode			=	t.Out_HKeyHubCode

	WHERE		t.Meta_LoadDateTime				=	@LoadDateTime ;
	  	 

	INSERT INTO [dv].[LinkIndustryHierarchy]
		(
			[HKeyLinkIndustryHierarchy]
			,[Meta_LoadDateTime]
			,[Meta_LastSeenDateTime]
			,[Meta_RecordSource]
			,[Meta_ETLProcessID]
			,[HKeyIndustryParentCode]
			,[HKeyIndustryChildCode]
			,[IndustryParentCode]
			,[IndustryChildCode]
		)
	
	SELECT 					
			t.Out_HKeyLinkIndustryHierarchy								AS [HKeyLinkIndustryHierarchy]					
			,t.Meta_LoadDateTime
			,t.Meta_LoadDateTime
			,t.Meta_RecordSource
			,t.Meta_ETLProcessID
			,t.Out_HKeyIndustryParentCode								AS HKeyIndustryParentCode
			,t.Out_HKeyHubCode											AS HKeyIndustryChildCode				
			,t.Out_ParentCode											AS [IndustryParentCode]
			,t.Out_Code													AS [IndustryChildCode]	
	FROM	stg.PACER_IndustryHierarchy t
	WHERE		t.Meta_LoadDateTime			=	@LoadDateTime 
	AND	NOT EXISTS 
			(
				SELECT		*	
				FROM		[dv].[LinkIndustryHierarchy]	h
				WHERE		h.HKeyIndustryParentCode	=	t.Out_HKeyIndustryParentCode
				AND			h.HKeyIndustryChildCode		=	t.Out_HKeyHubCode				
			) 
	;
	
			   					 

--	Load Hub
	
		-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
		-- (2 values generating same Hash), which we would want to know about. 
		-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubIndustryHierarchyLevel] 
		SET		Meta_LastSeenDateTime			=	t.Meta_LoadDateTime
	FROM		[dv].[HubIndustryHierarchyLevel] h

	INNER JOIN	stg.PACER_IndustryHierarchy t
	ON			h.HKeyIndustryHierarchyLevel	=	t.Out_HKeyHubCode
	
	WHERE		t.Meta_LoadDateTime				=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubIndustryHierarchyLevel]
			(
				[HKeyIndustryHierarchyLevel]	,			--	Hash of hierarchy level 
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

	FROM		stg.PACER_IndustryHierarchy t
	WHERE		t.Meta_LoadDateTime						=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubIndustryHierarchyLevel] h
			WHERE	h.[HKeyIndustryHierarchyLevel]		=	t.[Out_HKeyHubCode]
		) ;
		
		

--	Load Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatIndustryHierarchyLevel] 
		(
					HKeyIndustryHierarchyLevel, 
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
			
	FROM	stg.PACER_IndustryHierarchy  t
	WHERE	t.Meta_LoadDateTime		=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatIndustryHierarchyLevel] s
			WHERE	s.HKeyIndustryHierarchyLevel			=	t.Out_HKeyHubCode
			AND		s.HDiffHierarchyLevelPL					=	t.Out_HDiffHierarchyLevelPL
		) ;
	
	

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatIndustryHierarchyLevel] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.SatIndustryHierarchyLevel z
													WHERE	z.HKeyIndustryHierarchyLevel		=	s.HKeyIndustryHierarchyLevel
													AND		z.Meta_LoadDateTime					>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatIndustryHierarchyLevel] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_IndustryHierarchy t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubCode			=	s.HKeyIndustryHierarchyLevel
				)
	;


GO


