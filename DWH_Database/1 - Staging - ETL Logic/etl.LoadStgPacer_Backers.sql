CREATE PROCEDURE [etl].[PACER_LoadStgBackers]	(
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-12-02
			Description:	Load Pacer Backers Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
		

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_Backers] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Backers] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Backers] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[PACER_Backers] 
				(
					[In_Columns]
					
					, [Out_BackerCodeBK]
					, [Out_ShortName]
					
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
				TRIM([Columns])
				
			-- OUTPUTS				
				,UPPER( TRIM( LEFT([Columns], 10 )))				AS [Out_BackerCodeBK]
				,TRIM( SUBSTRING( [Columns], 11, 140 ))				AS [Out_ShortName]
					
				,[Meta_ETLProcessID]
				,N'PACER.BACKERS' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]

		FROM	tmp.PACER_Backers
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 

		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE	[stg].[PACER_Backers] 

					-- Business Key HASH VALUE					
				SET [Out_HKeyHubBackers]		=	HASHBYTES( N'SHA1', [Out_BackerCodeBK] ) 	
				
					-- Payload
					,[Out_BackerPL]				=	ISNULL( [Out_ShortName], N'') 

					-- Payload HASH VALUE - including the Business Key components
					,[Out_HDiffBackerPL]		=	HASHBYTES( N'SHA1', [Out_ShortName] )

		FROM	stg.[PACER_Backers]
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			   		 
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.PACER_LoadStgBackers : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO
