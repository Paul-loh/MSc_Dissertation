CREATE PROCEDURE [etl].[PACER_LoadDVValuations] (
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS

-- TBD: Load Valuation > Security > Booking Currency > Value Date Link 

--	Load Hub
	
	-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubValuations] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubValuations] h

	INNER JOIN	stg.PACER_Valuations t
	-- ON			h.HKeyCurrency			=	t.Out_HKeyHubCurrencies		
	ON			h.PORTCDBK		=	t.Out_PORTCDBK					-- UIX
	AND			h.SECIDBK		=	t.Out_SECIDBK					-- UIX
	AND			h.VALDATEBK		=	t.Out_VALDATEBK					-- UIX
	AND			h.BOKFXCBK		=	t.Out_BOKFXCBK					-- UIX

	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;  	 
   	 

	INSERT INTO		[dv].[HubValuations]
			(
				HKeyValuation, 
				Meta_LoadDateTime, 
				Meta_RecordSource, 				
				Meta_ETLProcessID,
				Meta_LastSeenDateTime,
				[PORTCDBK],
				[SECIDBK],
				[VALDATEBK],
				[BOKFXCBK]
			)
	SELECT 
				t.Out_HKeyHubValuations, 
				t.Meta_LoadDateTime, 
				t.Meta_RecordSource, 
				t.Meta_ETLProcessID,
				t.Meta_LoadDateTime,		
				t.Out_PORTCDBK,
				t.Out_SECIDBK,
				t.Out_VALDATEBK,
				t.Out_BOKFXCBK

	FROM		stg.PACER_Valuations t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubValuations] h
			WHERE	h.HKeyValuation		=	t.[Out_HKeyHubValuations]
		) ;



--	Load Satellites

	-- Insert new pay loads  
	INSERT INTO	[dv].[SatValuations] 
			(
				HKeyValuation, 
				Meta_LoadDateTime, 
				Meta_LoadEndDateTime,
				Meta_RecordSource, 
				Meta_ETLProcessID,
				[HOLDINGS],
				[COST],
				[VALUE],
				[COSTNAT],
				[VALUNAT],
				[PNAT],	   		
				[HDiffValuationPL]		
			)

	 SELECT 	
				t.Out_HKeyHubValuations, 
				t.Meta_LoadDateTime, 
				CAST(N'9999-12-31' AS DATETIME2),		
				t.Meta_RecordSource, 
				t.Meta_ETLProcessID,
				t.Out_HOLDINGS,
				t.Out_COST,
				t.Out_VALUE,
				t.Out_COSTNAT,
				t.Out_VALUNAT,
				t.Out_PNAT,	   		
				t.Out_HDiffValuationPL						

	FROM	stg.PACER_Valuations t
	WHERE	t.Meta_LoadDateTime		=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatValuations] s
			WHERE	s.HKeyValuation		=	t.Out_HKeyHubValuations
			AND		s.HDiffValuationPL	=	t.Out_HDiffValuationPL
		) ;
					
					

-- End Dating of Previous Satellite Entries 
	
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatValuations] 
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.SatValuations z
												WHERE	z.HKeyValuation		=	s.HKeyValuation		
												AND		z.Meta_LoadDateTime >	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatValuations] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_Valuations t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubValuations		=	s.HKeyValuation
				) ;

GO