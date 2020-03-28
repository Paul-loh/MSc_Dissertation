CREATE PROCEDURE [etl].[MANUAL_LoadDVPriceSources]	(
														@LoadDateTime	DATETIME2
													)
WITH EXECUTE AS OWNER 
AS
--	Load reference table
   	 
	INSERT INTO		[ref].[RefPriceSources]
			(				
				[Meta_LoadDateTime]				--	UIX	
				,[Meta_LoadEndDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
				
				,[RecordPriority]				--	UIX	
				,[PrimaryType]					--	UIX	
				,[PriceCcy]						--	UIX	
				,[Residence]					--	UIX	
				,[PriSrcPriority]				--	UIX		
				,[PriceSource]					--	UIX					
			)

	SELECT 	
				[Meta_LoadDateTime]
				,CAST( N'9999-12-31' AS DATETIME2)	
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
			
				,[Out_RecordPriority]
				,[Out_PrimaryType]
				,[Out_PriceCcy]
				,[Out_Residence]
				,[Out_PriSrcPriority]
				,[Out_PriceSource]
				
	FROM		stg.Manual_PriceSources		t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 
	;
	
-- End Dating of Previous Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[ref].[RefPriceSources] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	[ref].[RefPriceSources]  z
													WHERE	z.Meta_LoadDateTime >	s.Meta_LoadDateTime			
												)
	FROM	[ref].[RefPriceSources] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	;

GO


