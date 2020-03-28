CREATE PROCEDURE [etl].[PACER_LoadDVBrokers]	(
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS

--	Load Hub
	
		-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
		-- (2 values generating same Hash), which we would want to know about. 
		-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubBrokers] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubBrokers] h

	INNER JOIN	stg.PACER_Brokers t
	ON			h.HKeyBroker			=	t.Out_HKeyHubBroker
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[HubBrokers]
			(
				[HKeyBroker]				,			-- Hash of Broker Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[BrokerCode]							--	UIX	
			)

	SELECT 
				t.[Out_HKeyHubBroker]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_BrokerCodeBK]

	FROM		stg.PACER_Brokers t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubBrokers] h
			WHERE	h.HKeyBroker		=	t.[Out_HKeyHubBroker]
		) ;
		


--	Load Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatBrokers] 
		(
					HKeyBroker, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,
					[BrokerName],
					[HDiffBrokerPL]		
		)

	SELECT
					t.Out_HKeyHubBroker, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2),	
					t.Meta_RecordSource, 
					t.Meta_ETLProcessID,				
					t.Out_BrokerName, 
					t.Out_HDiffBrokerPL		
			
	FROM	stg.PACER_Brokers  t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatBrokers] s
			WHERE	s.HKeyBroker		=	t.Out_HKeyHubBroker
			AND		s.HDiffBrokerPL		=	t.Out_HDiffBrokerPL
		) ;
	
	

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatBrokers] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatBrokers] z
													WHERE	z.HKeyBroker			=	s.HKeyBroker
													AND		z.Meta_LoadDateTime		>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatBrokers] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_Brokers t
					WHERE	Meta_LoadDateTime		=	@LoadDateTime		
					AND		t.Out_HKeyHubBroker		=	s.HKeyBroker
				)
	;

GO


