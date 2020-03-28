CREATE PROCEDURE [etl].[PACER_LoadStgSecurityBackers]	(
															@LoadDateTime	DATETIME2
														)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-12-02
			Description:	Load Pacer Security Backers Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
		

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_SecurityBackers] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_SecurityBackers] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_SecurityBackers] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[PACER_SecurityBackers] 
				(
					[In_SECURITY ID]				,
					[In_ATTRIBUTE IDENTITY CODE]	,
					[In_ATTRIBUTE VALUE]			,
					[In_EFFECT START DATE]			,
					[In_EFFECT END DATE]			,
					[In_ENTRY OPERATOR]				,
					[In_ENTRY DATE]					,
					[In_MODI OPERATOR]				,
					[In_MODI DATE]					,
					[In_ANNOTATION]					,
					[In_ISSUER NAME]				,
					[In_ISSUE]						,
	
					[Out_SECID]							,
					[Out_ATTRIBUTE_IDENTITY_CODE]		,
					[Out_ATTRIBUTE_VALUE]				,
					[Out_EFFECT_START_DATE]				,
					[Out_EFFECT_END_DATE]				,
					[Out_ENTRY_OPERATOR]				,
					[Out_ENTRY_DATE]					,
					[Out_MODI_OPERATOR]					,
					[Out_MODI_DATE]						,
					[Out_ANNOTATION]					,
					[Out_ISSUER_NAME]					,
					[Out_ISSUE]							,

					[Out_SecurityBackersPL]				

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
				TRIM([SECURITY ID])
				,TRIM([ATTRIBUTE IDENTITY CODE])
				,TRIM([ATTRIBUTE VALUE])
				,TRIM([EFFECT START DATE])
				,TRIM([EFFECT END DATE])
				,TRIM([ENTRY OPERATOR])
				,TRIM([ENTRY DATE])
				,TRIM([MODI OPERATOR])
				,TRIM([MODI DATE])
				,TRIM([ANNOTATION])
				,TRIM([ISSUER NAME])
				,TRIM([ISSUE])
				
			-- OUTPUTS							
				,TRIM( SUBSTRING(TRIM( [SECURITY ID] ), 7, 10 ))
				,TRIM([ATTRIBUTE IDENTITY CODE])
				,TRIM([ATTRIBUTE VALUE])
				,TRIM([EFFECT START DATE])
				,TRIM([EFFECT END DATE])
				,TRIM([ENTRY OPERATOR])
				,TRIM([ENTRY DATE])
				,TRIM([MODI OPERATOR])
				,TRIM([MODI DATE])
				,TRIM([ANNOTATION])
				,TRIM([ISSUER NAME])
				,TRIM([ISSUE])
				
				,CONCAT_WS( N'|', 
								TRIM(ISNULL([SECURITY ID], N'')),  
								TRIM(ISNULL([ATTRIBUTE IDENTITY CODE], N'')),  
								-- TRIM(ISNULL([ATTRIBUTE VALUE], N'')),  
								TRIM(ISNULL([EFFECT START DATE], N'')),  
								TRIM(ISNULL([EFFECT END DATE], N'')),  
								TRIM(ISNULL([ENTRY OPERATOR], N'')),  
								TRIM(ISNULL([ENTRY DATE], N'')),  
								TRIM(ISNULL([MODI OPERATOR], N'')),  
								TRIM(ISNULL([MODI DATE], N'')),  
								TRIM(ISNULL([ANNOTATION], N'')),  
								TRIM(ISNULL([ISSUER NAME], N'')),  
								TRIM(ISNULL([ISSUE], N''))
							)										AS [Out_SecurityBackersPL] 
					
				,[Meta_ETLProcessID]
				,N'PACER.SECBACK' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]

		FROM	tmp.PACER_SecurityBackers
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 

		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE	[stg].[PACER_SecurityBackers] 

					-- Business Key HASH VALUE					
				SET [Out_HKeyLinkSecurityBackers]		=	HASHBYTES(N'SHA1', UPPER( CONCAT_WS('|', 
																									[Out_SECID] ,  
																									[Out_ATTRIBUTE_VALUE] 																					 
																									)))	
																										
					-- Payload HASH VALUE - including the Business Key components
					,[Out_HDiffSecurityBackersPL]		=	HASHBYTES( N'SHA1', UPPER( [Out_SecurityBackersPL] ))

					-- Linked Business Keys Hash Values
					, [Out_HKeySecurity]				=	HASHBYTES( N'SHA1', UPPER( [Out_SECID] ))
					, [Out_HKeyBacker]					=	HASHBYTES( N'SHA1', UPPER( [Out_ATTRIBUTE_VALUE] ))

		FROM	stg.[PACER_SecurityBackers]
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgSecurityBackers : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO
