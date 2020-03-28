CREATE PROCEDURE [etl].[PACER_LoadStgSecurityClassifications]	(
																	@LoadDateTime	DATETIME2
																)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-10-22
			Description:	Load Pacer security classification Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_SecurityClassification] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_SecurityClassification] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_SecurityClassification] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[PACER_SecurityClassification] 
				(
					[In_SecurityID]
					,[In_IndustryCode]
					,[In_RegionCode]
					,[In_AssetCatCode]
					
					,[Out_SecurityID]
					,[Out_IndustryCode]
					,[Out_RegionCode]						
					,[Out_AssetCatCode]	
					
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
				TRIM([SecurityID])
				,TRIM([IndustryCode])
				,TRIM([RegionCode])			
				,TRIM([AssetCatCode])

			-- OUTPUTS				
				,UPPER(TRIM([SecurityID])) 
				,UPPER(TRIM([IndustryCode]))
				,UPPER(TRIM([RegionCode]))
				,UPPER(TRIM([AssetCatCode]))
						
				,[Meta_ETLProcessID]
				,N'PACER.SECCLASS'
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,N'1900-01-01'										AS [Meta_EffectFromDateTime]	
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]

		FROM	tmp.[PACER_SecurityClassification]

		WHERE	Meta_LoadDateTime			=	@LoadDateTime 
		
		--	The import file terminates with a total record count line beginning with '!' so exclude from import 
		AND		LEFT(COALESCE( TRIM(SecurityID), '') , 1 )	<> '!'
		;


		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE stg.[PACER_SecurityClassification]

		-- Business Key HASH VALUE
		SET			

			-- Link composite Business Key HASH VALUE							
				Out_HKeyLinkSecurityClassification	=	HASHBYTES(N'SHA1', CONCAT_WS(N'|', 
																					TRIM( ISNULL([Out_SecurityID], N'')),
																					TRIM( ISNULL([Out_IndustryCode], N'')),  
																					TRIM( ISNULL([Out_RegionCode], N'')),  
																					TRIM( ISNULL([Out_AssetCatCode], N'')))
																		)				
				
				, Out_HKeySecurityID	=	CASE	WHEN	TRIM( ISNULL([Out_SecurityID], N'')) = '' 
													THEN	0x1111111111111111111111111111111111111111				--	Ghost Record
													ELSE	HASHBYTES(N'SHA1', UPPER( [Out_SecurityID] ))				
													END																	
				
				, Out_HKeyIndustryCode	=	CASE	WHEN	TRIM( ISNULL([Out_IndustryCode], N'')) = '' 
													THEN	0x1111111111111111111111111111111111111111				--	Ghost Record
													ELSE	HASHBYTES(N'SHA1', UPPER( [Out_IndustryCode] ))				
													END																

				, Out_HKeyRegionCode	=	CASE	WHEN	TRIM( ISNULL([Out_RegionCode], N'')) = '' 
													THEN	0x1111111111111111111111111111111111111111				--	Ghost Record
													ELSE	HASHBYTES(N'SHA1', UPPER( [Out_RegionCode] ))				
													END																

				, Out_HKeyAssetCatCode	=	CASE	WHEN	TRIM( ISNULL([Out_AssetCatCode], N'')) = '' 
													THEN	0x1111111111111111111111111111111111111111				--	Ghost Record
													ELSE	HASHBYTES(N'SHA1', UPPER( [Out_AssetCatCode] ))				
													END
		FROM	stg.[PACER_SecurityClassification]
		WHERE	Meta_LoadDateTime		=	@LoadDateTime	
		
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.PACER_LoadStgSecurityClassifications : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO