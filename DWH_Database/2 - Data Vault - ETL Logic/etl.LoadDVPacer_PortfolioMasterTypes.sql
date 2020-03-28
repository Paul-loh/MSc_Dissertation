CREATE PROCEDURE [etl].[PACER_LoadDVPortfolioMasterTypes]	(
																@LoadDateTime	DATETIME2
															)
WITH EXECUTE AS OWNER 
AS

--	Load Hub
	
	-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.
	
	UPDATE		[dv].[HubPortfolios] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubPortfolios] h

	INNER JOIN	stg.PACER_MasterPortfolios  t
	ON			h.HKeyPortfolio			=	t.Out_HKeyHubPortfolio
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;


	
	INSERT INTO		[dv].[HubPortfolios]
			(
				[HKeyPortfolio]				,			-- Hash of Portfolio Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[PortfCode]								--	UIX	
			)
	SELECT 
				t.[Out_HKeyHubPortfolio]	,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.Out_PortfCode

	FROM		stg.PACER_MasterPortfolios t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubPortfolios] h
			WHERE	h.[HKeyPortfolio]		=	t.[Out_HKeyHubPortfolio]
		) ;



--	Load Satellite

	-- Insert new pay loads  
	INSERT INTO [dv].[SatPortfolioMasterType] 
		(
					HKeyPortfolio, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,
					
					[HDiffPortfolioMasterTypePL],
					
					[AsFromDate],
					[MasterType]
		)

	SELECT
					t.Out_HKeyHubPortfolio, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2 ),		
					t.Meta_RecordSource				,
					t.Meta_ETLProcessID				,
					
					t.Out_HDiffMasterPortfolioPL	,

					t.[Out_AsFromDate]				,
					t.[Out_MasterType]	

	FROM	stg.PACER_MasterPortfolios  t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatPortfolioMasterType] s
			WHERE	s.[HKeyPortfolio]					=	t.[Out_HKeyHubPortfolio]
			AND		s.[HDiffPortfolioMasterTypePL]		=	t.[Out_HDiffMasterPortfolioPL]
		) ;



-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatPortfolioMasterType] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatPortfolioMasterType] z
													WHERE	z.HKeyPortfolio		=	s.HKeyPortfolio
													AND		z.Meta_LoadDateTime >	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatPortfolioMasterType] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_MasterPortfolios t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubPortfolio		=	s.HKeyPortfolio
				)
	;

GO
