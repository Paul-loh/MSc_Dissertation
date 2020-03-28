CREATE PROCEDURE [etl].[INITIAL_LOAD_Import_FX_From_Integration_DB] (
																		@LoadDateTime	DATETIME2
																	)
--WITH EXECUTE AS OWNER 
AS

--	Author:				Paul Loh	
--	Creation Date:		20200203
--	Description:		DWH Initial Load 
--						
--						Import all FX rates from the Integration DB.
-- 
--						Parameters:
--								@LoadDateTime	:	Used to set the timestamp of when the load occurred
--													This will be 1900-01-01 so we have a valid initial set of records to use
--													

	TRUNCATE TABLE tmp.PACER_FXRates;

	INSERT INTO		tmp.PACER_FXRates
	(
		[CcyCode]
		,[RateToGBP]
		,[RateDate]
		,[Meta_ETLProcessID]
		,[Meta_LoadDateTime]
	)

	SELECT	
		c1.SSCCode AS CcyCode
		,[RateToGBP]	
		, SUBSTRING ( CONVERT( VARCHAR, [RateDate], 112 ) , 3, 6) 	AS [RateDate]	
		,-1
		,@LoadDateTime	
	FROM		[.].[CAL_JBETL].[inv].[FXRates] f
	LEFT JOIN	[.].[CAL_JBETL].[inv].[Currencies] c1 on f.CurrencyCode	=	c1.CurrencyCode
	WHERE		f.CurrencyCode NOT IN ( 'SDD', 'XAF' )		
				-- No equivalent to translate these codes in inv.Currencies but haven't existed since 1999-12-31
	;

