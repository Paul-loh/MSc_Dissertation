CREATE PROCEDURE [etl].[MANUAL_LoadDVSecurityIdentifierMappings]	(
																		@LoadDateTime	DATETIME2
																	)
WITH EXECUTE AS OWNER 
AS

--	Load reference table   	 
	INSERT INTO		[ref].[RefSecurityIdentifierMappings]
			(				
				[Meta_LoadDateTime]						--	UIX	
				,[Meta_LoadEndDateTime]
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
				
				,[LeadSystemCode]						--	UIX	| Initially Pacer 
				,[LeadSystemSecurityCode]				--	UIX	
				,[PartnerSystemCode001]					--	UIX	| Initially HSBC.Net Client View
				,[PartnerSystemSecurityCode001]			--	UIX	| 
				,[PartnerSystemCode002]					-- LP Analyst?
				,[PartnerSystemSecurityCode002]			
				,[PartnerSystemCode003]					-- Spare
				,[PartnerSystemSecurityCode003]			
				,[PartnerSystemCode004]					-- Spare
				,[PartnerSystemSecurityCode004]			
				,[PartnerSystemCode005]					-- Spare
				,[PartnerSystemSecurityCode005]			
			)

	SELECT 	
				[Meta_LoadDateTime]
				,CAST( N'9999-12-31' AS DATETIME2)	
				,[Meta_RecordSource]
				,[Meta_ETLProcessID]
			
				,[Out_LeadSystemCode]
				,[Out_LeadSystemSecurityCode]
				,[Out_PartnerSystemCode001]
				,[Out_PartnerSystemSecurityCode001]
				,[Out_PartnerSystemCode002]
				,[Out_PartnerSystemSecurityCode002]
				,[Out_PartnerSystemCode003]
				,[Out_PartnerSystemSecurityCode003]
				,[Out_PartnerSystemCode004]
				,[Out_PartnerSystemSecurityCode004]
				,[Out_PartnerSystemCode005]
				,[Out_PartnerSystemSecurityCode005]
				
	FROM		[stg].[Manual_SecurityIdentityMappings]		t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 
	;
	
-- End Dating of Previous Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[ref].[RefSecurityIdentifierMappings] 
		SET		Meta_LoadEndDateTime		=	(	
													SELECT	COALESCE(
																	DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																	CAST( N'9999-12-31' AS DATETIME2 ) 
																	)
													FROM	[ref].[RefSecurityIdentifierMappings]  z
													WHERE	z.Meta_LoadDateTime >	s.Meta_LoadDateTime			
												)
	FROM	[ref].[RefSecurityIdentifierMappings] s
	WHERE	s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) 
	;

GO


