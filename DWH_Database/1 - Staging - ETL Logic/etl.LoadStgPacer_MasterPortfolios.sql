CREATE PROCEDURE [etl].[PACER_LoadStgMasterPortfolios] (
															@LoadDateTime	DATETIME2
														)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-12-10
			Description:	Load Pacer Master Portfolios Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
				

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_MasterPortfolios] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
		
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_MasterPortfolios] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_MasterPortfolios] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;

		INSERT INTO [stg].[PACER_MasterPortfolios] 
				(
					[In_AsFromDate]
					,[In_PortfCode]
					,[In_MasterType]

					,[Out_AsFromDate]
					,[Out_PortfCode]
					,[Out_MasterType]

					,[Out_MasterPortfolioPL]

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
				TRIM([AsFromDate])
				,TRIM([PortfCode])
				,TRIM([MasterType])

			-- OUTPUTS				
				,CAST(TRIM([AsFromDate])		AS NVARCHAR(100))
				,CAST(TRIM([PortfCode])			AS NVARCHAR(100))
				,CAST(TRIM([MasterType])		AS NVARCHAR(100))
				
			-- Payload
				,CONCAT_WS(N'|'
								,CAST(TRIM([PortfCode])			AS NVARCHAR(100))
								,CAST(TRIM([AsFromDate])		AS NVARCHAR(100))
								,CAST(TRIM([MasterType])		AS NVARCHAR(100))								
							)														AS Out_MasterPortfolioPL
									
				,[Meta_ETLProcessID]
				,N'PACER.MSTPRTTYP' 
				,[Meta_LoadDateTime]
				,NULL					AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]	AS [Meta_EffectFromDateTime]		
				,N'9999-12-31'			AS [Meta_EffectToDateTime]
				,1 AS [Meta_ActiveRow]

		FROM	tmp.PACER_MasterPortfolios
		
		
		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE stg.PACER_MasterPortfolios

			-- Business Key HASH VALUE
			SET	[Out_HKeyHubPortfolio]				=		HASHBYTES(N'SHA1', COALESCE( [Out_PortfCode], N''))				

			--	Payload HASH VALUE -	including Business Key components as we could in theory 
			--							have identical attributes against >1 business key			
				, [Out_HDiffMasterPortfolioPL]		=		HASHBYTES(N'SHA1', COALESCE( [Out_MasterPortfolioPL], N''))
				
		FROM	stg.PACER_MasterPortfolios
		WHERE	Meta_LoadDateTime		=	@LoadDateTime;

	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgMasterPortfolios : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


