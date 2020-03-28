CREATE PROC [etl].[HSBCNET_LoadDVCustodianPositions]	(
															@LoadDateTime	DATETIME2
														)
WITH EXECUTE AS OWNER 
AS

--	Load Custodian Accounts Hub

	-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubCustodianAccounts] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubCustodianAccounts] h

	INNER JOIN	stg.HSBCNET_CustodianPositions t
	ON			h.HKeyCustodianAccount	=	t.Out_HKeyHubCustodianAccount		
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;


	INSERT INTO		[dv].[HubCustodianAccounts]
			(
				[HKeyCustodianAccount]		,			-- Hash of Custodian Account Number 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_SrcSysExportDateTime]	, 
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[SecuritiesAccountNumber]								--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeyHubCustodianAccount]	,
				t.[Meta_LoadDateTime]			,
				t.[Meta_LoadDateTime]			,
				t.[Meta_SrcSysExportDateTime]	,
				t.[Meta_RecordSource]			,
				t.[Meta_ETLProcessID]			,
								
				t.[Out_SecuritiesAccountNumber]

	FROM		stg.HSBCNET_CustodianPositions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubCustodianAccounts] h
			WHERE	h.[HKeyCustodianAccount]	=	t.[Out_HKeyHubCustodianAccount]
		) ;
		
		
--	Load Custodian Accounts Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatCustodianAccounts] 
		(
					HKeyCustodianAccount, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_SrcSysExportDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,

					AccountName, 
					AccountCurrency,
					HDiffCustodianAccountPL
		)

	SELECT DISTINCT
					t.Out_HKeyHubCustodianAccount, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2),	
					t.Meta_SrcSysExportDateTime,
					t.Meta_RecordSource, 
					t.Meta_ETLProcessID,				

					t.Out_AccountName,
					t.Out_AccountCurrency,
					t.Out_HDiffCustodianAccountPL
			
	FROM	stg.HSBCNET_CustodianPositions  t
	WHERE	t.Meta_LoadDateTime		=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatCustodianAccounts] s
			WHERE	s.HKeyCustodianAccount		=	t.Out_HKeyHubCustodianAccount
			AND		s.HDiffCustodianAccountPL	=	t.Out_HDiffCustodianAccountPL
			AND		t.Meta_LoadDateTime			=	@LoadDateTime 
		) ;

		

-- End Date Previous Custodian Accounts Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatCustodianAccounts] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatCustodianAccounts] z
													WHERE	z.HKeyCustodianAccount		=	s.HKeyCustodianAccount
													AND		z.Meta_LoadDateTime			>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatCustodianAccounts] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.HSBCNET_CustodianPositions t
					WHERE	Meta_LoadDateTime				=	@LoadDateTime		
					AND		t.Out_HKeyHubCustodianAccount	=	s.HKeyCustodianAccount
				)
	;
		   	 

--	Load Custodian Securities Hub
	-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[HubCustodianSecurities] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubCustodianSecurities] h

	INNER JOIN	stg.HSBCNET_CustodianPositions t
	ON			h.HKeyCustodianSecurity	=	t.Out_HKeyHubCustodianSecurity
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;


	INSERT INTO		[dv].[HubCustodianSecurities]
			(
				[HKeyCustodianSecurity]		,			-- Hash of Custodian Account Security 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_SrcSysExportDateTime]	, 
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[ISIN]									--	UIX	
			)
	SELECT DISTINCT
				t.[Out_HKeyHubCustodianSecurity]	,
				t.[Meta_LoadDateTime]			,
				t.[Meta_LoadDateTime]			,
				t.[Meta_SrcSysExportDateTime]	,
				t.[Meta_RecordSource]			,
				t.[Meta_ETLProcessID]			,
								
				t.[Out_ISIN]					

	FROM		stg.HSBCNET_CustodianPositions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubCustodianSecurities] h
			WHERE	h.[HKeyCustodianSecurity]	=	t.[Out_HKeyHubCustodianSecurity]			
		) ;
		
		
--	Load Custodian Securities Satellite

	---- Insert new pay loads  
	INSERT INTO [dv].[SatCustodianSecurities] 
		(
					HKeyCustodianSecurity, 
					Meta_LoadDateTime, 
					Meta_LoadEndDateTime,
					Meta_SrcSysExportDateTime,
					Meta_RecordSource, 
					Meta_ETLProcessID,

					HDiffCustodianSecurityPL,
					
					SEDOL,	
					SecurityDescription,
					IssueType, 
					IssueTypeDescription, 
					SecurityCurrency					
		)

	SELECT DISTINCT
					t.Out_HKeyHubCustodianSecurity, 
					t.Meta_LoadDateTime, 
					CAST( N'9999-12-31' AS DATETIME2),	
					t.Meta_SrcSysExportDateTime,
					t.Meta_RecordSource, 
					t.Meta_ETLProcessID,				

					t.Out_HDiffCustodianSecurityPL,					
					
					t.Out_SEDOL,
					t.Out_SecurityDescription,
					t.Out_IssueType,
					t.Out_IssueTypeDescription,
					t.Out_SecurityCurrency
			
	FROM	stg.HSBCNET_CustodianPositions  t
	WHERE	t.Meta_LoadDateTime		=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatCustodianSecurities] s
			WHERE	s.HKeyCustodianSecurity		=	t.Out_HKeyHubCustodianSecurity
			AND		s.HDiffCustodianSecurityPL	=	t.Out_HDiffCustodianSecurityPL
			AND		t.Meta_LoadDateTime			=	@LoadDateTime 
		) ;


-- End Date Previous Custodian Securities Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatCustodianSecurities] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	dv.[SatCustodianSecurities] z
													WHERE	z.HKeyCustodianSecurity		=	s.HKeyCustodianSecurity
													AND		z.Meta_LoadDateTime			>	s.Meta_LoadDateTime
												)
	FROM	[dv].[SatCustodianSecurities] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.HSBCNET_CustodianPositions t
					WHERE	Meta_LoadDateTime				=	@LoadDateTime		
					AND		t.Out_HKeyHubCustodianSecurity	=	s.HKeyCustodianSecurity
				)
	;



--	Load Custodian Positions Link table
	
	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[LinkCustodianPositions] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[LinkCustodianPositions] l	

	INNER JOIN	stg.HSBCNET_CustodianPositions t
	ON			l.HKeyCustodianPosition		=	t.Out_HKeyLinkCustodianPosition		
	
	WHERE		t.Meta_LoadDateTime			=	@LoadDateTime ;


	INSERT INTO		[dv].[LinkCustodianPositions] 
			(
				[HKeyCustodianPosition]		,		-- Hash of Security Code + Price Date + Price Type + Price Source
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,		-- As no CDC from source used to check duration since data last sent
				[Meta_SrcSysExportDateTime]	, 
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,		-- FK to ID of import batch audit table	?

				[HKeyCustodianAccount]		,		--	UIX	
				[HKeyCustodianSecurity]		,		--	UIX		
				[HKeyPriceCurrency]			,		--	UIX	-- Hash of Currency Code
	
				[ReportDate]				,		--	UIX			
				[SecuritiesAccountNumber]	,		--	UIX			
				[ISIN]						,		--	UIX			
				[SecurityCurrency]			,		--	UIX			
				[AsOfDateTime]						--	UIX		
	
			)
	SELECT 
				t.[Out_HKeyLinkCustodianPosition]	,
				t.[Meta_LoadDateTime]				,
				t.[Meta_LoadDateTime]				,
				t.[Meta_SrcSysExportDateTime]		, 
				t.[Meta_RecordSource]				,
				t.[Meta_ETLProcessID]				,

				t.[Out_HKeyHubCustodianAccount]		,
				t.[Out_HKeyHubCustodianSecurity]	,
				t.[Out_HKeyHubSecurityCurrency]		,
				
				t.[Out_ReportDate] ,
				t.[Out_SecuritiesAccountNumber]		,
				t.[Out_ISIN]						,
				t.[Out_SecurityCurrency]			,
				t.[Out_AsOfDateTime]			

	FROM		stg.HSBCNET_CustodianPositions t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[LinkCustodianPositions] l
			WHERE	l.HKeyCustodianPosition			=	t.Out_HKeyLinkCustodianPosition
		) ;


--	Load Custodian Positions Satellite

	-- Insert new payloads  

	INSERT INTO [dv].[SatCustodianPositions] 
		(
			[HKeyCustodianPosition]			,	
			[Meta_LoadDateTime]				,
			[Meta_LoadEndDateTime]			,
			[Meta_SrcSysExportDateTime]		,
			[Meta_RecordSource]				,
			[Meta_ETLProcessID]				,				-- FK to ID of import batch 		
			[HDiffCustodianPositionPL]		,
			
			[LocationCode]								,
			[AssetLocation]								,
			[LocationDescription]						,
			[RegistrarCode]								,
			[RegistrarDescription]						,
			[RegistrationCode]							,
			[RegistrationDescription]					,
			[MaturityDate]								,
			
			[TradedAggregate]							,
			[SettledAggregate]							,
			[AvailableBalance]							,
			[SecurityPrice]								,
			[SecurityOnLoan]							,
			[TradedValue_SecurityCurrency]				,
			[SettledAggregateValue_SecurityCurrency]	,			
			[TradedValue_AccountCurrency]				,
			[SettledAggregateValue_AccountCurrency]		,
			[ExchangeRate]													
		)

	SELECT
			t.Out_HKeyLinkCustodianPosition, 
			t.Meta_LoadDateTime, 
			CAST( N'9999-12-31' AS DATETIME2 ),		
			t.Meta_SrcSysExportDateTime,
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,
			t.Out_HDiffCustodianPositionPL,	

			t.Out_LocationCode,
			t.Out_AssetLocation,
			t.Out_LocationDescription,
			t.Out_RegistrarCode,
			t.Out_RegistrarDescription,
			t.Out_RegistrationCode,
			t.Out_RegistrationDescription,
			t.Out_MaturityDate,
						
			t.Out_TradedAggregate,
			t.Out_SettledAggregate,
			t.Out_AvailableBalance,

			t.Out_SecurityPrice,
			t.Out_SecurityOnLoan, 
			t.Out_TradedValue_SecurityCurrency,
			t.Out_SettledAggregateValue_SecurityCurrency,						
			t.Out_TradedValue_AccountCurrency,
			t.Out_SettledAggregateValue_AccountCurrency,
			t.Out_ExchangeRate
						
	FROM	stg.HSBCNET_CustodianPositions t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatCustodianPositions] s
			WHERE	s.HKeyCustodianPosition		=	t.Out_HKeyLinkCustodianPosition
			AND		s.HDiffCustodianPositionPL	=	t.Out_HDiffCustodianPositionPL
			AND		t.Meta_LoadDateTime			=	@LoadDateTime 
			-- AND		s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 )
		) ;
	
	
-- End Date Previous Custodian Position Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime

	UPDATE	[dv].[SatCustodianPositions] 
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.[SatCustodianPositions] z
												WHERE	z.HKeyCustodianPosition	=	s.HKeyCustodianPosition
												AND		z.Meta_LoadDateTime		>	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatCustodianPositions] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.HSBCNET_CustodianPositions t
					WHERE	t.Meta_LoadDateTime				=	@LoadDateTime		
					AND		t.Out_HKeyLinkCustodianPosition =	s.HKeyCustodianPosition
				)
	;

	   	 
GO


