CREATE PROCEDURE [etl].[PACER_LoadDVPortfolioMasterSubsidiaries]	(
																		@LoadDateTime	DATETIME2
																	)
WITH EXECUTE AS OWNER 
AS

--	Load Link	

	-- Check if Link already exists using Business Key hashes 	
	UPDATE		[dv].[LinkPortfolioMasterSubsidiary] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[LinkPortfolioMasterSubsidiary] h

	INNER JOIN	stg.PACER_MasterPortfolioSubsidiaries t

	ON			h.[HKeyMasterPortfolioCode]			=	t.[Out_HKeyHubMasterCode]
	AND			h.[HKeySubsidiaryPortfolioCode]		=	t.[Out_HKeyHubSubPortfCode]
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;

   	 
	INSERT INTO		[dv].[LinkPortfolioMasterSubsidiary]
			(
				[HKeyLinkPortfolioMasterSubsidiary], 
				Meta_LoadDateTime, 
				Meta_LastSeenDateTime,
				Meta_RecordSource, 				
				Meta_ETLProcessID,

				[HKeyMasterPortfolioCode],		
				[HKeySubsidiaryPortfolioCode],	
				[MasterPortfolioCode],					--	UIX					
				[SubsidiaryPortfolioCode]				--	UIX					
			)
	SELECT DISTINCT
				t.[Out_HKeyLinkPortfolioMasterSubsidiary], 
				t.Meta_LoadDateTime, 
				t.Meta_LoadDateTime,		
				t.Meta_RecordSource, 
				t.Meta_ETLProcessID,
				
				t.[Out_HKeyHubMasterCode],
				t.[Out_HKeyHubSubPortfCode],
				t.[Out_MasterCode],
				t.[Out_SubPortfCode]

	FROM		stg.PACER_MasterPortfolioSubsidiaries t
	WHERE		t.Meta_LoadDateTime			=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	[dv].[LinkPortfolioMasterSubsidiary] l			
			WHERE 	l.[HKeyMasterPortfolioCode]				=	t.[Out_HKeyHubMasterCode]
			AND		l.[HKeySubsidiaryPortfolioCode]			=	t.[Out_HKeyHubSubPortfCode]			
		) ;
	

--	NOTE:	no Satellite table to the Master \ Subsidiary Link table and record 
--			effectivity dates of each link can be determined by the SatPortfolioMasterType


--	Load Satellite
	-- Insert new pay loads  
	
	
-- End Dating of Previous Satellite Entries 
-- Set last Load datetime for existing records to inactive using past point in time before next load datetime

GO

