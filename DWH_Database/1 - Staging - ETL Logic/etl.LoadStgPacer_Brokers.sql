CREATE PROCEDURE [etl].[PACER_LoadStgBrokers] (
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2020-02-26
			Description:	Load Pacer Broker master data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
		
		-- Re-Run for exactly the same Load Datetime - would only happen during testing \ historical load 
		DELETE 	
		FROM		[stg].[PACER_Brokers] 
		WHERE		Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Brokers] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Brokers] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[PACER_Brokers]
				(
					[In_Columns]

					,[Out_BrokerCodeBK]
					,[Out_BrokerName]
										
					,[Out_BrokerPL]				
					
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
				TRIM([FIELDS])
				
			-- OUTPUTS				
				, TRIM( UPPER( SUBSTRING( TRIM([FIELDS]), 2, 4 )))				AS [Out_BrokerCode]
				, TRIM( SUBSTRING( TRIM( [FIELDS] ), 8, 992 ))					AS [Out_BrokerName]

			-- Payload
				, ISNULL( TRIM( SUBSTRING( TRIM( [FIELDS] ), 8, 992 )), N'')	AS [Out_BrokerPL]
				
				,[Meta_ETLProcessID]
				,N'PACER.BROKERS' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]

		FROM	tmp.PACER_Brokers

		WHERE	Meta_LoadDateTime		=	@LoadDateTime
		;
		
		

		-- Update Hash values of Business Key using Unicode 'Out_' values
		UPDATE stg.PACER_Brokers

			---- Business Key HASH VALUEs			
			SET		
			
			-- Broker Code 
				[Out_HKeyHubBroker]			=	HASHBYTES( N'SHA1', COALESCE( [Out_BrokerCodeBK], N''))																			
																				
			-- Payload HASH VALUE - including the Business Key components
				,[Out_HDiffBrokerPL]		=	HASHBYTES(N'SHA1', COALESCE( [Out_BrokerPL], N'' ))
				
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgBrokers : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO






