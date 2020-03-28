CREATE PROCEDURE [etl].[PACER_LoadDVFXRates](
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS

--	Load Link
	
	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.


	UPDATE		[dv].[LinkFXRates] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[LinkFXRates] l	

	INNER JOIN	stg.PACER_FXRates t
	ON			l.HKeyFXRate			=	t.Out_HKeyFXRates		
	--AND			l.HKeyCurrency			=	t.Out_HKeyCurrencyCode
	--AND			l.RateDate				=	t.Out_RateDate
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;


	INSERT INTO		[dv].[LinkFXRates] 
			(
				[HKeyFXRate]				,			-- Hash of Security Code + Price Date + Price Type + Price Source
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
				
				[HKeyCurrency]				,			--	UIX	-- Hash of Currency Code
				[CurrencyCode]				,			--	UIX	
				[RateDate]								--	UIX	
			)
	SELECT 
				t.[Out_HKeyFXRates]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,

				t.[Out_HKeyCurrencyCode]	,
				t.[Out_CurrencyCode]		,
				t.[Out_RateDate]				

	FROM		stg.PACER_FXRates t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[LinkFXRates] l
			WHERE	l.HKeyFXRate			=	t.Out_HKeyFXRates
		) ;



--	Load Satellite

	-- Insert new payloads  
	INSERT INTO [dv].[SatFXRates] 
		(
			[HKeyFXRate]			,	
			[Meta_LoadDateTime]		,
			[Meta_LoadEndDateTime]	,
			[Meta_RecordSource]		,
			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
			[HDiffFXRatePL]			,
					
			[SSCCcyCode]			,
			[RateToGBP]			
		)

	SELECT
			t.Out_HKeyFXRates, 
			t.Meta_LoadDateTime, 
			CAST( N'9999-12-31' AS DATETIME2 ),		
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,
			t.Out_HDiffFXRatesPL,

			Out_SSCCcyCode,
			Out_RateToGBP			
			
	FROM	stg.PACER_FXRates t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatFXRates] s
			WHERE	s.HKeyFXRate		=	t.Out_HKeyFXRates
			AND		s.HDiffFXRatePL		=	t.Out_HDiffFXRatesPL
		) ;
	
	
-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime

	UPDATE	[dv].[SatFXRates] 
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.[SatFXRates] z
												WHERE	z.HKeyFXRate			=	s.HKeyFXRate
												AND		z.Meta_LoadDateTime		>	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatFXRates] s
	WHERE	-- s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_FXRates t
					WHERE	t.Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyFXRates			=	s.HKeyFXRate
				)
	;

GO



