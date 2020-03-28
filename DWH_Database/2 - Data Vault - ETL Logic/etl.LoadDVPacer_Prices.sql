CREATE PROCEDURE [etl].[PACER_LoadDVPrices](
												@LoadDateTime	DATETIME2
											)
WITH EXECUTE AS OWNER 
AS

--	Load Link
	
	-- Check link already contains Business Keys using Business Key values and not Hash values because of (minute) possibility of hash collisions 
	-- (2 values generating same Hash), which we would want to know about. 
	-- If it occurs (very, very unlikely), error is raised when trying to insert duplicate Hash values into table as its the PK.

	UPDATE		[dv].[LinkPrices] 
		SET		Meta_LastSeenDateTime	=	t.Meta_LoadDateTime
	FROM		[dv].[LinkPrices] l	

	INNER JOIN	stg.PACER_Prices t
	-- ON			l.HKeyPrice				=	t.Out_HKeyPrices
	ON			l.HKeySecurity			=	t.Out_HKeySecID
	AND			l.PriceSource			=	t.Out_PriceSource
	AND			l.PriceType				=	t.Out_PriceType
	AND			l.[PriceDate]			=	t.Out_PriceDate
		
	
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime ;
	

	INSERT INTO		[dv].[LinkPrices] 
			(
				[HKeyPrice]					,			-- Hash of Security Code + Price Date + Price Type + Price Source
				[Meta_LoadDateTime]			,
				[Meta_LastSeenDateTime]		,			-- As no CDC from source used to check duration since data last sent
				[Meta_RecordSource]			,
				[Meta_ETLProcessID]			,			-- FK to ID of import batch audit table	?
		
				[HKeySecurity]				,			--	UIX	-- Hash of SecurityID
				[PriceDate]					,			--	UIX
				[PriceType]					,			--	UIX	
				[PriceSource]							--	UIX
			)
	SELECT 
				t.Out_HKeyPrices			,
				t.[Meta_LoadDateTime]		,
				t.[Meta_LoadDateTime]		,
				t.Meta_RecordSource			,
				t.Meta_ETLProcessID			,

				t.[Out_HKeySecID]			,
				t.Out_PriceDate				,
				t.Out_PriceType				,
				t.Out_PriceSource

	FROM		stg.PACER_Prices t
	WHERE		t.Meta_LoadDateTime		=	@LoadDateTime 

	AND	NOT EXISTS 
		(
			SELECT	*
			FROM	dv.LinkPrices l
			-- WHERE	l.HKeyPrice			=	t.Out_HKeyPrices
			WHERE	l.HKeySecurity		=	t.Out_HKeySecID
			AND		l.[PriceDate]		=	t.Out_PriceDate
			AND		l.PriceType			=	t.Out_PriceType
			AND		l.PriceSource		=	t.Out_PriceSource
		) ;

			

--	Load Satellite

	-- Insert new payloads  

	INSERT INTO [dv].[SatPrices] 
		(
			[HKeyPrice]				,	
			[Meta_LoadDateTime]		,
			[Meta_LoadEndDateTime]	,
			[Meta_RecordSource]		,
			[Meta_ETLProcessID]		,				-- FK to ID of import batch 		
			[HDiffPricePL]			,
					
			[StatusFlag]			,
			[ClosePrice]			,
			[BidPrice]				,
			[AskPrice]				,
			[HighPrice]				,
			[LowPrice]				,
			[TradingVolume]			,
			[Yield]					,
			[EntryDate]				
		)

	SELECT
			t.Out_HKeyPrices, 
			t.Meta_LoadDateTime, 
			CAST( N'9999-12-31' AS DATETIME2 ),		
			t.Meta_RecordSource, 
			t.Meta_ETLProcessID,
			t.Out_HDiffPricePL,

			[Out_StatusFlag]			,
			[Out_ClosePrice]			,
			[Out_BidPrice]				,
			[Out_AskPrice]				,
			[Out_HighPrice]				,
			[Out_LowPrice]				,
			[Out_TradingVolume]			,
			[Out_Yield]					,
			[Out_EntryDate]				
			
	FROM	stg.PACER_Prices t
	WHERE	t.Meta_LoadDateTime	=	@LoadDateTime 
	AND NOT EXISTS 
		(
			SELECT	*							
			FROM	[dv].[SatPrices] s
			WHERE	s.HKeyPrice				=	t.Out_HKeyPrices
			AND		s.HDiffPricePL			=	t.Out_HDiffPricePL
			AND		s.Meta_LoadEndDateTime	=	CAST( N'9999-12-31' AS DATETIME2 )
		) ;
	
	
-- End Dating of Previous Satellite Entries 
	-- Set last Load datetime for existing records to inactive using past point in time before next load datetime

	UPDATE	[dv].[SatPrices] 
		SET		Meta_LoadEndDateTime	=	(	
												SELECT	COALESCE(
																DATEADD( MILLISECOND, -1, MIN( z.Meta_LoadDateTime)), 	  
																CAST( N'9999-12-31' AS DATETIME2 ) 
																)
												FROM	dv.[SatPrices] z
												WHERE	z.HKeyPrice			=	s.HKeyPrice
												AND		z.Meta_LoadDateTime >	s.Meta_LoadDateTime
											)
	FROM	[dv].[SatPrices] s
	WHERE	-- s.Meta_LoadEndDateTime		=	CAST( N'9999-12-31' AS DATETIME2 ) -- AND 
	EXISTS	(
					SELECT  * 
					FROM	stg.PACER_Prices t
					WHERE	t.Meta_LoadDateTime			=	@LoadDateTime		
					AND		t.Out_HKeyPrices			=	s.HKeyPrice
				)
	;

GO



