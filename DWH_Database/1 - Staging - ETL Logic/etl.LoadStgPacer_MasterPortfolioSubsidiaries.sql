CREATE PROCEDURE [etl].[PACER_LoadStgMasterPortfolioSubsidiaries]	(
																		@LoadDateTime	DATETIME2
																	)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-12-10
			Description:	Load Pacer Master Portfolio Subsidiary Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
				

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_MasterPortfolioSubsidiaries] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
		
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_MasterPortfolioSubsidiaries] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_MasterPortfolioSubsidiaries] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;


		INSERT INTO [stg].[PACER_MasterPortfolioSubsidiaries] 
				(
					[In_MasterCode]
					,[In_SubPortfCode]

					,[Out_MasterCode]
					,[Out_SubPortfCode]

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
				TRIM([MasterCode])
				,TRIM([SubPortfCode])

			-- OUTPUTS				
				,CAST(TRIM([MasterCode])						AS NVARCHAR(100))
				,CAST(TRIM([SubPortfCode])						AS NVARCHAR(100))				
									
				,[Meta_ETLProcessID]
				,N'PACER.MSTPRTSUB' 
				,[Meta_LoadDateTime]
				,NULL											AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]							AS [Meta_EffectFromDateTime]		
				,N'9999-12-31'									AS [Meta_EffectToDateTime]
				,1 AS [Meta_ActiveRow]

		FROM	tmp.[PACER_MasterPortfolioSubsidiaries]
		
		
		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE stg.[PACER_MasterPortfolioSubsidiaries]

			SET	
			-- Link record HASH VALUE
				[Out_HKeyLinkPortfolioMasterSubsidiary]		=	HASHBYTES(N'SHA1', UPPER( 
																							CONCAT_WS(N'|', 
																										TRIM( ISNULL( [Out_MasterCode], N'' )), 
																										TRIM( ISNULL( [Out_SubPortfCode], N'' ))
																									))) 	
			-- Business Key HASH VALUES
			,	[Out_HKeyHubMasterCode]						=		HASHBYTES(N'SHA1', COALESCE( [Out_MasterCode], N''))				
			,	[Out_HKeyHubSubPortfCode]					=		HASHBYTES(N'SHA1', COALESCE( [Out_SubPortfCode], N''))				
				
		FROM	stg.[PACER_MasterPortfolioSubsidiaries]
		WHERE	Meta_LoadDateTime							=		@LoadDateTime;

	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgMasterPortfolioSubsidiaries : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


