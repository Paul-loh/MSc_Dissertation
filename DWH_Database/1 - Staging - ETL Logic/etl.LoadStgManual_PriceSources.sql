CREATE PROCEDURE [etl].[MANUAL_LoadStgPriceSources]	(
														@LoadDateTime	DATETIME2
													)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2020-01-28
			Description:	Load manually managed price sources master data to Staging Layer							
			Changes:								
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;


		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[Manual_PriceSources] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[Manual_PriceSources] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		
		FROM		[stg].[Manual_PriceSources] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[Manual_PriceSources] 
				(
					[In_RecordPriority]				,
					[In_PrimaryType]				,
					[In_PriceCcy]					,
					[In_Residence]					,
					[In_PriSrcPriority]				,
					[In_PriceSource]				,					

					-- META DATA
					[Meta_ETLProcessID]
					,[Meta_RecordSource]
					,[Meta_LoadDateTime]
					,[Meta_SourceSysExportDateTime]
					,[Meta_EffectFromDateTime]
					,[Meta_EffectToDateTime]
					,[Meta_ActiveRow]					
				 )

		SELECT 	

			-- INPUTS
				TRIM([RecordPriority])				
				,TRIM([PrimaryType])			
				,TRIM([PriceCcy])
				,TRIM([Residence]) 
				,TRIM([PriSrcPriority])
				,TRIM([PriceSource])
										
				,[Meta_ETLProcessID]
				,N'MANUAL.PRCSRC' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]
		FROM	[tmp].[Manual_PriceSources]
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 

		-- UPDATE STAGING OUTPUTS				
		UPDATE		[stg].[Manual_PriceSources] 
		SET					
					[Out_RecordPriority]		=	CAST( [In_RecordPriority] AS INT ), 
					[Out_PrimaryType]			=	CAST( [In_PrimaryType] AS NCHAR(1) ), 
					[Out_PriceCcy]				=	CAST( [In_PriceCcy] AS NCHAR(3) ), 
					[Out_Residence]				=	CAST( [In_Residence] AS NCHAR(2) ), 
					[Out_PriSrcPriority]		=	CAST( [In_PriSrcPriority] AS INT ), 
					[Out_PriceSource]			=	CAST( [In_PriceSource] AS NVARCHAR(3) )
	
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
		
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.MANUAL_LoadStgPriceSources : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


