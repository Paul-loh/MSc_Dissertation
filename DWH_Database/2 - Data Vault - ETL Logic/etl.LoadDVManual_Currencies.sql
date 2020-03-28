CREATE PROC [etl].[MANUAL_LoadDVCurrencies]  (
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS

--	Load Hub
	
		-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
		-- (2 values generating same Hash), which we would want to know about. 
		-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubCurrencies] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubCurrencies] h

	INNER JOIN	stg.MANUAL_Currencies t
	ON			h.HKeyCurrency			=	t.Out_HKeyHubCurrencies		
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubCurrencies]
			(
				[HKeyCurrency]				,			-- Hash of Security Code + Price Date + Price Type + Price Source
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[CurrencyCode]								--	UIX	
			)
	SELECT 
				t.[Out_HKeyHubCurrencies]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_CcyCodeBK]

	FROM		stg.MANUAL_Currencies t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubCurrencies] h
			WHERE	h.HKeyCurrency		=	t.[Out_HKeyHubCurrencies]
		) ;
		


--	Load Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatCurrencies] 
		(
					HKeyCurrency, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,
					CurrencyName, 
					SSCCode, 
					CurrencyGroup, 
					HDiffCurrencyPL		
		)

	SELECT
					t.Out_HKeyHubCurrencies, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2),	
					t.Meta_RecordSource, 
					t.Meta_ETLProcessID,				
					t.Out_CurrencyName, 
					t.Out_SSCCode, 
					t.Out_Group, 
					t.Out_HDiffCurrencyPL		
			
	FROM	stg.MANUAL_Currencies  t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatCurrencies] s
			WHERE	s.HKeyCurrency			=	t.Out_HKeyHubCurrencies
			AND		s.HDiffCurrencyPL		=	t.Out_HDiffCurrencyPL
		) ;
	
	   	 

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatCurrencies] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.SatCurrencies z
													WHERE	z.HKeyCurrency		=	s.HKeyCurrency
													AND		z.Meta_LoadDateTime >	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatCurrencies] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.MANUAL_Currencies t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubCurrencies		=	s.HKeyCurrency
				)
	;

GO


