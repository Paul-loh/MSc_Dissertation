CREATE PROC [etl].[PACER_LoadDVSecurities] (
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS

--	Load Hub
	
	-- Check hub already contains Business Key using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.


	UPDATE		[dv].[HubSecurities] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubSecurities] h

	INNER JOIN	stg.PACER_Securities t
	ON			h.HKeySecurity			=	t.Out_HKeyHubSecurities
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;


	
	INSERT INTO		[dv].[HubSecurities]
			(
				[HKeySecurity]				,			-- Hash of Security Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[SecID]									--	UIX	
			)
	SELECT 
				t.[Out_HKeyHubSecurities]			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_SecID]

	FROM		stg.PACER_Securities t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubSecurities] h
			WHERE	h.HKeySecurity		=	t.[Out_HKeyHubSecurities]
		) ;

		

--	Load Satellites

	---- Set the last valid datetime for existing records to inactive historical point in time 
	--MERGE INTO	[dv].[SatSecurities] AS s
	--USING		( SELECT * FROM stg.PACER_Securities WHERE Meta_ActiveRow = 1 ) AS t
	--ON			s.HKeySecurity			=	t.Out_HKeyHubSecurities	
	--AND			s.HDiffSecurityPL		<>	t.Out_HDiffSecurityPL
	--AND			s.Meta_LoadEndDateTime	>	t.Meta_LoadDateTime
	--WHEN MATCHED THEN 
	--			UPDATE SET s.Meta_LoadEndDateTime		=	DATEADD( MILLISECOND, -1, t.Meta_LoadDateTime)	
	--;

	-- Insert new payloads  

	INSERT INTO [dv].[SatSecurities] 
		(
			HKeySecurity, 
			Meta_LoadDateTime, 
			Meta_LoadEndDateTime,
			Meta_RecordSource, 
			Meta_ETLProcessID,
			HDiffSecurityPL,
					
			[SecID]					,
			[IssuerName]			,
			[IssueDesc]				,
			[Ticker]				,
			[PrimaryType]			,
			[SecondaryType]			,
			[TertiaryType]			,
			[IsFloatingRate]		,
			[IsFwdBwdSecID]			,
			[IncomePayFreq]			,
			[IncomeStatus]			,
			[PriceCcy]				,
			[IncomeCcy]				,
			[EarningsCcy]			,
			[PriceCcyISO]			,
			[IncomeCcyISO]			,
			[EarningsCcyISO]		,
			[ResidenceCtry]			,
			[AnnualIncome]			,
			[CurrentExDate]			,
			[LastAdjDate]			,
			[SplitRate]				,
			[FirstInterestDate]		,
			[Latest12MthEPS]		,
			[FxDealRate]			,
			[AccrualDate]			,
			[PaymentStream]			,
			[FRSUSchCode]			,
			[VotingCode]			,
			[SettleDTCEligible]		,
			[StdIndustryClass]		,
			[IssueDate]				,
			[RedeemDate]			,
			[AltRedeemDate]			,
			[ConstPrepayRate]		,
			[OutstandingShares]		,
			[BondIssuerType]		,
			[NextCallDate]			,
			[Multiplier]			,
			[NextCallPrice]			,
			[SecCategory]			,
			[IssuerCode]			,
			[CompoundingFreq]		,
			[LastUpdate]			,
			[EntryDate]				,
			[DbSource]				,
			[ExchangeCtry]			
		)
	SELECT
			t.Out_HKeyHubSecurities, 
			t.Meta_LoadDateTime, 
			CAST( N'9999-12-31' AS DATETIME2 ),		
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,
			t.Out_HDiffSecurityPL,

			t.[Out_SecID]					,
			t.[Out_IssuerName]			,
			t.[Out_IssueDesc]				,
			t.[Out_Ticker]				,
			t.[Out_PrimaryType]			,
			t.[Out_SecondaryType]			,
			t.[Out_TertiaryType]			,
			t.[Out_IsFloatingRate]		,
			t.[Out_IsFwdBwdSecID]			,
			t.[Out_IncomePayFreq]			,
			t.[Out_IncomeStatus]			,
			t.[Out_PriceCcy]				,
			t.[Out_IncomeCcy]				,
			t.[Out_EarningsCcy]			,
			t.[Out_PriceCcyISO]			,
			t.[Out_IncomeCcyISO]			,
			t.[Out_EarningsCcyISO]		,
			t.[Out_ResidenceCtry]			,
			t.[Out_AnnualIncome]			,
			t.[Out_CurrentExDate]			,
			t.[Out_LastAdjDate]			,
			t.[Out_SplitRate]				,
			t.[Out_FirstInterestDate]		,
			t.[Out_Latest12MthEPS]		,
			t.[Out_FxDealRate]			,
			t.[Out_AccrualDate]			,
			t.[Out_PaymentStream]			,
			t.[Out_FRSUSchCode]			,
			t.[Out_VotingCode]			,
			t.[Out_SettleDTCEligible]		,
			t.[Out_StdIndustryClass]		,
			t.[Out_IssueDate]				,
			t.[Out_RedeemDate]			,
			t.[Out_AltRedeemDate]			,
			t.[Out_ConstPrepayRate]		,
			t.[Out_OutstandingShares]	,
			t.[Out_BondIssuerType]		,
			t.[Out_NextCallDate]		,
			t.[Out_Multiplier]			,
			t.[Out_NextCallPrice]		,
			t.[Out_SecCategory]			,
			t.[Out_IssuerCode]			,
			t.[Out_CompoundingFreq]		,
			t.[Out_LastUpdate]			,
			t.[Out_EntryDate]			,
			t.[Out_DbSource]			,
			t.[Out_ExchangeCtry]	
			
	FROM	stg.PACER_Securities t
	WHERE	Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatSecurities] s
			WHERE	s.HKeySecurity		=	t.Out_HKeyHubSecurities
			AND		s.HDiffSecurityPL	=	t.Out_HDiffSecurityPL
		) ;
	
	

-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatSecurities] 
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.[SatSecurities] z
												WHERE	z.HKeySecurity		=	s.HKeySecurity
												AND		z.Meta_LoadDateTime >	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatSecurities] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_Securities t
					WHERE	Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyHubSecurities		=	s.HKeySecurity
				)
	;

GO



