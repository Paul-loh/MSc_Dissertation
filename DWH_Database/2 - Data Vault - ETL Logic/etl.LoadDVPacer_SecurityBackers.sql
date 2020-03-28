CREATE PROCEDURE [etl].[PACER_LoadDVSecurityBackers]	(
															@LoadDateTime	DATETIME2
														)
WITH EXECUTE AS OWNER 
AS

--	Load Link
	
	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[LinkSecurityBackers] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[LinkSecurityBackers] l	

	INNER JOIN	stg.PACER_SecurityBackers t
	ON			l.[HKeySecurityBacker]			=	t.Out_HKeyLinkSecurityBackers	
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;


	INSERT INTO		[dv].[LinkSecurityBackers] 
			(
				[HKeySecurityBacker]		,			-- Hash of Security Code + Backer Code
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
				
				[HKeySecurity]				,			--	UIX	-- Hash of Currency Code
				[HKeyBacker]				,			--	UIX	
				[SecID]						,			--	UIX	
				[BackerCode]							--	UIX	
			)

	SELECT DISTINCT
				t.[Out_HKeyLinkSecurityBackers]	,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,

				t.[Out_HKeySecurity]		,
				t.[Out_HKeyBacker]			,
				t.[Out_SECID]				,
				t.[Out_ATTRIBUTE_VALUE]				

	FROM		stg.PACER_SecurityBackers t
	WHERE		t.Meta_LoadDateTime		=		@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[LinkSecurityBackers] l
			WHERE	l.[HKeySecurityBacker]			=	t.[Out_HKeyLinkSecurityBackers]
		) ;



--	Load Satellite

	-- Insert new payloads  
	INSERT INTO [dv].[SatSecurityBackersEffectivity] 
		(
			[HKeySecurityBacker]	,	
			[Meta_LoadDateTime]		,
			[Meta_LoadEndDateTime]	,
			[Meta_RecordSource]		,
			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
			[EffectiveFromDateTime]	,					
			[EffectiveToDateTime]
		)

	SELECT DISTINCT
			t.[Out_HKeyLinkSecurityBackers], 
			t.Meta_LoadDateTime, 
			CAST( N'9999-12-31' AS DATETIME2 ),		
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,
			CAST( N'1900-01-01' AS DATETIME2 ),		
			CAST( N'9999-12-31' AS DATETIME2 )		
			
	FROM	stg.PACER_SecurityBackers t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatSecurityBackersEffectivity] s
			WHERE	s.[HKeySecurityBacker]		=	t.[Out_HKeyLinkSecurityBackers]			
		) ;
	
	
-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime

	UPDATE	[dv].[SatSecurityBackersEffectivity] 
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.[SatSecurityBackersEffectivity] z
												WHERE	z.[HKeySecurityBacker]		=	s.[HKeySecurityBacker]
												AND		z.Meta_LoadDateTime			>	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatSecurityBackersEffectivity] s
	WHERE	
	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_SecurityBackers t
					WHERE	t.Meta_LoadDateTime					=	@LoadDateTime		
					AND		t.[Out_HKeyLinkSecurityBackers]		=	s.[HKeySecurityBacker]
				)
	;

GO



