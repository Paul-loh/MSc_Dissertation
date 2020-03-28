CREATE PROCEDURE [etl].[INITIAL_LOAD_Import_Prices_From_Integration_DB] (
																			@LoadDateTime	DATETIME2
																		)
-- WITH EXECUTE AS OWNER 
AS

--	Author:				Paul Loh	
--	Creation Date:		20200203
--	Description:		DWH Initial Load 
--						
--						Import all Prices from the Integration DB.
-- 
--						Parameters:
--								@LoadDateTime	:	Used to set the timestamp of when the load occurred
--													This will be 1900-01-01 so we have a valid initial set of records to use
--				

TRUNCATE TABLE DWH.tmp.PACER_Prices;

	INSERT INTO		DWH.tmp.PACER_Prices
	(
		[SecID]
		,[IssuerName]
		,[IssueDesc]
		,[Date]
		,[Source]
		,[Type]
		,[Flag]
		,[HighPrice]
		,[LowPrice]
		,[ClosePrice]
		,[BidPrice]
		,[AskPrice]
		,[YieldToBid]
		,[VolumeTraded]
		,[EntryDate]
		,[Meta_ETLProcessID]
		,[Meta_LoadDateTime]
	)

	SELECT	[SecurityCode]
			,NULL 
			,NULL 		
			, SUBSTRING ( CONVERT( VARCHAR, [PriceDate], 112 ) , 3, 6) 	AS PriceDate
			,[PriceSource]
			,[PriceType]
			,[StatusFlag]
			,[HighPrice]
			,[LowPrice]
			,[ClosePrice]
			,[BidPrice]
			,[AskPrice]		
			,[Yield]
			,[TradingVolume]				
			, SUBSTRING ( CONVERT( VARCHAR, [EntryDate], 112 ) , 3, 6) 	AS EntryDate		
			,-1
			,@LoadDateTime	
	FROM	[.].[CAL_JBETL].inv.Prices p
	;

