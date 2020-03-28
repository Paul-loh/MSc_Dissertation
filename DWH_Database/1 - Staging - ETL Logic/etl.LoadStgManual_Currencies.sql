CREATE PROC [etl].[MANUAL_LoadStgCurrencies]	(
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load manually managed Currencies Master Data to Staging Layer							
			Changes:								
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;


		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[MANUAL_Currencies] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[MANUAL_Currencies] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[MANUAL_Currencies] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[MANUAL_Currencies] 
				(
					[In_CcyCode]
					,[In_SSCCode]
					,[In_CurrencyName]
					,[In_Group]
					
					,[Out_CcyCodeBK]
					,[Out_SSCCode]
					,[Out_CurrencyName]						
					,[Out_Group]			
					
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
				TRIM([CcyCode])
				,TRIM([SSCCode])
				,TRIM([CurrencyName])			
				,TRIM([Group])

			-- OUTPUTS				
				,UPPER(TRIM([CcyCode])) 
				,TRIM([SSCCode])
				,TRIM([CurrencyName])
				,CAST([Group] AS INT)
									
				,[Meta_ETLProcessID]
				,N'MANUAL.CURRENC' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]
		FROM	tmp.MANUAL_Currencies
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 
		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE	[stg].[MANUAL_Currencies] 

					-- Business Key HASH VALUE					
				SET [Out_HKeyHubCurrencies]		=	HASHBYTES(N'SHA1', [Out_CcyCodeBK] ) 					
					-- Payload
					,[Out_CurrencyPL]			=	CONCAT_WS(N'|', 
																TRIM( ISNULL([Out_SSCCode], N'')),  
																TRIM( ISNULL([Out_CurrencyName], N'')),  
																TRIM( ISNULL(TRY_CAST([Out_Group] AS NVARCHAR), N'')))				
					-- Payload HASH VALUE - including the Business Key components
					,[Out_HDiffCurrencyPL]		=	HASHBYTES(N'SHA1', CONCAT_WS(N'|', 
																				TRIM( ISNULL([Out_CcyCodeBK], N'')),  
																				TRIM( ISNULL([Out_SSCCode], N'')),  
																				TRIM( ISNULL([Out_CurrencyName], N'')),  
																				TRIM( ISNULL( TRY_CAST([Out_Group] AS NVARCHAR), N''))))	

		FROM	stg.MANUAL_Currencies
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.MANUAL_LoadStgCurrencies : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


