CREATE PROC [etl].[PACER_LoadStgTransactions]	(
													@LoadDateTime	DATETIME2
												)
WITH EXECUTE AS OWNER 
AS

	/*
			Author:			Paul Loh
			Date:			2019-08-07
			Description:	Load Pacer Transactions to Staging Layer
			Changes:		
	*/	

SET XACT_ABORT, NOCOUNT ON;
BEGIN

	BEGIN TRY

		DECLARE  @TranCount					INT = 0;
	

	-- Re-Run for exactly the same Load Datetime
		DELETE 	FROM [stg].[PACER_Transactions] 
		WHERE	Meta_LoadDateTime	=	@LoadDateTime ;
	

	--	Set to inactive the previous active rows 
		UPDATE		[stg].[PACER_Transactions] 
		SET
					[Meta_EffectToDateTime]			=	DATEADD( MILLISECOND, -1, @LoadDateTime ),
					[Meta_ActiveRow]				=	0
		FROM		[stg].[PACER_Transactions] t
		WHERE		t.Meta_LoadDateTime				<>	@LoadDateTime;


								
		INSERT INTO [stg].[PACER_Transactions]
				   (
						-- INPUTS 
						[In_TRANNUM],
						[In_PORTCODE],
						[In_SECID],
						[In_TRANTYPE],
						[In_FOOTNOTE],
						[In_CLASS],
						[In_STATUS],
						[In_TRADDATE],
						[In_SHAREPAR],
						[In_PRICEU],
						[In_PRICCURR],
						[In_NETAMTC],
						[In_GAINC],
						[In_ACCRINTC],
						[In_ACCRINTU],
						[In_TAXLOT],
						[In_ORPARVAL],
						[In_SETTDATE],
						[In_ACTUSETT],
						[In_SETTCURR],
						[In_ENTRDATE],
						[In_MISC1U],
						[In_MISC2U],
						[In_MISC3U],
						[In_MISC4U],
						[In_MISC5U],
						[In_MISC6U],
						[In_MISCTOTU],						
						[In_COMMISSU],
						[In_COMMISSC],
						[In_BROKCODE],
						[In_ACQUDATE],
						[In_CREDITS],
						[In_SUBPORTF],
						[In_IMPCOMMC],
						[In_COSTOTLC],
						[In_CPTYCODE],
						[In_ANNOT],
						[In_GAINFXC],
						[In_TRADTYPE],
						[In_BROKFINS],
						[In_BROKNAME],
						[In_COSTOTLU],
						[In_CPTYNAME],
						[In_CREDITC],
						[In_CREDITU],
						[In_DEBITC],
						[In_DEBITS],
						[In_DEBITU],
						[In_DURATION],
						[In_EFFEDATE],
						[In_ENTRNAME],
						[In_ENTROPER],
						[In_ENTRTIME],
						[In_FORNCASH],
						[In_FXRATE],
						[In_FXRATEPS],
						[In_FXRATESB],
						[In_GAINFXU],
						[In_GROSAMTC],
						[In_GROSAMTU],
						[In_IMPCOMMU],
						[In_LOCANAME],
						[In_LOCATION],
						[In_MISC1C],
						[In_MISC2C],
						[In_MISC3C],
						[In_MISC4C],
						[In_MISC5C],
						[In_MISC6C],
						[In_MISCTOTC],
						[In_MODIDATE],
						[In_MODIOPER],
						[In_MODITIME],
						[In_ORDRNUM],
						[In_PRICEC],
						[In_STRATGCD],
						[In_STRATGIS],
						[In_STRATGMS],
						[In_STRATGNM],
						[In_STRATGTY],
						[In_TRADNUM],
						[In_YLDCOST],
						[In_YLDTRAN],
						[In_NETAMTU],
						[In_GAINU],
						[In_EXCUM],
						[In_EXREFNUM],
						[In_MISCCODS],


						-- OUTPUTS 
						[Out_TRANNUM]	
						,[Out_TRANNUM_Original]
						,[Out_PORTCODE]
						,[Out_SECID]
						,[Out_TRANTYPE]
						,[Out_FOOTNOTE]
						,[Out_CLASS]
						,[Out_TRADDATE]
						,[Out_SETTDATE]
						,[Out_BROKCODE]
						,[Out_SHAREPAR]

						-- ISO \ Swift converted currency codes 
						,[Out_PriceCcyISO]
						,[Out_SettleCcyISO]

						,[Out_FXRATE]
						,[Out_FXRATEPS]
						,[Out_FXRATESB]
						,[Out_PRICEU]
						,[Out_PRICCURR]
						,[Out_SETTCURR]
						,[Out_GROSAMTU]
						,[Out_COMMISSU]
						,[Out_MISCTOTU]
						,[Out_NETAMTU]
						,[Out_COSTOTLU]
						,[Out_GAINU]
						,[Out_GROSAMTC]
						,[Out_COMMISSC]
						,[Out_MISCTOTC]
						,[Out_NETAMTC]
						,[Out_COSTOTLC]
						,[Out_GAINC]

						-- Calculated ?!?
						,[Out_QuantityChange]
						,[Out_CostChangeLC]
						,[Out_CostChangeBC]

						,[Out_DEBITU]
						,[Out_CREDITU]
						,[Out_DEBITS]
						,[Out_CREDITS]
						,[Out_DEBITC]
						,[Out_CREDITC]

						-- Calculated ?!?
						,[Out_NetCashLC]					
						,[Out_NetCashSC]					
						,[Out_NetCashBC]

						,[Out_TRADTYPE]
						,[Out_ANNOT]
						,[Out_EXCUM]
						,[Out_EXREFNUM]
						
						-- Miscellaneous codes - BC
						,[Out_MISC1U]
						,[Out_MISC2U]
						,[Out_MISC3U]
						,[Out_MISC4U]
						,[Out_MISC5U]
						,[Out_MISC6U]

						-- Miscellaneous codes - LC
						,[Out_MISC1C]
						,[Out_MISC2C]
						,[Out_MISC3C]
						,[Out_MISC4C]
						,[Out_MISC5C]
						,[Out_MISC6C]

						,[Out_MISCCODS]						
						,[Out_STATUS]
						,[Out_ENTRDATE]
						,[Out_ENTRTIME]
						,[Out_ENTRDATETIME]
						,[Out_EFFEDATE]
						,[Out_MODIDATE]
						,[Out_MODITIME]
						,[Out_MODIDATETIME]
						
						-- ,[Out_HKeyLinkTransactions]

						,[Out_TransactionPL]
						
						-- ,[Out_HDiffTransactionPL]
						
						,[Out_SeqEntryDateTime]

						--,[Out_HKeyPORTCODE]
						--,[Out_HKeySECID]		
						--,[Out_HKeyBROKCODE]		
						--,[Out_HKeyPriceCcyISO]		
						--,[Out_HKeySettleCcyISO]
						
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
						[TRANNUM],
						[PORTCODE] ,
						[SECID] ,
						[TRANTYPE] ,
						[FOOTNOTE] ,
						[CLASS] ,
						[STATUS] ,
						[TRADDATE] ,
						[SHAREPAR] ,
						[PRICEU] ,
						[PRICCURR] ,
						[NETAMTC] ,
						[GAINC] ,
						[ACCRINTC] ,
						[ACCRINTU] ,
						[TAXLOT] ,
						[ORPARVAL] ,
						[SETTDATE] ,
						[ACTUSETT] ,
						[SETTCURR] ,
						[ENTRDATE] ,
						[MISC1U] ,
						[MISC2U] ,
						[MISC3U] ,
						[MISC4U] ,
						[MISC5U] ,
						[MISC6U] ,
						[MISCTOTU] ,			
						[COMMISSU] ,			
						[COMMISSC] ,
						[BROKCODE] ,
						[ACQUDATE] ,
						[CREDITS] ,
						[SUBPORTF] ,
						[IMPCOMMC] ,
						[COSTOTLC] ,
						[CPTYCODE] ,
						[ANNOT] ,
						[GAINFXC] ,
						[TRADTYPE] ,
						[BROKFINS] ,
						[BROKNAME] ,
						[COSTOTLU] ,
						[CPTYNAME] ,
						[CREDITC] ,
						[CREDITU] ,
						[DEBITC] ,
						[DEBITS] ,
						[DEBITU] ,
						[DURATION] ,
						[EFFEDATE] ,
						[ENTRNAME] ,
						[ENTROPER] ,
						[ENTRTIME] ,
						[FORNCASH] ,
						[FXRATE] ,
						[FXRATEPS] ,
						[FXRATESB] ,
						[GAINFXU] ,
						[GROSAMTC] ,
						[GROSAMTU] ,
						[IMPCOMMU] ,
						[LOCANAME] ,
						[LOCATION] ,
						[MISC1C] ,
						[MISC2C] ,
						[MISC3C] ,
						[MISC4C] ,
						[MISC5C] ,
						[MISC6C] ,
						[MISCTOTC] ,
						[MODIDATE] ,
						[MODIOPER] ,
						[MODITIME] ,
						[ORDRNUM] ,
						[PRICEC] ,
						[STRATGCD] ,
						[STRATGIS] ,
						[STRATGMS] ,
						[STRATGNM] ,
						[STRATGTY] ,
						[TRADNUM] ,
						[YLDCOST] ,
						[YLDTRAN] ,
						[NETAMTU] ,
						[GAINU] ,
						[EXCUM] ,
						[EXREFNUM] ,
						[MISCCODS] ,


		-- OUTPUTS
			 CAST((case when LEFT(TRIM(TRANNUM),2) = N'TC' then substring(TRIM(TRANNUM),3,9) else TRANNUM end) as int)			AS OutTranNum

			,TRIM(TRANNUM)		AS [Out_TRANNUM_Original]			 
			,TRIM([PORTCODE])	AS PortCode
			,(case when TRIM(SECID) = N'CASH' then N'PCASH' + TRIM(PRICCURR) else TRIM(SECID) end)						AS SecID

			,TRIM([TRANTYPE])				AS TranType
			,TRIM(IsNull(t.FOOTNOTE, ''))	AS Footnote

			,TRIM([CLASS])					AS Class
			
			,CAST((	CASE	WHEN TRIM(t.[TRADDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[TRADDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[TRADDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[TRADDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[TRADDATE] ), 5, 2) 
							END ) AS DATETIME2 )																		AS TradDate	

			,CAST((	CASE	WHEN TRIM(t.[SETTDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[SETTDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[SETTDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[SETTDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[SETTDATE] ), 5, 2) 
							END ) AS DATETIME2 )																		AS SettDate	

			,TRIM([BROKCODE]) as BrokCode
			,CAST(SHAREPAR as numeric(38, 20)) as SharePar

			-- TBD:		ISO \ Swift converted currency codes	- Business Logic?
			,COALESCE( c1.[CurrencyCode], N'MISSING_MANDATORY_BK')		AS PriceCcyISO
			,COALESCE( c2.[CurrencyCode], N'MISSING_MANDATORY_BK')		AS SettleCcyISO

			,cast([FXRATE] as numeric(38, 20)) as FxRate
			,cast([FXRATEPS] as numeric(38, 20)) as FxRatePS
			,cast([FXRATESB] as numeric(38, 20)) as FxRateSB
			,cast([PRICEU] as numeric(38, 20)) as PriceEU

			,TRIM(ISNULL(PRICCURR, '')) as PricCurr
			,TRIM(ISNULL(SETTCURR, '')) as SetCurr

			,cast([GROSAMTU] as numeric(38, 20)) as GrosAmtU
			,cast([COMMISSU] as numeric(38, 20)) as CommissU
			,cast([MISCTOTU] as numeric(38, 20)) as MiscTotU
			,cast([NETAMTU] as numeric(38, 20)) as NetAmtU
			,cast([COSTOTLU] as numeric(38, 20)) as CostTotU
			,cast([GAINU] as numeric(38, 20)) as GainU

			,cast([GROSAMTC] as numeric(38, 20)) as GrosAmtC
			,cast([COMMISSC] as numeric(38, 20)) as CommissC
			,cast([MISCTOTC] as numeric(38, 20)) as MiscTotC
			,cast([NETAMTC] as numeric(38, 20)) as NetAmtC
			,cast([COSTOTLC] as numeric(38, 20)) as CostTotC
			,cast([GAINC] as numeric(38, 20)) as GainC

			,(case when TRIM(ISNULL(t.TRANTYPE, '')) ='B' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HC' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HG' then CAST(SHAREPAR as numeric(38, 20))
			  else (case when TRIM(ISNULL(t.TRANTYPE, '')) = 'S' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HC' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HG' then -CAST(t.SHAREPAR as numeric(38, 20)) 
			  else 0 end) end) as QuantityChange

			,(case when TRIM(ISNULL(t.TRANTYPE, '')) ='B' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HG' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'OX' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'UA' 
			  then CAST(NETAMTU as numeric(38, 20))
			  else (case when (TRIM(ISNULL(t.TRANTYPE, '')) = 'S' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HG' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'UA') 
			  OR (TRIM(ISNULL(t.TRANTYPE, '')) ='B' and TRIM(ISNULL(t.FOOTNOTE, '')) = 'OX') then -CAST(COSTOTLU as numeric(38, 20)) 
			  else 0 end) end) as CostChangeLC

			,(case when TRIM(ISNULL(t.TRANTYPE, '')) ='B' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HG' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'OX' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'UA' 
			  then CAST(NETAMTC as numeric(38, 20))
			  else (case when (TRIM(ISNULL(t.TRANTYPE, '')) = 'S' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'HG' and TRIM(ISNULL(t.FOOTNOTE, '')) != 'UA') 
			  OR (TRIM(ISNULL(t.TRANTYPE, '')) ='B' and TRIM(ISNULL(t.FOOTNOTE, '')) = 'OX') then -CAST(COSTOTLC as numeric(38, 20)) 
			  else 0 end) end) as CostChangeBC

			,CAST( TRIM( ISNULL( DEBITU, '0.0') ) AS NUMERIC (38, 20) )		AS DebitU
			,CAST( TRIM( ISNULL( CREDITU, '0.0') ) AS NUMERIC (38, 20) )	AS CreditU
			,CAST( TRIM( ISNULL( DEBITS, '0.0') ) AS NUMERIC (38, 20) )		AS DebitS
			,CAST( TRIM( ISNULL( CREDITS, '0.0') ) AS NUMERIC (38, 20) )	AS CreditS
			,CAST( TRIM( ISNULL( DEBITC, '0.0') ) AS NUMERIC (38, 20) )		AS DebitC
			,CAST( TRIM( ISNULL( CREDITC, '0.0') ) AS NUMERIC (38, 20) )	AS CreditC

			,	CAST( TRIM( ISNULL( DEBITU, '0.0') ) AS NUMERIC (38, 20) )	- 
				CAST( TRIM( ISNULL( CREDITU, '0.0') ) AS NUMERIC (38, 20) )									AS NetCashLC

			,	CAST( TRIM( ISNULL( DEBITS, '0.0') ) AS NUMERIC (38, 20) )	- 
				CAST( TRIM( ISNULL( CREDITS, '0.0') ) AS NUMERIC (38, 20) )									AS NetCashSC

			,	CAST( TRIM( ISNULL( DEBITC, '0.0') ) AS NUMERIC (38, 20) )	- 
				CAST( TRIM( ISNULL( CREDITC, '0.0') ) AS NUMERIC (38, 20) )									AS NetCashBC	
				

			,ISNULL(TRIM(TRADTYPE), '') as TradType
			,ISNULL(TRIM(ANNOT), '')	as Annot
			,ISNULL(TRIM(EXCUM), '')	as ExCum
			,CAST(EXREFNUM as int)		as ExtRefNum

			,CAST(MISC1U as numeric(38, 20)) as Misc1U
			,CAST(MISC2U as numeric(38, 20)) as Misc2U
			,CAST(MISC3U as numeric(38, 20)) as Misc3U
			,CAST(MISC4U as numeric(38, 20)) as Misc4U
			,CAST(MISC5U as numeric(38, 20)) as Misc5U
			,CAST(MISC6U as numeric(38, 20)) as Misc6U

			,CAST(MISC1C as numeric(38, 20)) as Misc1C
			,CAST(MISC2C as numeric(38, 20)) as Misc2C
			,CAST(MISC3C as numeric(38, 20)) as Misc3C
			,CAST(MISC4C as numeric(38, 20)) as Misc4C
			,CAST(MISC5C as numeric(38, 20)) as Misc5C
			,CAST(MISC6C as numeric(38, 20)) as Misc6C

			,TRIM(MISCCODS)					as MiscCods
			,TRIM([STATUS])					as [Status]

			,CAST((	CASE	WHEN TRIM(t.[ENTRDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[ENTRDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[ENTRDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[ENTRDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[ENTRDATE] ), 5, 2) 
							END ) AS DATETIME2 )												AS EntrDate

			,CAST(TRIM(ENTRTIME) as time(7))													AS EntrTime

			--,CAST((case when substring(TRIM(ENTRDATE),1,2)>=60 then '19' else '20' end)+ substring(TRIM(ENTRDATE),1,2) + '-' +
			--substring(TRIM(ENTRDATE),3,2) + '-' + substring(TRIM(ENTRDATE),5,2) + 'T' + TRIM(ENTRTIME) as datetime2) as EntrDateTime
			
			,CAST((	CASE	WHEN TRIM(t.[ENTRDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[ENTRDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[ENTRDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[ENTRDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[ENTRDATE] ), 5, 2) + 'T' 
									+ TRIM(ENTRTIME)
							END ) AS DATETIME2 )												AS EntrDateTime

			,CAST((	CASE	WHEN TRIM(t.[EFFEDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[EFFEDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[EFFEDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[EFFEDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[EFFEDATE] ), 5, 2) 
							END ) AS DATETIME2 )												AS EffectiveDate

			,CAST((	CASE	WHEN TRIM(t.[MODIDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[MODIDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[MODIDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[MODIDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[MODIDATE] ), 5, 2) 
							END ) AS DATETIME2 )												AS ModiDate

			,CAST((case when ISNULL(TRIM(MODITIME), '') = '' then NULL else 
				  (TRIM(MODITIME)) end) as time(7))												AS ModiTime
				  				   			
			,CAST((	CASE	WHEN TRIM(t.[MODIDATE]) = N'' 
							THEN N'1901-01-01' 
							ELSE (	CASE	WHEN SUBSTRING (TRIM( t.[MODIDATE] ), 1, 2) > 60 
											THEN N'19' ELSE N'20' END ) 
									+ SUBSTRING( TRIM( t.[MODIDATE] ), 1, 2) + '-' 
									+ SUBSTRING( TRIM( t.[MODIDATE] ), 3, 2) + '-' 
									+ SUBSTRING( TRIM( t.[MODIDATE] ), 5, 2) + 'T' 
									+ TRIM(t.[MODITIME])
							END ) AS DATETIME2 )												AS ModiDateTime
												
			---- Transaction Payload - Concatenated string of transaction attributes identifying a transaction at a specific point in time.			
				---- Hash Diff of Transaction Payload 
			,CONCAT_WS( N'|', 				
				CASE WHEN TRANNUM IS NOT NULL
				THEN CASE WHEN LEFT(TRIM(TRANNUM),2) = N'TC' 
						THEN SUBSTRING( TRIM( TRANNUM ),3,9) ELSE TRANNUM END	 
				ELSE N'' END , 
				TRIM( ISNULL([PORTCODE], N'') ) ,
				TRIM( ISNULL([SECID], N'') ) ,
				TRIM( ISNULL([TRANTYPE], N'') ) , 
				TRIM( ISNULL([CLASS], N'') ) ,
				TRIM( ISNULL([STATUS], N'') ) ,
				TRIM( ISNULL([TRADDATE], N'') ) ,
				TRIM( ISNULL([SHAREPAR], N'') ) ,
				TRIM( ISNULL([PRICEU], N'') ) ,
				TRIM( ISNULL([PRICCURR], N'') ) ,
				TRIM( ISNULL([NETAMTC], N'') ) ,
				TRIM( ISNULL([GAINC], N'') ) ,
				TRIM( ISNULL([ACCRINTC], N'') ) ,
				TRIM( ISNULL([ACCRINTU], N'') ) ,
				TRIM( ISNULL([TAXLOT], N'') ) ,
				TRIM( ISNULL([ORPARVAL], N'') ) ,
				TRIM( ISNULL([SETTDATE], N'') ) ,
				TRIM( ISNULL([ACTUSETT], N'') ) ,
				TRIM( ISNULL([SETTCURR], N'') ) ,
				TRIM( ISNULL([ENTRDATE], N'') ) ,
				TRIM( ISNULL([MISC1U], N'') ) ,
				TRIM( ISNULL([MISC2U], N'') ) ,
				TRIM( ISNULL([MISC3U], N'') ) ,
				TRIM( ISNULL([MISC4U], N'') ) ,
				TRIM( ISNULL([MISC5U], N'') ) ,
				TRIM( ISNULL([MISC6U], N'') ) ,
				TRIM( ISNULL([MISCTOTU], N'') ) ,
				TRIM( ISNULL([COMMISSU], N'') ) ,
				TRIM( ISNULL([COMMISSC], N'') ) ,
				TRIM( ISNULL([BROKCODE], N'') ) ,
				-- TRIM( ISNULL([ACQUDATE], N'') ) ,
				TRIM( ISNULL([CREDITS], N'') ) ,
				TRIM( ISNULL([SUBPORTF], N'') ) ,
				TRIM( ISNULL([IMPCOMMC], N'') ) ,
				TRIM( ISNULL([COSTOTLC], N'') ) ,
				TRIM( ISNULL([CPTYCODE], N'') ) ,
				TRIM( ISNULL([ANNOT], N'') ) ,
				TRIM( ISNULL([GAINFXC], N'') ) ,
				TRIM( ISNULL([TRADTYPE], N'') ) ,
				TRIM( ISNULL([BROKFINS], N'') ) ,
				TRIM( ISNULL([BROKNAME], N'') ) ,
				TRIM( ISNULL([COSTOTLU], N'') ) ,
				TRIM( ISNULL([CPTYNAME], N'') ) ,
				TRIM( ISNULL([CREDITC], N'') ) ,
				TRIM( ISNULL([CREDITU], N'') ) ,
				TRIM( ISNULL([DEBITC], N'') ) ,
				TRIM( ISNULL([DEBITS], N'') ) ,
				TRIM( ISNULL([DEBITU], N'') ) ,
				TRIM( ISNULL([DURATION], N'') ) ,
				TRIM( ISNULL([EFFEDATE], N'') ) ,
				TRIM( ISNULL([ENTRNAME], N'') ) ,
				TRIM( ISNULL([ENTROPER], N'') ) ,
				TRIM( ISNULL([ENTRTIME], N'') ) ,
				TRIM( ISNULL([FORNCASH], N'') ) ,
				TRIM( ISNULL([FXRATE], N'') ) ,
				TRIM( ISNULL([FXRATEPS], N'') ) ,
				TRIM( ISNULL([FXRATESB], N'') ) ,
				TRIM( ISNULL([GAINFXU], N'') ) ,
				TRIM( ISNULL([GROSAMTC], N'') ) ,
				TRIM( ISNULL([GROSAMTU], N'') ) ,
				TRIM( ISNULL([IMPCOMMU], N'') ) ,
				TRIM( ISNULL([LOCANAME], N'') ) ,
				TRIM( ISNULL([LOCATION], N'') ) ,
				TRIM( ISNULL([MISC1C], N'') ) ,
				TRIM( ISNULL([MISC2C], N'') ) ,
				TRIM( ISNULL([MISC3C], N'') ) ,
				TRIM( ISNULL([MISC4C], N'') ) ,
				TRIM( ISNULL([MISC5C], N'') ) ,
				TRIM( ISNULL([MISC6C], N'') ) ,
				TRIM( ISNULL([MISCTOTC], N'') ) ,
				TRIM( ISNULL([MODIDATE], N'') ) ,
				TRIM( ISNULL([MODIOPER], N'') ) ,
				TRIM( ISNULL([MODITIME], N'') ) ,
				TRIM( ISNULL([ORDRNUM], N'') ) ,
				TRIM( ISNULL([PRICEC], N'') ) ,
				TRIM( ISNULL([STRATGCD], N'') ) ,
				TRIM( ISNULL([STRATGIS], N'') ) ,
				TRIM( ISNULL([STRATGMS], N'') ) ,
				TRIM( ISNULL([STRATGNM], N'') ) ,
				TRIM( ISNULL([STRATGTY], N'') ) ,
				TRIM( ISNULL([TRADNUM], N'') ) ,
				TRIM( ISNULL([YLDCOST], N'') ) ,
				TRIM( ISNULL([YLDTRAN], N'') ) ,
				TRIM( ISNULL([NETAMTU], N'') ) ,
				TRIM( ISNULL([GAINU], N'') ) ,
				TRIM( ISNULL([EXCUM], N'') ) ,
				TRIM( ISNULL([EXREFNUM], N'') ) ,
				TRIM( ISNULL([MISCCODS], N'') ) )							AS	TransactionPL
				
			-- Transaction sequence number 
				-- This is defined by entry date\time into the Pacer source system and determines the lastest (therefore active) record. 
			,CAST (
					(case when substring(TRIM(ENTRDATE),1,2)>=60 then '19' else '20' end)+ TRIM(ENTRDATE) +
						substring(TRIM(ENTRTIME),1,2) + substring(TRIM(ENTRTIME),4,2) + substring(TRIM(ENTRTIME),7,2) AS BIGINT)  AS TransSeq
						
			,t.[Meta_ETLProcessID]
			,N'PACER.TRANS'						AS RecordSource
			,t.Meta_LoadDateTime				AS [Meta_LoadDateTime]	
			,NULL								AS [Meta_SourceSysExportDateTime]
			,t.Meta_LoadDateTime				AS [Meta_EffectFromDateTime]		
			,CAST(N'9999-12-31' AS DATETIME2)	AS [Meta_EffectToDateTime]
			,1									AS [Meta_ActiveRow]

		FROM [tmp].[PACER_Transactions] t
		
		LEFT JOIN (
						SELECT		h.HKeyCurrency, h.CurrencyCode, s.SSCCode
						FROM		dv.HubCurrencies h
						LEFT JOIN	dv.SatCurrencies s
						ON			h.HKeyCurrency = s.HKeyCurrency
						WHERE		COALESCE( s.Meta_LoadEndDateTime, CAST(N'9999-12-31' AS DATETIME2)) = CAST(N'9999-12-31' AS DATETIME2)
					) AS c1
		ON	c1.[SSCCode] = TRIM(t.[PRICCURR])
		
		LEFT JOIN (
						SELECT		h.HKeyCurrency, h.CurrencyCode, s.SSCCode
						FROM		dv.HubCurrencies h
						LEFT JOIN	dv.SatCurrencies s
						ON			h.HKeyCurrency = s.HKeyCurrency
						WHERE		COALESCE( s.Meta_LoadEndDateTime, CAST(N'9999-12-31' AS DATETIME2)) = CAST(N'9999-12-31' AS DATETIME2)
					) AS c2
		ON	c2.[SSCCode] = TRIM(t.[SETTCURR])
		
		WHERE	t.Meta_LoadDateTime		=	@LoadDateTime
		;



		UPDATE stg.[PACER_Transactions] 
			
			SET		Out_HKeyLinkTransactions	=	
					-- Hash value of Business Key 			
					-- Transaction Link Hash is based on Transaction Number and referenced hub Business Keys				
					HASHBYTES(N'SHA1', UPPER( 
												CONCAT_WS(N'|', 
															TRIM( ISNULL( [Out_PortCode], N'' )), 
															TRIM( ISNULL( [Out_SECID], N'' )), 
															TRIM( ISNULL( [Out_BROKCODE], N'' )), 
															TRIM( ISNULL( [Out_PriceCcyISO], N'' )), 
															TRIM( ISNULL( [Out_SettleCcyISO], N'' )), 
															TRIM( ISNULL( TRY_CAST( [Out_TRANNUM] AS NVARCHAR(100) ), N''))											
														))) 		

					, Out_HDiffTransactionPL	=	HASHBYTES(N'SHA1', [Out_TransactionPL] )

					, Out_HKeyPORTCODE			=	CASE WHEN ISNULL( [Out_PortCode], N'') = N''
													THEN	
														0x1111111111111111111111111111111111111111	-- GHOST KEY for unknown 
													ELSE
														HASHBYTES(N'SHA1', UPPER( [Out_PortCode] ))
													END
													
					, Out_HKeySECID				=	CASE WHEN ISNULL( [Out_SECID], N'') = N''
													THEN	
														0x1111111111111111111111111111111111111111	-- GHOST KEY for unknown 
													ELSE
														HASHBYTES(N'SHA1', UPPER( [Out_SECID] ))
													END
													
					, Out_HKeyBROKCODE			=	CASE WHEN ISNULL( [Out_BROKCODE], N'') = N''  
													THEN	
														0x1111111111111111111111111111111111111111	-- GHOST KEY for unknown 
													ELSE
														HASHBYTES(N'SHA1', UPPER( [Out_BROKCODE] ))
													END

					, Out_HKeyPriceCcyISO		=	CASE WHEN ISNULL( [Out_PriceCcyISO], N'') = N''  
													THEN	
														0x1111111111111111111111111111111111111111	-- GHOST KEY for unknown 
													ELSE
														HASHBYTES(N'SHA1', UPPER( [Out_PriceCcyISO] ))
													END
													
					, Out_HKeySettleCcyISO		=	CASE WHEN ISNULL( [Out_SettleCcyISO], N'') = N''  
													THEN	
														0x1111111111111111111111111111111111111111	-- GHOST KEY for unknown 
													ELSE
														HASHBYTES(N'SHA1', UPPER( [Out_SettleCcyISO] ))
													END
													
		FROM	stg.[PACER_Transactions]
		WHERE	Meta_LoadDateTime			=	@LoadDateTime	

	END TRY
	
	BEGIN CATCH
	
		-- ROLLBACK  
		IF XACT_STATE() <> 0 AND @TranCount = 0 		
			ROLLBACK TRANSACTION
					
		DECLARE @error INT, @message VARCHAR(4000)
        
		SET @error		=	ERROR_NUMBER()
		SET @message	=	ERROR_MESSAGE()

		RAISERROR(N'etl.PACER_LoadStgTransactions : %d : %s', 16, 1, @error, @message);
		RETURN (-1)

	END CATCH

END