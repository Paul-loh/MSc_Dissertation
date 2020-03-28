CREATE PROCEDURE [etl].[PACER_LoadStgFXRates]	(
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load Pacer FX Rates to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_FXRates] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;

				
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_FXRates] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_FXRates] t
		
		WHERE		t.Meta_LoadDateTime				<>	@LoadDateTime ; 
		
			   

		INSERT INTO [stg].[PACER_FXRates] 
				(
					[In_CcyCode]					
					,[In_RateToGBP]					
					,[In_RateDate]				
					
					,[Out_CurrencyCode]				
					,[Out_RateDate]					
					,[Out_RateToGBP]				
					,[Out_SSCCcyCode]			

					--,[Out_HKeyFXRates]
					--,[Out_FXRatesPL]
					--,[Out_HDiffFXRatesPL]

					,[Out_HKeyCurrencyCode]
					
					,[Meta_ETLProcessID]
					,[Meta_RecordSource]
					,[Meta_LoadDateTime]
					,[Meta_EffectFromDateTime]
					,[Meta_EffectToDateTime]
					,[Meta_ActiveRow]
				 )

		SELECT 	
			-- INPUTS 
				TRIM( fx.CcyCode )
				,TRIM( fx.[RateToGBP] )
				,TRIM( fx.[RateDate] )
			
			-- OUTPUTS
				,COALESCE( c1.CurrencyCode, N'MISSING_MANDATORY_BK')					AS Out_CurrencyCode
				,CASE	WHEN COALESCE(RateDate, N'') = N'' 
						THEN NULL
						ELSE CAST( CAST( RateDate AS DATE) AS DATETIME2) END			AS Out_RateDate
				,CAST( TRIM( fx.[RateToGBP] ) AS NUMERIC (38,20))						AS Out_RateToGBP	
				,UPPER( TRIM( fx.CcyCode ) )											AS [Out_SSCCcyCode]							

			---- Hash value of Business Key 
			--	,HASHBYTES(N'SHA1', UPPER( CONCAT_WS(N'|', 
			--									COALESCE(c1.CurrencyCode, N'MISSING_MANDATORY_BK'), 
			--									CASE	WHEN COALESCE(fx.[RateDate], N'') = N'' 
			--											THEN N''
			--											ELSE CONVERT( NVARCHAR(30), TRIM(fx.[RateDate]), 126) END
			--										)
			--							))												AS [Out_HKeyFXRates]			
			--							-- TRIM( ISNULL(fx.[RateDate], '')))))			AS [Out_HKeyFXRates]			
															
			--	,CONCAT_WS(N'|', 
			--					COALESCE(c1.CurrencyCode, N'MISSING_MANDATORY_BK'), 
			--					TRIM( ISNULL(fx.[CcyCode], N'')), 
			--					CASE	WHEN ISNULL(fx.[RateDate], N'') = N'' 
			--							THEN N''
			--							ELSE CONVERT( NVARCHAR(30), TRIM(fx.[RateDate]), 126) END,
			--					TRIM( ISNULL(fx.[RateToGBP], ''))
			--				)															AS [Out_FXRatesPL]

			--	,HASHBYTES(N'SHA1', 
			--						CONCAT_WS('|', 
			--									COALESCE(c1.CurrencyCode, N'MISSING_MANDATORY_BK'),
			--									TRIM( ISNULL(fx.[CcyCode], '')), 
			--									CASE	WHEN ISNULL(fx.[RateDate], N'') = N'' 
			--											THEN N''
			--											ELSE CONVERT( NVARCHAR(30), TRIM(fx.[RateDate]), 126) END,
			--									TRIM( ISNULL(fx.[RateToGBP], ''))
			--								)
			--				)															AS [Out_HDiffFXRatesPL]

				,CASE	WHEN c1.HKeyCurrency IS NOT NULL
						THEN 
							c1.HKeyCurrency	
						ELSE 
							(SELECT HKeyCurrency 
							FROM	dv.HubCurrencies 
							WHERE	CurrencyCode = N'MISSING_MANDATORY_BK')
						END																AS [Out_HKeyCurrencyCode]

				,fx.[Meta_ETLProcessID]
				,N'PACER.FXRATES' 
				,[Meta_LoadDateTime]													AS [Meta_LoadDateTime]
				,[Meta_LoadDateTime]													AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )										AS [Meta_EffectToDateTime]
				,1																		AS [Meta_ActiveRow]
		
		FROM		tmp.PACER_FXRates fx
		
		-- Look up the latest 3 character code in the Currencies hub
		-- TBD:	Again we should standardise the Pacer source feeds to all use 3-character currency codes		
		LEFT JOIN (
						SELECT		h.HKeyCurrency, h.CurrencyCode, s.SSCCode
						FROM		dv.HubCurrencies h
						LEFT JOIN	dv.SatCurrencies s
						ON			h.HKeyCurrency = s.HKeyCurrency
						WHERE		COALESCE( s.Meta_LoadEndDateTime, CAST(N'9999-12-31' AS DATETIME2)) = CAST(N'9999-12-31' AS DATETIME2)
					) AS c1
		ON		c1.[SSCCode]	=	TRIM(fx.CcyCode)

		
		   		 
		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE stg.PACER_FXRates

			-- Hash value of Business Key 
			SET		[Out_HKeyFXRates]	=	HASHBYTES(N'SHA1', 
														UPPER( CONCAT_WS( N'|' , 
																				Out_CurrencyCode, 
																				CASE	WHEN COALESCE(Out_RateDate, N'') = N'' 
																						THEN N''
																						ELSE CONVERT( NVARCHAR(10), Out_RateDate, 23) 
																						END
														)))																						
															
					, [Out_FXRatesPL]	=	CONCAT_WS(N'|', 
														Out_CurrencyCode, 
														TRIM( ISNULL( Out_SSCCcyCode, N'') ), 
														CASE	WHEN ISNULL(Out_RateDate, N'') = N'' 
																THEN N''
																ELSE CONVERT( NVARCHAR(10), Out_RateDate, 23) END,
														ISNULL( CAST( NULL AS NVARCHAR(100) ), N'' )
													)															

					, [Out_HDiffFXRatesPL]	=	HASHBYTES(N'SHA1', 
															CONCAT_WS(N'|', 
																		Out_CurrencyCode, 
																		TRIM( ISNULL( Out_SSCCcyCode, N'') ), 
																		CASE	WHEN ISNULL(Out_RateDate, N'') = N'' 
																				THEN N''
																				ELSE CONVERT( NVARCHAR(10), Out_RateDate, 23) END,
																		ISNULL( CAST( NULL AS NVARCHAR(100) ), N'' )
																	))					
																

		FROM	stg.PACER_FXRates
		WHERE	Meta_LoadDateTime		=	@LoadDateTime;

	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgFXRates : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
