CREATE PROCEDURE [etl].[PACER_LoadDVAssetHierarchyLevels]	(
																	@LoadDateTime	DATETIME2
																)
WITH EXECUTE AS OWNER 
AS

	/*
			Author:			Paul Loh
			Date:			2019-12-12
			Description:	Load Pacer Asset Hierarchy master data to Data Vault layer
			Changes:		
	*/	
	
----	Load Link
	
--	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
--	-- (2 values generating same Hash), which we would want to know about. 
--	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[LinkAssetHierarchy] 
		SET		Meta_LastSeenDateTime			=	t.Meta_LoadDateTime
	FROM		[dv].[LinkAssetHierarchy]	l

	INNER JOIN	stg.PACER_AssetHierarchy t
	ON			l.HKeyAssetParentCode		=	t.Out_HKeyAssetParentCode
	AND			l.HKeyAssetChildCode			=	t.Out_HKeyHubCode

	WHERE		t.Meta_LoadDateTime				=	@LoadDateTime ;
	  	 

	INSERT INTO [dv].[LinkAssetHierarchy]
		(
			[HKeyLinkAssetHierarchy]
			,[Meta_LoadDateTime]
			,[Meta_LastSeenDateTime]
			,[Meta_RecordSource]
			,[Meta_ETLProcessID]
			,[HKeyAssetParentCode]
			,[HKeyAssetChildCode]
			,[AssetParentCode]
			,[AssetChildCode]
		)
	
	SELECT 					
			t.Out_HKeyLinkAssetHierarchy								AS [HKeyLinkAssetHierarchy]					
			,t.Meta_LoadDateTime
			,t.Meta_LoadDateTime
			,t.Meta_RecordSource
			,t.Meta_ETLProcessID
			,t.Out_HKeyAssetParentCode								AS HKeyAssetParentCode
			,t.Out_HKeyHubCode											AS HKeyAssetChildCode				
			,t.Out_ParentCode											AS [AssetParentCode]
			,t.Out_Code													AS [AssetChildCode]	
	FROM	stg.PACER_AssetHierarchy t
	WHERE		t.Meta_LoadDateTime			=	@LoadDateTime 
	AND	NOT EXISTS 
			(
				SELECT		*	
				FROM		[dv].[LinkAssetHierarchy]	h
				WHERE		h.HKeyAssetParentCode	=	t.Out_HKeyAssetParentCode
				AND			h.HKeyAssetChildCode		=	t.Out_HKeyHubCode				
			) 
	;
	
			   					 

--	Load Hub
	
		-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
		-- (2 values generating same Hash), which we would want to know about. 
		-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubAssetHierarchyLevel] 
		SET		Meta_LastSeenDateTime			=	t.Meta_LoadDateTime
	FROM		[dv].[HubAssetHierarchyLevel] h

	INNER JOIN	stg.PACER_AssetHierarchy t
	ON			h.HKeyAssetHierarchyLevel	=	t.Out_HKeyHubCode
	
	WHERE		t.Meta_LoadDateTime				=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubAssetHierarchyLevel]
			(
				[HKeyAssetHierarchyLevel]	,			--	Hash of hierarchy level 
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

	FROM		stg.PACER_AssetHierarchy t
	WHERE		t.Meta_LoadDateTime						=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubAssetHierarchyLevel] h
			WHERE	h.[HKeyAssetHierarchyLevel]		=	t.[Out_HKeyHubCode]
		) ;
		
		

--	Load Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatAssetHierarchyLevel] 
		(
					HKeyAssetHierarchyLevel, 
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
			
	FROM	stg.PACER_AssetHierarchy  t
	WHERE	t.Meta_LoadDateTime		=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatAssetHierarchyLevel] s
			WHERE	s.HKeyAssetHierarchyLevel			=	t.Out_HKeyHubCode
			AND		s.HDiffHierarchyLevelPL					=	t.Out_HDiffHierarchyLevelPL
		) ;
	
	

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatAssetHierarchyLevel] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.SatAssetHierarchyLevel z
													WHERE	z.HKeyAssetHierarchyLevel		=	s.HKeyAssetHierarchyLevel
													AND		z.Meta_LoadDateTime					>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatAssetHierarchyLevel] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_AssetHierarchy t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubCode			=	s.HKeyAssetHierarchyLevel
				)
	;


GO


