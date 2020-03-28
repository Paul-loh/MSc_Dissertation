CREATE PROCEDURE [etl].[PACER_LoadStgValuations]	(
														@LoadDateTime	DATETIME2
													)
WITH EXECUTE AS OWNER 
AS

	/*
			Author:			Paul Loh
			Date:			2019-09-06 (My birthday!!!)
			Description:	Load Pacer Valuations into Staging Layer
			Changes:		

	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE		@TranCount		INT;

		SET @TranCount	=	@@TRANCOUNT;

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_Valuations] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;

		
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Valuations] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Valuations] c
		WHERE		c.[Meta_LoadDateTime]			<>	@LoadDateTime
		;
		   
		-- INPUTS
		INSERT INTO [stg].[PACER_Valuations] 
				(
					[In_PORTCD]
					,[In_SECID]
					,[In_VALDATE]
					,[In_BOKFXC]
					,[In_HOLDINGS]
					,[In_COST]
					,[In_VALUE]
					,[In_COSTNAT]
					,[In_VALUNAT]
					,[In_PNAT]

					,[Out_PORTCDBK]
					,[Out_SECIDBK]
					,[Out_VALDATEBK]
					,[Out_BOKFXCBK]
					,[Out_HOLDINGS]
					,[Out_COST]
					,[Out_VALUE]
					,[Out_COSTNAT]
					,[Out_VALUNAT]
					,[Out_PNAT]

					--,[Out_HKeyHubValuations]
					,[Out_ValuationPL]
					--,[Out_HDiffValuationPL]
										
					,[Meta_ETLProcessID]
					,[Meta_RecordSource]
					,[Meta_LoadDateTime]
					,[Meta_SourceSysExportDateTime]
					,[Meta_EffectFromDateTime]
					,[Meta_EffectToDateTime]
					,[Meta_ActiveRow]					
				 )

		SELECT 	
			-- INPUTS
				TRIM([PORTCD])
				,TRIM([SECID])
				,TRIM([VALDATE])
				,TRIM([BOKFXC])
				,TRIM([HOLDINGS])
				,TRIM([COST])
				,TRIM([VALUE])
				,TRIM([COSTNAT])
				,TRIM([VALUNAT])
				,TRIM([PNAT])

			-- OUTPUTS				
				-- KEY CODES Used in Hash Key \ Primary Key converted to upper case  
				,UPPER(TRIM([PORTCD]))
				,UPPER(TRIM([SECID]))
				
				-- ,UPPER(TRIM([VALDATE]))
				,CAST( TRIM([VALDATE]) AS DATETIME2 )
				
				,UPPER(TRIM([BOKFXC]))
				,CAST(TRIM([HOLDINGS])	AS DECIMAL(38,20))
				,CAST(TRIM([COST])		AS DECIMAL(38,20)) 
				,CAST(TRIM([VALUE])		AS DECIMAL(38,20)) 
				,CAST(TRIM([COSTNAT])	AS DECIMAL(38,20)) 
				,CAST(TRIM([VALUNAT])	AS DECIMAL(38,20)) 
				,CAST(TRIM([PNAT])		AS DECIMAL(38,20)) 
															
			---- Business Key HASH VALUE
			--	,HASHBYTES(N'SHA1', UPPER( 
			--							CONCAT_WS(N'|', 											
			--									TRIM(ISNULL([PORTCD],N'')), 
			--									TRIM(ISNULL([SECID],N'')),												
			--									-- TRIM(ISNULL([VALDATE],N'')),	-- TBD - Convert to ISO 1806 format 
			--									CASE	WHEN TRIM( ISNULL([VALDATE], N'')) = N''
			--											THEN ''
			--											ELSE CONVERT( NVARCHAR(30), CAST( TRIM([VALDATE]) AS DATETIME2), 126) END, 
			--											TRIM(ISNULL([BOKFXC], N''))
			--									)))						AS BKHashkey
				
			-- Payload
				,CONCAT_WS(N'|', 
								TRIM( ISNULL([HOLDINGS],N'')),  
								TRIM( ISNULL([COST],N'')),  
								TRIM( ISNULL([VALUE],N'')),
								TRIM( ISNULL([COSTNAT],N'')),
								TRIM( ISNULL([VALUNAT],N'')),
								TRIM( ISNULL([PNAT],N''))
								)										AS ValuationPL

			---- Payload HASH VALUE - including the Business Key components
			--	,HASHBYTES(N'SHA1', CONCAT_WS(N'|', 
			--							TRIM( ISNULL([HOLDINGS],N'')),  
			--							TRIM( ISNULL([COST],N'')),  
			--							TRIM( ISNULL([VALUE],N'')),
			--							TRIM( ISNULL([COSTNAT],N'')),
			--							TRIM( ISNULL([VALUNAT],N'')),
			--							TRIM( ISNULL([PNAT],N''))
			--							))								AS PLHashDiff
									
				,[Meta_ETLProcessID]
				,N'PACER.VALU' 
				,[Meta_LoadDateTime]									AS [Meta_LoadDateTime]
				,NULL													AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]									AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )						AS [Meta_EffectToDateTime]
				,1														AS [Meta_ActiveRow]
		FROM	tmp.PACER_Valuations

		WHERE	[Meta_LoadDateTime]		=	@LoadDateTime


		-- Update Hash values of Business Keys and PayLoads using Unicode 'Out_' values
		UPDATE stg.PACER_Valuations				
			
			-- Valuation Business Key Hash Value
			SET [Out_HKeyHubValuations]		=	HASHBYTES(N'SHA1', 
														UPPER( 
																CONCAT_WS(N'|', 											
																		TRIM(ISNULL([Out_PORTCDBK],N'')), 
																		TRIM(ISNULL([Out_SECIDBK],N'')),												
																		CASE	WHEN [Out_VALDATEBK] IS NULL 
																				THEN N''
																				ELSE CONVERT( NVARCHAR(10), [Out_VALDATEBK], 23) END, 
																				TRIM(ISNULL([Out_BOKFXCBK], N''))
																		)))										

			-- Valuation Payload Hash Value - including the Business Key components
				, [Out_HDiffValuationPL]		=	HASHBYTES(N'SHA1', [Out_ValuationPL] )
		
		FROM	stg.PACER_Valuations
		WHERE	Meta_LoadDateTime		=	@LoadDateTime;
		
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgValuations : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


