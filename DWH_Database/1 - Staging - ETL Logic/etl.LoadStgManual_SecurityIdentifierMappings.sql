CREATE PROCEDURE [etl].[MANUAL_LoadStgSecurityIdentifierMappings]	(
																		@LoadDateTime	DATETIME2
																	)
WITH EXECUTE AS OWNER 
AS
	/*
			Author:			Paul Loh
			Date:			2020-02-06
			Description:	Load manually managed system security identifier mappings master data to Staging Layer
			Changes:								
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN
		
	BEGIN TRY

		DECLARE @TranCount		INT;
		

		-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[Manual_SecurityIdentityMappings] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	
	
		--	Set to inactive the previous active rows 
		UPDATE		[stg].[Manual_SecurityIdentityMappings]
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[Manual_SecurityIdentityMappings] c
		WHERE		c.Meta_LoadDateTime				<>	@LoadDateTime;
		

		INSERT INTO [stg].[Manual_SecurityIdentityMappings] 
				(
					[In_LeadSystemCode]						,
					[In_LeadSystemSecurityCode]				,
					[In_PartnerSystemCode001]				,
					[In_PartnerSystemSecurityCode001]		,
					[In_PartnerSystemCode002]				,
					[In_PartnerSystemSecurityCode002]		,
					[In_PartnerSystemCode003]				,
					[In_PartnerSystemSecurityCode003]		,
					[In_PartnerSystemCode004]				,
					[In_PartnerSystemSecurityCode004]		,
					[In_PartnerSystemCode005]				,
					[In_PartnerSystemSecurityCode005]		,

					[Out_LeadSystemCode]					,
					[Out_LeadSystemSecurityCode]			,
					[Out_PartnerSystemCode001]				,
					[Out_PartnerSystemSecurityCode001]		,
					[Out_PartnerSystemCode002]				,
					[Out_PartnerSystemSecurityCode002]		,
					[Out_PartnerSystemCode003]				,
					[Out_PartnerSystemSecurityCode003]		,
					[Out_PartnerSystemCode004]				,
					[Out_PartnerSystemSecurityCode004]		,
					[Out_PartnerSystemCode005]				,
					[Out_PartnerSystemSecurityCode005]		

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
				TRIM([LeadSystemCode])
				,TRIM([LeadSystemSecurityCode])
				,TRIM([PartnerSystemCode001])			
				,TRIM([PartnerSystemSecurityCode001])
				,TRIM([PartnerSystemCode002])
				,TRIM([PartnerSystemSecurityCode002])
				,TRIM([PartnerSystemCode003])
				,TRIM([PartnerSystemSecurityCode003])
				,TRIM([PartnerSystemCode004])
				,TRIM([PartnerSystemSecurityCode004])
				,TRIM([PartnerSystemCode005])
				,TRIM([PartnerSystemSecurityCode005])
								
			-- OUTPUTS				
				,CAST( TRIM( ISNULL( [LeadSystemCode], N'' ))				AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [LeadSystemSecurityCode], N'' ))		AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemCode001], N''))			AS NVARCHAR(100) )			 
				,CAST( TRIM( ISNULL( [PartnerSystemSecurityCode001], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemCode002], N'' ))			AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemSecurityCode002], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemCode003], N'' ))			AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemSecurityCode003], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemCode004], N'' ))			AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemSecurityCode004], N'' )) AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemCode005], N'' ))			AS NVARCHAR(100) )
				,CAST( TRIM( ISNULL( [PartnerSystemSecurityCode005], N'' )) AS NVARCHAR(100) )
									
				,[Meta_ETLProcessID]
				,N'MANUAL.SECIDNMAP' 
				,[Meta_LoadDateTime]
				,NULL												AS [Meta_SourceSysExportDateTime]
				,[Meta_LoadDateTime]								AS [Meta_EffectFromDateTime]		
				,CAST( N'9999-12-31' AS DATETIME2 )					AS [Meta_EffectToDateTime]
				,1													AS [Meta_ActiveRow]
		FROM	tmp.[Manual_SecurityIdentifierMappings]
		WHERE	Meta_LoadDateTime		=	@LoadDateTime ;
			  
	END TRY
	
	BEGIN CATCH

		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
        SET @error		=	ERROR_NUMBER()
        SET @message	=	ERROR_MESSAGE()

		RAISERROR('etl.MANUAL_LoadStgSecurityIdentifierMappings : %d : %s', 16, 1, @error, @message);
		RETURN (-1);

	END CATCH

END
GO


