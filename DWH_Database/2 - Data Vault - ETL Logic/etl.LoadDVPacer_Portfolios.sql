CREATE PROCEDURE [etl].[PACER_LoadDVPortfolios] (
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

	INNER JOIN	stg.PACER_Portfolios t
	ON			h.HKeyPortfolio			=	t.Out_HKeyHubPortfolios		
	
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
				t.[Out_HKeyHubPortfolios]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.Out_PortfCode

	FROM		stg.PACER_Portfolios t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubPortfolios] h
			WHERE	h.[HKeyPortfolio]		=	t.[Out_HKeyHubPortfolios]
		) ;



--	Load Satellite

	-- Insert new pay loads  
	INSERT INTO [dv].[SatPortfolios] 
		(
					HKeyPortfolio, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,
					[HDiffPortfolioPL],
					[AccountExec]				,
					[AccountNumber]				,
					[PortfType]					,
					[Permissions]				,
					[InitDate]					,
					[BaseCcy]					,
					[ResidenceCtry]				,
					[ResidenceRegion]			,
					[TaxType]					,
					[ValuationDate]				,
					[BookCost]					,
					[MarketValue]				,
					[CustodianCode]				,
					[SettlementAcct]			,
					[CustAcctNumber]			,
					[ObjectiveCode]				,
					[PortfStatus]				,
					[PersysFlag]				,
					[PortfName]					,
					[Address1]					,
					[Address2]					,
					[CumulGain]					,
					[LotIndicator]								
		)

	SELECT
					t.Out_HKeyHubPortfolios, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2 ),		
					t.Meta_RecordSource			,
					t.Meta_ETLProcessID			,				
					t.Out_HDiffPortfolioPL		,
					t.[Out_AccountExec]			,
					t.[Out_AccountNumber]		,
					t.[Out_PortfType]			,
					t.[Out_Permissions]			,
					t.[Out_InitDate]			,
					t.[Out_BaseCcy]				,
					t.[Out_ResidenceCtry]		,
					t.[Out_ResidenceRegion]		,
					t.[Out_TaxType]				,
					t.[Out_ValuationDate]		,
					t.[Out_BookCost]			,
					t.[Out_MarketValue]			,
					t.[Out_CustodianCode]		,
					t.[Out_SettlementAcct]		,
					t.[Out_CustAcctNumber]		,
					t.[Out_ObjectiveCode]		,
					t.[Out_PortfStatus]			,
					t.[Out_PersysFlag]			,
					t.[Out_PortfName]			,
					t.[Out_Address1]			,
					t.[Out_Address2]			,
					t.[Out_CumulGain]			,
					t.[Out_LotIndicator]				
			
	FROM	stg.PACER_Portfolios  t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatPortfolios] s
			WHERE	s.HKeyPortfolio			=	t.Out_HKeyHubPortfolios
			AND		s.HDiffPortfolioPL		=	t.Out_HDiffPortfolioPL
		) ;



-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatPortfolios] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatPortfolios] z
													WHERE	z.HKeyPortfolio		=	s.HKeyPortfolio
													AND		z.Meta_LoadDateTime >	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatPortfolios] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_Portfolios t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubPortfolios		=	s.HKeyPortfolio
				)
	;

GO
