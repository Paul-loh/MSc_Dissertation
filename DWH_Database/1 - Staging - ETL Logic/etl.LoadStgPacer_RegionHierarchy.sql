CREATE PROCEDURE [etl].[PACER_LoadStgRegionHierarchy] (
															@LoadDateTime	DATETIME2
														)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2019-12-12
			Description:	Load Pacer Region Hierarchy master data to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
		
		-- Re-Run for exactly the same Load Datetime - would only happen during testing \ historical load 
		DELETE 	FROM [stg].[PACER_RegionHierarchy] 
		WHERE		Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_RegionHierarchy] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_RegionHierarchy] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[PACER_RegionHierarchy]
				(
					[In_FIELDS]

					,[Out_Code]
					,[Out_SecurityClass]
					,[Out_ParentCode]
					
					,[Out_HierarchyLevelPL]				
					
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
				TRIM([FIELDS])
				
			-- OUTPUTS				
				, UPPER( SUBSTRING( TRIM([FIELDS]), 2, 9 ))											AS [Out_Code]
				, TRIM( SUBSTRING( TRIM( [FIELDS] ), 12, 988 ))										AS [Out_SecurityClass]

				, UPPER( TRIM( 
							CASE	WHEN SUBSTRING( TRIM(FIELDS), 8, 3) <> N'999' 
									THEN SUBSTRING(	TRIM(FIELDS), 2, 6) + N'999' 
									WHEN SUBSTRING(	TRIM(FIELDS), 5, 3) <> N'999' 
									THEN SUBSTRING(	TRIM(FIELDS), 2, 3) + N'999999'
							END				
						))																			AS [Out_ParentCode]

			-- Payload
				, TRIM( ISNULL( TRIM( SUBSTRING( [FIELDS], 12, 988 )) , N''))						AS [Out_HierarchyLevelPL]
				
				,[Meta_ETLProcessID]
				,N'PACER.REGHIER' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]

		FROM	tmp.PACER_RegionHierarchy

		WHERE	Meta_LoadDateTime		=	@LoadDateTime
		


		-- Update Hash values of Business Key using Unicode 'Out_' values

		UPDATE stg.PACER_RegionHierarchy

			---- Business Key HASH VALUEs			
			SET		
			
			-- Parent Region Code and Region Code 
				[Out_HKeyLinkRegionHierarchy]		=	HASHBYTES	( N'SHA1',																		
																		CONCAT_WS( N'|',
																						COALESCE( [Out_ParentCode], N'')	-- Region Parent Code
																						,COALESCE( [Out_Code], N'')			-- Region Child Code
																				)																			
																	)																			
																	
			-- Region Parent Code
					-- It's valid for some records not to have Parent codes as they are at the 'top of the hierarchy'
				, Out_HKeyRegionParentCode		=	CASE	WHEN [Out_ParentCode] IS NULL 
																THEN	0x1111111111111111111111111111111111111111	
																ELSE	HASHBYTES(N'SHA1', COALESCE( [Out_ParentCode], N'' ))	
																END 

			-- Region Code
				, [Out_HKeyHubCode]					=	CASE	WHEN [Out_Code] IS NULL 
																THEN	0x1111111111111111111111111111111111111111	
																ELSE	HASHBYTES(N'SHA1', COALESCE( [Out_Code], N'' ))	
																END 
																				
			-- Payload HASH VALUE - including the Business Key components
				, [Out_HDiffHierarchyLevelPL]		=	HASHBYTES(N'SHA1', COALESCE( [Out_HierarchyLevelPL], N'' ))
				
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadstgRegionHierarchy : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO






