CREATE PROCEDURE [etl].[PACER_LoadStgPortfolios] (
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load Pacer Portfolios Master Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
				

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_Portfolios] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
		

		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Portfolios] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Portfolios] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;

		INSERT INTO [stg].[PACER_Portfolios] 
				(
					[In_PortfCode]
					,[In_AccountExec]
					,[In_AccountNumber]
					,[In_PortfType]
					,[In_Permissions]
					,[In_InitDate]
					,[In_BaseCcy]
					,[In_ResidenceCtry]
					,[In_ResidenceRegion]
					,[In_TaxType]
					,[In_ValuationDate]
					,[In_BookCost]
					,[In_MarketValue]
					,[In_CustodianCode]
					,[In_SettlementAcct]
					,[In_CustAcctNumber]
					,[In_ObjectiveCode]
					,[In_PortfStatus]
					,[In_PersysFlag]
					,[In_PortfName]
					,[In_Address1]
					,[In_Address2]
					,[In_CumulGain]
					,[In_LotIndicator]
					,[Out_PortfCode]
					,[Out_AccountExec]
					,[Out_AccountNumber]
					,[Out_PortfType]
					,[Out_Permissions]
					,[Out_InitDate]
					,[Out_BaseCcy]
					,[Out_ResidenceCtry]
					,[Out_ResidenceRegion]
					,[Out_TaxType]
					,[Out_ValuationDate]
					,[Out_BookCost]
					,[Out_MarketValue]
					,[Out_CustodianCode]
					,[Out_SettlementAcct]
					,[Out_CustAcctNumber]
					,[Out_ObjectiveCode]
					,[Out_PortfStatus]
					,[Out_PersysFlag]
					,[Out_PortfName]
					,[Out_Address1]
					,[Out_Address2]
					,[Out_CumulGain]
					,[Out_LotIndicator]

					-- ,[Out_HKeyHubPortfolios]
					,[Out_PortfolioPL]
					-- ,[Out_HDiffPortfolioPL]

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
				TRIM([PortfCode])
				,TRIM([AccountExec])
				,TRIM([AccountNumber])
				,TRIM([PortfType])
				,TRIM([Permissions])
				,TRIM([InitDate])
				,TRIM([BaseCcy])
				,TRIM([ResidenceCtry])
				,TRIM([ResidenceRegion])
				,TRIM([TaxType])
				,TRIM([ValuationDate])
				,TRIM([BookCost])
				,TRIM([MarketValue])
				,TRIM([CustodianCode])
				,TRIM([SettlementAcct])
				,TRIM([CustAcctNumber])
				,TRIM([ObjectiveCode])
				,TRIM([PortfStatus])
				,TRIM([PersysFlag])
				,TRIM([PortfName])
				,TRIM([Address1])
				,TRIM([Address2])
				,TRIM([CumulGain])
				,TRIM([LotIndicator])

			-- OUTPUTS				
				,CAST(TRIM([PortfCode])			AS NVARCHAR(100))
				,CAST(TRIM([AccountExec])		AS NVARCHAR(100))
				,CAST(TRIM([AccountNumber])		AS NVARCHAR(100))
				,CAST(TRIM([PortfType])			AS NVARCHAR(100))
				,CAST(TRIM([Permissions])		AS NVARCHAR(100))
				,CAST(TRIM([InitDate])			AS NVARCHAR(100))
				,CAST(TRIM([BaseCcy])			AS NVARCHAR(100))
				,CAST(TRIM([ResidenceCtry])		AS NVARCHAR(100))
				,CAST(TRIM([ResidenceRegion])	AS NVARCHAR(100))
				,CAST(TRIM([TaxType])			AS NVARCHAR(100))
				,CAST(TRIM([ValuationDate])		AS NVARCHAR(100))
				,CAST(TRIM([BookCost])			AS NUMERIC(30,20))
				,CAST(TRIM([MarketValue])		AS NUMERIC(30,20))
				,CAST(TRIM([CustodianCode])		AS NVARCHAR(100))
				,CAST(TRIM([SettlementAcct])	AS NVARCHAR(100))
				,CAST(TRIM([CustAcctNumber])	AS NVARCHAR(100))
				,CAST(TRIM([ObjectiveCode])		AS NVARCHAR(100))
				,CAST(TRIM([PortfStatus])		AS NVARCHAR(100))
				,CAST(TRIM([PersysFlag])		AS NVARCHAR(100))
				,CAST(TRIM([PortfName])			AS NVARCHAR(100))
				,CAST(TRIM([Address1])			AS NVARCHAR(100))
				,CAST(TRIM([Address2])			AS NVARCHAR(100))
				,CAST(TRIM([CumulGain])			AS NUMERIC(30,20))
				,CAST(TRIM([LotIndicator])		AS NVARCHAR(100))
				
			-- Payload
				,CONCAT_WS(N'|'
								,TRIM([PortfCode])
								,TRIM([AccountExec])
								,TRIM([AccountNumber])
								,TRIM([PortfType])
								,TRIM([Permissions])
								,TRIM([InitDate])
								,TRIM([BaseCcy])
								,TRIM([ResidenceCtry])
								,TRIM([ResidenceRegion])
								,TRIM([TaxType])
								,TRIM([ValuationDate])
								,TRIM([BookCost])
								,TRIM([MarketValue])
								,TRIM([CustodianCode])
								,TRIM([SettlementAcct])
								,TRIM([CustAcctNumber])
								,TRIM([ObjectiveCode])
								,TRIM([PortfStatus])
								,TRIM([PersysFlag])
								,TRIM([PortfName])
								,TRIM([Address1])
								,TRIM([Address2])
								,TRIM([CumulGain])
								,TRIM([LotIndicator])
							)													AS PortfolioPL
									
				,[Meta_ETLProcessID]
				,N'PACER.PORTF' 
				,[Meta_LoadDateTime]
				,NULL					AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]	AS [Meta_EffectFromDateTime]		
				,N'9999-12-31'			AS [Meta_EffectToDateTime]
				,1 AS [Meta_ActiveRow]

		FROM	tmp.PACER_Portfolios
		
		
		-- Update Hash value of Business Key using Unicode 'Out_' values
		UPDATE stg.PACER_Portfolios
			-- Business Key HASH VALUE
			SET	Out_HKeyHubPortfolios		=	HASHBYTES(N'SHA1', COALESCE( [Out_PortfCode], N''))				
			-- Payload HASH VALUE - including Business Key components as we could in theory have identical attributes against >1 business key			
				, Out_HDiffPortfolioPL	=	HASHBYTES(N'SHA1', COALESCE( [Out_PortfolioPL], N''))
				
		FROM	stg.PACER_Portfolios
		WHERE	Meta_LoadDateTime		=	@LoadDateTime;

	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgPortfolios : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


