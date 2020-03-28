CREATE PROCEDURE [etl].[HSBCNET_LoadStgCustodianPositions] (
															@LoadDateTime	DATETIME2															
															)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load HSBC.Net Client View Positions Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[HSBCNET_CustodianPositions]
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;


		-- Delete the last record from the temp table if it contains columns that are all NULL.
		-- This is caused by the HSBC.Net report that terminates the file with "", ?
		DELETE	FROM tmp.HSBCNet_CustodianPositions 
		WHERE	COALESCE( SecuritiesAccountNumber, N'' ) = N''
		AND		COALESCE( SEDOL, N'' ) = N''
		AND		COALESCE( ISIN, N'' ) = N'';


		--	Set to inactive the previous active rows 
		UPDATE		[stg].[HSBCNET_CustodianPositions] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[HSBCNET_CustodianPositions] t
		WHERE		t.Meta_LoadDateTime				<>	@LoadDateTime ;
			   

		INSERT INTO [stg].[HSBCNET_CustodianPositions]
				(
					[In_SecuritiesAccountNumber]				,
					[In_AccountName]							,
					[In_IssueType]								,
					[In_ISIN]									,
					[In_SecurityDescription]					,
					[In_AssetLocation]							,
					[In_LocationDescription]					,
					[In_IssueTypeDescription]					,
					[In_LocationCode]							,
					[In_RegistrarCode]							,
					[In_MaturityDate]							,					
					[In_TradedAggregate]						,
					[In_RegistrationCode]						,
					[In_RegistrarDescription]					,					
					[In_SettledAggregate]						,
					[In_SecurityOnLoan]							,
					[In_RegistrationDescription]				,					
					[In_AvailableBalance]						,
					[In_SEDOL]									,	
					[In_SecurityPrice]							,
					[In_SecurityCurrency]						,

					[In_TradedValue_SecurityCurrency]			,
					[In_SettledAggregateValue_SecurityCurrency]	,
					[In_AccountCurrency]						,
					[In_TradedValue_AccountCurrency]			,
					[In_SettledAggregateValue_AccountCurrency]	,
					[In_ExchangeRate]							,
	
					[Out_ReportDate]								,
					[Out_AsOfDateTime]								,
					[Out_SecuritiesAccountNumber]					,
					[Out_AccountName]								,
					[Out_IssueType]									,
					[Out_ISIN]										,
					[Out_SecurityDescription]						,
					[Out_AssetLocation]								,
					[Out_LocationDescription]						,
					[Out_IssueTypeDescription]						,
					[Out_LocationCode]								,
					[Out_RegistrarCode]								,
					[Out_MaturityDate]								,					
					[Out_TradedAggregate]							,
					[Out_RegistrationCode]							,
					[Out_RegistrarDescription]						,
					[Out_SettledAggregate]							,
					[Out_SecurityOnLoan]							,
					[Out_RegistrationDescription]					,					
					[Out_AvailableBalance]							,
					[Out_SEDOL]										,	
					[Out_SecurityPrice]								,					
					[Out_SecurityCurrency]							,										
					[Out_TradedValue_SecurityCurrency]				,
					[Out_SettledAggregateValue_SecurityCurrency]	,
					[Out_AccountCurrency]							,
					[Out_TradedValue_AccountCurrency]				,
					[Out_SettledAggregateValue_AccountCurrency]		,
					[Out_ExchangeRate]								,
	
					[Meta_ETLProcessID]								,	 
					[Meta_RecordSource]								,
					[Meta_LoadDateTime]								,
					[Meta_SrcSysExportDateTime]						, 	
					[Meta_EffectFromDateTime]						,
					[Meta_EffectToDateTime]							,	
					[Meta_ActiveRow]								
				 )

			SELECT 

			-- INPUTS
					TRIM( t.[SecuritiesAccountNumber] )		,
					TRIM( t.[AccountName] )					,
					TRIM( t.[IssueType] )					,
					TRIM( t.[ISIN] )						,
					TRIM( t.[SecurityDescription])			,
					TRIM( t.[AssetLocation] )				,
					TRIM( t.[LocationDescription] )			,
					TRIM( t.[IssueTypeDescription] )		,
					TRIM( t.[LocationCode] )				,
					TRIM( t.[RegistrarCode] )				,
					TRIM( t.[MaturityDate] )				,
					
					TRIM( t.[TradedAggregate] )				,
					TRIM( t.[RegistrationCode] )			,
					TRIM( t.[RegistrarDescription] )		,
					TRIM( t.[SettledAggregate] )			,
					TRIM( t.[SecurityOnLoan] )				,
					TRIM( t.[RegistrationDescription] )		,					
					TRIM( t.[AvailableBalance] )			,
					TRIM( t.[SEDOL] )						,
					TRIM( t.[SecurityPrice] )				,
					TRIM( t.[SecurityCurrency] )			,
					
					TRIM( t.[TradedValue_SecurityCurrency] ),
					TRIM( t.[SettledAggregateValue_SecurityCurrency])	,
					TRIM( t.[AccountCurrency] )				,
					TRIM( t.[TradedValue_AccountCurrency] )	,
					TRIM( t.[SettledAggregateValue_AccountCurrency] )	,	 
					TRIM( t.[ExchangeRate] )							,
					
			-- OUTPUTS
					
					-- The report date is derived the AsAtDateTime in the file header
						-- If the time is before 5PM then the report date is the current date, 
						-- If the time is after 5PM then the Report date is the next business date
					
					--CAST( t.[Meta_SrcSysExportDateTime] AS DATE )								AS Out_ReportDate,
					CAST(
							CASE	WHEN	DATEPART( hh, ( CAST( t.Meta_SrcSysExportDateTime AS TIME) ) ) > 17 
									THEN	DATEADD( DAY, 1, t.Meta_SrcSysExportDateTime)
									ELSE	t.Meta_SrcSysExportDateTime
									END	AS DATE
						)																		AS Out_ReportDate,
					t.[Meta_SrcSysExportDateTime] 												AS Out_AsOfDateTime,
					 
					TRIM( t.[SecuritiesAccountNumber] )											AS SecuritiesAccountNumber, 
					TRIM( t.[AccountName] )														AS AccountName,
					TRIM( t.[IssueType] )														AS IssueType,
					TRIM( t.[ISIN] )															AS ISIN, 
					TRIM( t.[SecurityDescription] )												AS SecurityDescription, 
					TRIM( t.[AssetLocation] )													AS AssetLocation, 
					TRIM( t.[LocationDescription] )												AS LocationDescription, 
					TRIM( t.[IssueTypeDescription] )											AS IssueTypeDescription,
					TRIM( t.[LocationCode] )													AS LocationCode, 
					TRIM( t.[RegistrarCode] )													AS RegistrarCode, 
					TRY_CAST( t.[MaturityDate] AS DATETIME2)									AS MaturityDate, 
					TRY_CAST(t.[TradedAggregate] AS NUMERIC(38,20))								AS TradedAggregate,
					TRIM( t.[RegistrationCode] )												AS RegistrationCode, 
					TRIM( t.[RegistrarDescription] )											AS RegistrarDescription, 
					TRY_CAST(t.[SettledAggregate] AS NUMERIC(38,20))							AS SettledAggregate,
					TRY_CAST(t.[SecurityOnLoan] AS NUMERIC(38,20))								AS SecurityOnLoan,
					TRIM( t.[RegistrationDescription] )											AS RegistrationDescription, 
					TRY_CAST(t.[AvailableBalance] AS NUMERIC(38,20))							AS AvailableBalance,
					TRIM( t.[SEDOL] )															AS SEDOL, 
					TRY_CAST(t.[SecurityPrice] AS NUMERIC(38,20))								AS SecurityPrice,										
					TRIM( t.[SecurityCurrency] )												AS SecurityCurrency, 
					
					TRY_CAST(t.[TradedValue_SecurityCurrency] AS NUMERIC(38,20))				AS TradedAggregate,
					TRY_CAST(t.[SettledAggregateValue_SecurityCurrency] AS NUMERIC(38,20))		AS TradedAggregate,

					TRIM( t.[AccountCurrency] )													AS AccountCurrency, 
					TRY_CAST(t.[TradedValue_AccountCurrency] AS NUMERIC(38,20))					AS TradedValue_AccountCurrency,										
					TRY_CAST(t.[SettledAggregateValue_AccountCurrency] AS NUMERIC(38,20))		AS SettledAggregateValue_AccountCurrency,										
					TRY_CAST(t.[ExchangeRate] AS NUMERIC(38,20))								AS ExchangeRate										
								

					,t.Meta_ETLProcessID				AS [Meta_ETLProcessID]
					,N'HSBCNET.POS'						AS [Meta_RecordSource]
					,t.Meta_LoadDateTime				AS [Meta_LoadDateTime]
					,t.[Meta_SrcSysExportDateTime]		AS [Meta_SrcSysExportDateTime]
					,t.Meta_LoadDateTime				AS [Meta_EffectFromDateTime]		
					,N'9999-12-31'						AS [Meta_EffectToDateTime]					
					,1									AS [Meta_ActiveRow]

		FROM	tmp.HSBCNet_CustodianPositions t


		-- Update Hash value of Business Key using Unicode 'Out_' values

		UPDATE	[stg].[HSBCNET_CustodianPositions]
			SET 
					[Out_HKeyLinkCustodianPosition]	=	HASHBYTES(N'SHA1', UPPER( CONCAT_WS('|', 														
																				--CONVERT( NVARCHAR(30), @ReportDate, 23),  
																				CONVERT( NVARCHAR(30), [Meta_SrcSysExportDateTime], 23),  
																				TRIM( ISNULL([Out_SecuritiesAccountNumber], N'')),  
																				TRIM( ISNULL([Out_ISIN], N'')),
																				TRIM( ISNULL([Out_SecurityCurrency], N'')),
																				CONVERT( NVARCHAR(30), [Meta_SrcSysExportDateTime] ), 126 )
																				))																

					-- Custodian Position Satellite Payload
					, [Out_CustodianPositionPL]		=	CONCAT_WS	(N'|', 									
																	TRIM( ISNULL( [Out_LocationCode], N'')), 
																	TRIM( ISNULL( [Out_AssetLocation], N'')),
																	TRIM( ISNULL( [Out_LocationDescription], N'')),
																	TRIM( ISNULL( [Out_RegistrarCode], N'')),
																	TRIM( ISNULL( [Out_RegistrarDescription], N'')),
																	TRIM( ISNULL( [Out_RegistrationCode], N'')),
																	TRIM( ISNULL( [Out_RegistrationDescription], N'')),																	
																	CONVERT( NVARCHAR(30), [Out_MaturityDate] , 23),  
																	TRIM( ISNULL( TRY_CAST( [Out_TradedAggregate] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_SettledAggregate] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_AvailableBalance] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_SecurityPrice] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_SecurityOnLoan] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_TradedValue_SecurityCurrency] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_SettledAggregateValue_SecurityCurrency] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_TradedValue_AccountCurrency] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_SettledAggregateValue_AccountCurrency] AS NVARCHAR), N'')), 
																	TRIM( ISNULL( TRY_CAST( [Out_ExchangeRate] AS NVARCHAR), N'')) 																				
																	)
																	
					-- Custodian Position Satellite Payload HASH VALUE - including the Business Key components + satellite attributes 
					, [Out_HDiffCustodianPositionPL]	=	HASHBYTES(N'SHA1', CONCAT_WS	(N'|', 
																		TRIM( ISNULL( [Out_LocationCode], N'')), 
																		TRIM( ISNULL( [Out_AssetLocation], N'')),
																		TRIM( ISNULL( [Out_LocationDescription], N'')),
																		TRIM( ISNULL( [Out_RegistrarCode], N'')),
																		TRIM( ISNULL( [Out_RegistrarDescription], N'')),
																		TRIM( ISNULL( [Out_RegistrationCode], N'')),
																		TRIM( ISNULL( [Out_RegistrationDescription], N'')),
																		CONVERT( NVARCHAR(30), [Out_MaturityDate] , 23),  
																		TRIM( ISNULL( TRY_CAST( [Out_TradedAggregate] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_SettledAggregate] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_AvailableBalance] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_SecurityPrice] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_SecurityOnLoan] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_TradedValue_SecurityCurrency] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_SettledAggregateValue_SecurityCurrency] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_TradedValue_AccountCurrency] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_SettledAggregateValue_AccountCurrency] AS NVARCHAR), N'')), 
																		TRIM( ISNULL( TRY_CAST( [Out_ExchangeRate] AS NVARCHAR), N'')) 									
																	))
					
					, [Out_HKeyHubCustodianAccount]		=	HASHBYTES( N'SHA1', 
																		UPPER( TRIM( ISNULL( [Out_SecuritiesAccountNumber], N''))))		 	

					, [Out_CustodianAccountPL]			=	CONCAT_WS	(N'|', 		
																			TRIM( ISNULL( [Out_AccountName], N'')), 
																			TRIM( ISNULL( [Out_AccountCurrency], N''))
																		)																		
													
					, [Out_HDiffCustodianAccountPL]		=	HASHBYTES( N'SHA1', CONCAT_WS	(N'|', 		
																			TRIM( ISNULL( [Out_AccountName], N'')), 
																			TRIM( ISNULL( [Out_AccountCurrency], N''))
																	))																					

					, [Out_HKeyHubCustodianSecurity]		=	HASHBYTES( N'SHA1', UPPER( TRIM( ISNULL( [Out_ISIN], N''))))							

					, [Out_CustodianSecurityPL]			=	CONCAT_WS	(	N'|', 
																			TRIM( ISNULL( [Out_SEDOL], N'')), 
																			TRIM( ISNULL( [Out_SecurityDescription], N'')),
																			TRIM( ISNULL( [Out_IssueType], N'')),
																			TRIM( ISNULL( [Out_IssueTypeDescription], N'')),
																			TRIM( ISNULL( [Out_SecurityCurrency], N''))
																		)																		

					, [Out_HDiffCustodianSecurityPL]	=	HASHBYTES(	N'SHA1', 
																		CONCAT_WS	(	N'|', 
																						TRIM( ISNULL( [Out_SEDOL], N'')), 
																						TRIM( ISNULL( [Out_SecurityDescription], N'')),
																						TRIM( ISNULL( [Out_IssueType], N'')),
																						TRIM( ISNULL( [Out_IssueTypeDescription], N'')),
																						TRIM( ISNULL( [Out_SecurityCurrency], N''))
																					)
																		)																		

					, [Out_HKeyHubSecurityCurrency]		=	HASHBYTES( N'SHA1', UPPER( TRIM( ISNULL( [Out_SecurityCurrency], N''))))			

		FROM	[stg].[HSBCNET_CustodianPositions] t
		WHERE	t.Meta_LoadDateTime						=	@LoadDateTime
		
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.HSBCNET_LoadStgPositions : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END

RETURN @@ROWCOUNT

GO


