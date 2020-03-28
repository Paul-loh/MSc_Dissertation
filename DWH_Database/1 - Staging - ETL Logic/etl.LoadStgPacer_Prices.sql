CREATE PROC [etl].[PACER_LoadStgPrices] (
											@LoadDateTime	DATETIME2
										)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load Pacer Prices Data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_Prices] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;

				
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Prices] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Prices] t
		WHERE		t.Meta_LoadDateTime				<>	@LoadDateTime

		AND	EXISTS		--	Price Natural Key	SecurityCode \ Price Date \ Price Type \ Price Source
		(	
			SELECT	* 
			FROM	tmp.PACER_Prices 

			-- TBD:		THIS IS RUBBISH, as we're implementing soft business rules in staging logic but we should just import  
			--			the actual original Security IDs and manipluate them downstream in the Business Vault.
			--			That way the raw data is preserved when imported. 

			WHERE	(case when Left(TRIM(SecID),8) = N'XMFSHARE' then N'WMFSHARE'+ substring(TRIM(SecID),9,2) else TRIM(SecID) end)	=	t.Out_SecurityCode 

			AND		cast((case when TRIM([Date]) = N'' then N'1901-01-01' else
					(case when substring(TRIM([Date]), 1, 2) > 60 then N'19' else N'20' end) + substring(TRIM([Date]), 1, 2) + N'-'
					+ substring(TRIM([Date]), 3, 2) + N'-' +  substring(TRIM([Date]), 5, 2) end) as date)	=	t.Out_PriceDate

			AND		TRIM([Type])	=	t.Out_PriceType
			AND		TRIM([Source])	=	t.Out_PriceSource						 
		);
			   

		INSERT INTO [stg].[PACER_Prices] 
				(
					[In_SecID]							,
					[In_IssuerName]						,
					[In_IssueDesc]						,
					[In_Date]							,
					[In_Source]							,
					[In_Type]							,
					[In_Flag]							,
					[In_HighPrice]						,
					[In_LowPrice]						,
					[In_ClosePrice]						,
					[In_BidPrice]						,
					[In_AskPrice]						,
					[In_YieldToBid]						,
					[In_VolumeTraded]					,
					[In_EntryDate]						

					,[Out_SecurityCode]
					,[Out_PriceDate]
					,[Out_PriceType]
					,[Out_PriceSource]
					,[Out_StatusFlag]
					,[Out_ClosePrice]
					,[Out_BidPrice]
					,[Out_AskPrice]
					,[Out_HighPrice]
					,[Out_LowPrice]
					,[Out_TradingVolume]
					,[Out_Yield]
					,[Out_EntryDate]

					--,[Out_HKeyPrices]
					,[Out_PricePL]
					--,[Out_HDiffPricePL]
					--,[Out_HKeySecID]	
					
					,[Meta_ETLProcessID]
					,[Meta_RecordSource]
					,[Meta_LoadDateTime]
					,[Meta_EffectFromDateTime]
					,[Meta_EffectToDateTime]
					,[Meta_ActiveRow]
				 )

			SELECT 
				-- INPUTS
					TRIM( t.[SecID] )			,
					TRIM( t.[IssuerName] )	,
					TRIM( t.[IssueDesc] )		,
					TRIM( t.[Date])			,
					TRIM( t.[Source] )		,
					TRIM( t.[Type] )			,
					TRIM( t.[Flag] )			,
					TRIM( t.[HighPrice] )		,
					TRIM( t.[LowPrice] )		,
					TRIM( t.[ClosePrice] )	,
					TRIM( t.[BidPrice] )		,
					TRIM( t.[AskPrice])		,
					TRIM( t.[YieldToBid] )	,
					TRIM( t.[VolumeTraded] )	,
					TRIM( t.[EntryDate] )						

				-- OUTPUTS
					,(CASE	WHEN UPPER( LEFT( TRIM( t.SecID ), 8)) = N'XMFSHARE' 
							THEN N'WMFSHARE' + UPPER( SUBSTRING( TRIM( t.SecID ), 9, 2)) 
							ELSE UPPER( TRIM( t.SecID )) END)							AS SecurityCode

					,CAST((	CASE	WHEN TRIM(t.[Date]) = N'' 
									THEN N'1901-01-01' 
									ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[Date] ), 1, 2) > 60 
													THEN N'19' ELSE N'20' END ) 
											+ SUBSTRING( TRIM( t.[Date] ), 1, 2) + '-' 
											+ SUBSTRING( TRIM( t.[Date] ), 3, 2) + '-' 
											+ SUBSTRING( TRIM(t.[Date]), 5, 2) 
							END
							) AS DATETIME2)					AS PriceDate

					,TRIM(t.[Type])							AS PriceType
					,TRIM(t.[Source])						AS PriceSource
					,TRIM(t.[Flag])							AS StatusFlag
					,CAST(t.ClosePrice AS NUMERIC(38,20))	AS ClosePrice
					,CAST(t.BidPrice AS NUMERIC(38,20))		AS BidPrice
					,CAST(t.AskPrice AS NUMERIC(38,20))		AS AskPrice
					,CAST(t.HighPrice AS NUMERIC(38,20))	AS HighPrice
					,CAST(t.LowPrice AS NUMERIC(38,20))		AS LowPrice
					,CAST(t.VolumeTraded AS INT)			AS TradingVolume
					,CAST(t.YieldToBid AS NUMERIC(38,20))	AS Yield
																			
					,CAST((	CASE	WHEN TRIM(t.EntryDate) = N'' 
									THEN N'1901-01-01' 
									ELSE (	CASE	WHEN SUBSTRING (TRIM( t.EntryDate ), 1, 2) > 60 
													THEN N'19' ELSE N'20' END ) 
											+ SUBSTRING( TRIM( t.EntryDate ), 1, 2) + '-' 
											+ SUBSTRING( TRIM( t.EntryDate ), 3, 2) + '-' 
											+ SUBSTRING( TRIM(t.EntryDate), 5, 2) 
							END
							) AS DATETIME2)					AS EntryDate
				
				-- Payload
					, CONCAT_WS	(N'|', 
									TRIM( ISNULL( t.[SecID], N'')), 
									TRIM( ISNULL( t.[Source], N'')), 
									TRIM( ISNULL( t.[Type], N'')), 

									-- TRIM( ISNULL( t.[Date], N'')), 
									CONVERT(	NVARCHAR(30), 
												CAST((	CASE	WHEN TRIM(t.[Date]) = N'' 
												THEN N'1901-01-01' 
												ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[Date] ), 1, 2) > 60 
																THEN N'19' ELSE N'20' END ) 
														+ SUBSTRING( TRIM( t.[Date] ), 1, 2) + '-' 
														+ SUBSTRING( TRIM( t.[Date] ), 3, 2) + '-' 
														+ SUBSTRING( TRIM(t.[Date]), 5, 2) 
												END ) AS DATETIME2 ), 
												126),  
												
									TRIM( ISNULL( t.[IssuerName], N'')), 
									TRIM( ISNULL( t.[IssueDesc], N'')), 
									TRIM( ISNULL( t.[Flag], N'')), 
									TRIM( ISNULL( t.[HighPrice], N'')), 
									TRIM( ISNULL( t.[LowPrice], N'')), 
									TRIM( ISNULL( t.[ClosePrice], N'')), 
									TRIM( ISNULL( t.[BidPrice], N'')), 
									TRIM( ISNULL( t.[AskPrice], N'')), 
									TRIM( ISNULL( t.[YieldToBid], N'')), 
									TRIM( ISNULL( t.[VolumeTraded], N'')), 

									-- TRIM( ISNULL( t.[EntryDate], N''))
									CONVERT(	NVARCHAR(30), 
												CAST((	CASE	WHEN TRIM(t.EntryDate) = N'' 
												THEN N'1901-01-01' 
												ELSE (	CASE	WHEN SUBSTRING (TRIM( t.EntryDate ), 1, 2) > 60 
																THEN N'19' ELSE N'20' END ) 
														+ SUBSTRING( TRIM( t.EntryDate ), 1, 2) + '-' 
														+ SUBSTRING( TRIM( t.EntryDate ), 3, 2) + '-' 
														+ SUBSTRING( TRIM(t.EntryDate), 5, 2) 
												END) AS DATETIME2),
												126) 

								)															AS [Out_PricePL]

					,t.Meta_ETLProcessID				AS [Meta_ETLProcessID]
					,N'PACER.PRICES'					AS [Meta_RecordSource]
					,t.Meta_LoadDateTime				AS [Meta_LoadDateTime]
					,t.Meta_LoadDateTime				AS [Meta_EffectFromDateTime]		
					,N'9999-12-31'						AS [Meta_EffectToDateTime]
					,1									AS [Meta_ActiveRow]

		FROM	tmp.PACER_Prices t
		

		UPDATE	stg.PACER_Prices 
		
			-- Hash value of Business Key 
				SET		Out_HKeyPrices		=	HASHBYTES(N'SHA1', UPPER( CONCAT_WS('|', 
																					UPPER( [Out_SecurityCode] ),  
																					UPPER( [Out_PriceSource] ),  
																					UPPER( [Out_PriceType] ),  																			
																					CONVERT( NVARCHAR(10), Out_PriceDate, 23) 
																		)))												
							
			-- Payload HASH VALUE - including the Business Key components + satellite attributes 
						,	[Out_HDiffPricePL]	=	HASHBYTES(N'SHA1', [Out_PricePL] )																
						,	[Out_HKeySecID]		=	HASHBYTES(N'SHA1', UPPER( [Out_SecurityCode] ))

		FROM	stg.PACER_Prices 
		WHERE	Meta_LoadDateTime				=	@LoadDateTime

	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgPrices : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


