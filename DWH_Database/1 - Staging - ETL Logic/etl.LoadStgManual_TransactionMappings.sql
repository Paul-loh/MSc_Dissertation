CREATE PROCEDURE [etl].[MANUAL_LoadStgTransactionMappings]		(
																	@LoadDateTime	DATETIME2
																)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2020-01-31
			Description:	Load manually managed Transaction Mapping file Master Data to Staging Layer							
			Changes:								
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;


		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[Manual_TransactionMappings] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[Manual_TransactionMappings] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[Manual_TransactionMappings] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[Manual_TransactionMappings] 
				(
					[In_From_TransType]				,
					[In_From_FootNote]				,
					[In_From_TradeType]				,
					[In_From_PrimaryType]			,
					[In_To_Trans_Category]			,
					[In_To_Unit_Category]			,
					[In_To_Cash_Category]			,

					[Out_From_TransType]			,
					[Out_From_FootNote]				,
					[Out_From_TradeType]			,
					[Out_From_PrimaryType]			,
					[Out_To_Trans_Category]			,
					[Out_To_Unit_Category]			,
					[Out_To_Cash_Category]			
	
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
				TRIM([From_TransType])
				,TRIM([From_FootNote])
				,TRIM([From_TradeType])			
				,TRIM([From_PrimaryType])
				,TRIM([To_Trans_Category])
				,TRIM([To_Unit_Category])
				,TRIM([To_Cash_Category])
				
			-- OUTPUTS				
				,CAST( TRIM( ISNULL( [From_TransType], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [From_FootNote], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [From_TradeType], N'')) AS NVARCHAR(100) )			 
				,CAST( TRIM( ISNULL( [From_PrimaryType], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [To_Trans_Category], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [To_Unit_Category], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [To_Cash_Category], N'' )) AS NVARCHAR(100) )
									
				,[Meta_ETLProcessID]
				,N'MANUAL.TRANMAP' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]
		FROM	tmp.[Manual_TransactionMappings]
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			  
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.MANUAL_LoadStgTransactionMappings : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


