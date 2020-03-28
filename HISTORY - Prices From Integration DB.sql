-- Source:			Production Copy of Integration DB
-- Destination:		Temp PACER_Prices table 

	DECLARE		@LoadDateTime	AS DATETIME2;

		--		SELECT	COUNT( * ) FROM	inv.Prices;
		--		SELECT	* FROM	inv.Prices;
		--		SELECT	* FROM	DWH.tmp.PACER_Transactions;
		--		SELECT	* FROM	DWH.tmp.PACER_Prices;
		--		SELECT	* FROM	DWH.stg.PACER_Prices;
	
	--	Set LoadDatetime to date \ time of last transaction trade date?
	SET		@LoadDateTime	=	'2019-10-01 00:00:30.000'			--	NOTE!!! MUST INCLUDE A TIME PART i.e. not all 0's
	
		--		exec etl.PACER_LoadStgPrices @LoadDateTime

	PRINT @LoadDateTime;

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
	FROM	[CAL_JBETL_PROD_COPY].inv.Prices p
	;


	/*

	SELECT	COUNT(*) 
	FROM	DWH.dv.LinkPrices	lp

	SELECT * 
	FROM	DWH.dv.LinkPrices	lp

	INNER JOIN DWH.dv.SatPrices	sp
	ON		lp.HKeyPrice	=	sp.HKeyPrice
	;

	SELECT * 
	FROM	DWH.dv.LinkFXRates
	;

	*/




