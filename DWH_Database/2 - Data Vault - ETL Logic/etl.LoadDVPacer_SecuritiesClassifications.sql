CREATE PROCEDURE [etl].[PACER_LoadDVSecuritiesClassifications]	(
																	@LoadDateTime	DATETIME2
																)
WITH EXECUTE AS OWNER 
AS

/* 
	Author:					Paul Loh
	Business Rule Ref:		N\A
	Description:			Load to data vault Security classifications.
							Mappings of Security Business Keys to Pacer Hierarchy Level Business Keys 
							
							Pacer Hierarchies provided:
								1.	Industry
								2.	Region
								3.	Asset Types
*/

--	Load Hub	
	
	-- Populate Security Hub if security not yet seen by DWH ( Business Key = Security ID )	
	UPDATE		[dv].[HubSecurities] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[HubSecurities] h

	INNER JOIN	stg.PACER_SecurityClassification t
	ON			h.HKeySecurity			=	t.Out_HKeySecurityID
	 
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;
	
	
	INSERT INTO		[dv].[HubSecurities]
			(
				[HKeySecurity]				,			-- Hash of Security Code 
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[SecID]									--	UIX	
			)
	SELECT 
				t.Out_HKeySecurityID		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.[Meta_RecordSource]		,
				t.[Meta_ETLProcessID]		,
								
				t.[Out_SecurityID]

	FROM		stg.PACER_SecurityClassification t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[HubSecurities] h
			WHERE	h.HKeySecurity		=	t.[Out_HKeySecurityID]
		) ;
				


--	Load Links

	-- Populate Security Classification Link Mapping table
	
	-- Insert new payloads  
	INSERT INTO [dv].[LinkSecurityClassification]
	
		(
			HKeyLinkSecurityClassification, 
			Meta_LoadDateTime, 
			Meta_LastSeenDateTime,
			Meta_RecordSource, 
			Meta_ETLProcessID,

			HKeySecurity,			
			HKeyIndustryHierarchyLevel,
			HKeyRegionHierarchyLevel,
			HKeyAssetHierarchyLevel,

			SecID,
			IndustryHierarchyCode,
			RegionHierarchyCode,
			AssetHierarchyCode
		)

	SELECT			
			t.Out_HKeyLinkSecurityClassification,
			t.Meta_LoadDateTime, 
			CAST( N'9999-12-31' AS DATETIME2 ),		
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,
			
			t.Out_HKeySecurityID,	
			t.Out_HKeyIndustryCode,
			t.Out_HKeyRegionCode,
			t.Out_HKeyAssetCatCode,

			t.Out_SecurityID,
			t.Out_IndustryCode,
			t.Out_RegionCode,
			t.Out_AssetCatCode
			
	FROM	stg.PACER_SecurityClassification t
	WHERE	Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[LinkSecurityClassification] s
			WHERE	s.HKeyLinkSecurityClassification	=	t.Out_HKeyLinkSecurityClassification			
		);


--	Populate Security Classification Effectivity Satellite table

	-- Insert new pay loads  
		INSERT INTO [dv].[SatSecurityClassificationEffectivity] 
			(
				[HKeyLinkSecurityClassification],
				[Meta_LoadDateTime],
				[Meta_LoadEndDateTime],
				[Meta_RecordSource],
				[Meta_ETLProcessID],
				[EffectiveFromDateTime],
				[EffectiveToDateTime]
			) 

		SELECT
				t.Out_HKeyLinkSecurityClassification,
				t.Meta_LoadDateTime,
				CAST('9999-12-31' AS DATETIME2),	
				t.Meta_RecordSource,
				t.Meta_ETLProcessID,
				t.Meta_EffectFromDateTime,
				t.Meta_EffectToDateTime
		FROM	stg.PACER_SecurityClassification t
		
		WHERE	t.Meta_LoadDateTime				=	@LoadDateTime 

		AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatSecurityClassificationEffectivity] s
			WHERE	s.HKeyLinkSecurityClassification		=	t.Out_HKeyLinkSecurityClassification
			AND		s.Meta_LoadDateTime						=	@LoadDateTime
		) ;
		

-- End Dating of Previous Effectivity Satellite Entries 

	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime
	UPDATE	[dv].[SatSecurityClassificationEffectivity]
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.[SatSecurityClassificationEffectivity] z
												WHERE	z.HKeyLinkSecurityClassification	=	s.HKeyLinkSecurityClassification
												AND		z.Meta_LoadDateTime					>	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatSecurityClassificationEffectivity] s
	WHERE	s.Meta_LoadEndDateTime	=	CAST( N'9999-12-31' AS DATETIME2 ) 
	AND	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_SecurityClassification t
					WHERE	Meta_LoadDateTime							=	@LoadDateTime		
					AND		t.Out_HKeyLinkSecurityClassification		=	s.HKeyLinkSecurityClassification
				)
	;
	   	 
GO



