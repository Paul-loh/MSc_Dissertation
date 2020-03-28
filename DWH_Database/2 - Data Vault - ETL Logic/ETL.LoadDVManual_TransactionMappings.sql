CREATE PROCEDURE [etl].[MANUAL_LoadDVTransactionMappings]	(
																@LoadDateTime	DATETIME2
															)
WITH EXECUTE AS OWNER 
AS

--	Load reference table   	 
	INSERT INTO		[ref].[RefTransactionAnalysisMapping]
			(				
				[Meta_LoadDateTime]					--	UIX	
				,[Meta_LoadEndDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
				
				,[From_TransType]					--	UIX	
				,[From_FootNote]					--	UIX	
				,[From_TradeType]					--	UIX	
				,[From_PrimaryType]					--	UIX	
				,[To_Trans_Category]				--	UIX		
				,[To_Unit_Category]					--	UIX			
				,[To_Cash_Category]					--	UIX			
			)

	SELECT 	
				[Meta_LoadDateTime]
				,CAST( N'9999-12-31' AS DATETIME2)	
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
			
				,[Out_From_TransType]
				,[Out_From_FootNote]
				,[Out_From_TradeType]
				,[Out_From_PrimaryType]
				,[Out_To_Trans_Category]
				,[Out_To_Unit_Category]
				,[Out_To_Cash_Category]
				
	FROM		stg.Manual_TransactionMappings		t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 
	;
	
-- End Dating of Previous Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[ref].[RefTransactionAnalysisMapping] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	[ref].[RefTransactionAnalysisMapping]  z
													WHERE	z.Meta_LoadDateTime >	s.Meta_LoadDateTime			
												)
	FROM	[ref].[RefTransactionAnalysisMapping] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	;

GO


