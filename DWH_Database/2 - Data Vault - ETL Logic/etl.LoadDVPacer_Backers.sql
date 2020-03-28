CREATE PROCEDURE [etl].[PACER_LoadDVBackers]	(
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS

--	Load Hub
	
		-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
		-- (2 values generating same Hash), which we would want to know about. 
		-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubBackers] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubBackers] h

	INNER JOIN	stg.PACER_Backers t
	ON			h.HKeyBacker			=	t.Out_HKeyHubBackers		
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubBackers]
			(
				[HKeyBacker]				,			-- Hash of Backer Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[BackerCode]							--	UIX	
			)

	SELECT 
				t.[Out_HKeyHubBackers]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_BackerCodeBK]

	FROM		stg.PACER_Backers t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubBackers] h
			WHERE	h.HKeyBacker		=	t.[Out_HKeyHubBackers]
		) ;
		


--	Load Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatBackers] 
		(
					HKeyBacker, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,
					[ShortName],
					[HDiffBackerPL]		
		)

	SELECT
					t.Out_HKeyHubBackers, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2),	
					t.Meta_RecordSource, 
					t.Meta_ETLProcessID,				
					t.Out_ShortName, 
					t.Out_HDiffBackerPL		
			
	FROM	stg.PACER_Backers  t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatBackers] s
			WHERE	s.HKeyBacker			=	t.Out_HKeyHubBackers
			AND		s.HDiffBackerPL		=	t.Out_HDiffBackerPL
		) ;
	
	   	 

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatBackers] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatBackers] z
													WHERE	z.HKeyBacker			=	s.HKeyBacker
													AND		z.Meta_LoadDateTime		>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatBackers] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_Backers t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubBackers		=	s.HKeyBacker
				)
	;

GO


