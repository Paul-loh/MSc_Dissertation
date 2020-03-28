USE DWH;

--	Populate Dimensions

	--  Dates
	TRUNCATE TABLE dwh.dwh.Dim_Date;
	GO

	INSERT INTO dwh.dwh.Dim_Date
	(	
	  [ID]	
	  ,[CalendarDate]
      ,[Day]
      ,[Month]
      ,[Year]
      ,[Quarter]
      ,[DayOfWeek]
      ,[DayOccInMonth]
      ,[DayOfQuarter]
      ,[DayOfYear]
      ,[WeekNumISO]
      ,[MonthOfQuarter]
      ,[StartOfMonth]
      ,[EndOfMonth]
      ,[StartOfQuarter]
      ,[EndOfQuarter]
      ,[StartOfCalYear]
      ,[EndOfCalYear]
      ,[StartOfFinYear]
      ,[EndOfFinYear]
      ,[d]
      ,[dd]
      ,[ddd]
      ,[dddd]
      ,[m]
      ,[mm]
      ,[mmm]
      ,[mmmm]
      ,[q]
      ,[qqqq]
      ,[yy]
      ,[yyyy]
      ,[FY_m]
      ,[FY_mm]
      ,[FY_q]
      ,[FY_qqqq]
      ,[FY_yy]
      ,[FY_yyyy]
      ,[IsWeekDay]
      ,[IsHolidayUK]
      ,[HolidayUK]
      ,[UpdatedAt]
	)
	  
	SELECT 
	  [DateKey]
      ,[CalendarDate]
      ,[Day]
      ,[Month]
      ,[Year]
      ,[Quarter]
      ,[DayOfWeek]
      ,[DayOccInMonth]
      ,[DayOfQuarter]
      ,[DayOfYear]
      ,[WeekNumISO]
      ,[MonthOfQuarter]
      ,[StartOfMonth]
      ,[EndOfMonth]
      ,[StartOfQuarter]
      ,[EndOfQuarter]
      ,[StartOfCalYear]
      ,[EndOfCalYear]
      ,[StartOfFinYear]
      ,[EndOfFinYear]
      ,[d]
      ,[dd]
      ,[ddd]
      ,[dddd]
      ,[m]
      ,[mm]
      ,[mmm]
      ,[mmmm]
      ,[q]
      ,[qqqq]
      ,[yy]
      ,[yyyy]
      ,[FY_m]
      ,[FY_mm]
      ,[FY_q]
      ,[FY_qqqq]
      ,[FY_yy]
      ,[FY_yyyy]
      ,[IsWeekDay]
      ,[IsHolidayUK]
      ,[HolidayUK]
      ,GETDATE()
	FROM	[CAL_JBETL_PROD_COPY].inv.Calendar;

  		

	--  Currency
	TRUNCATE TABLE [DWH].[dwh].[Dim_Currency];
	GO

	INSERT INTO [DWH].[dwh].[Dim_Currency]
	(
		 [Currency_Code]
		,[Name]
		,[VALID_FROM_DATE]
		,[VALID_TO_DATE]
		,[ACTIVE]
	)

	SELECT 
	[CurrencyCode]
    ,[CurrencyName]
	,GETDATE(),
	NULL,
	1
	FROM	[CAL_JBETL_PROD_COPY].inv.[Currencies];

	----  Investees
	--TRUNCATE TABLE dwh.dwh.Dim_Investee;
	--GO

	--INSERT INTO dwh.dwh.Dim_Investee
	--(	
	--	[INVESTEE]
	--	,[INFERRED]
	--	,[VALID_FROM_DATE]
	--	,[VALID_TO_DATE]
	--	,[ACTIVE]
	--)

	--SELECT 
	--[IssuerName]
 --   ,0
	--,GETDATE(),
	--NULL,
	--1
	--FROM	[CAL_JBETL_PROD_COPY].inv.[Investees];
	  
	--  Pools
	TRUNCATE TABLE dwh.dwh.[Dim_Pool];
	GO
	
	INSERT INTO dwh.dwh.[Dim_Pool]
	(
		[POOL_PORTFOLIO_CODE]
		,[POOL_NAME]
		,[INFERRED]
		,[VALID_FROM_DATE]
		,[VALID_TO_DATE]
		,[ACTIVE]
	)
	
	SELECT DISTINCT 
			MasterCode
			,MasterName
			,0
			,GETDATE()
			,NULL
			,1
	FROM	[CAL_JBETL_PROD_COPY].inv.MasterSubPortfs
	WHERE	MasterType = 'POOL'
	;
	

	--  Portfolios
	TRUNCATE TABLE dwh.dwh.[Dim_Portfolio];
	GO

	INSERT INTO dwh.dwh.[Dim_Portfolio]
	(	
		[PORTFOLIO_CODE]
		,[PORTFOLIO_NAME]
		,[COMPANY_ID]
		,[PORTFOLIO_POOL_CODE]
		,[PORTFOLIO_POOL]
		,[INFERRED]
		,[VALID_FROM_DATE]
		,[VALID_TO_DATE]
		,[ACTIVE]
	)

	SELECT 
		[PortfolioCode]
		,[PortfolioName]
		,NULL
		,NULL
		,NULL
		,0
		,GETDATE()
		,NULL
		,1		
	FROM [CAL_JBETL_PROD_COPY].[inv].[Portfolios]

	--  Securities
	TRUNCATE TABLE dwh.dwh.[Dim_Security];
	GO

	INSERT INTO dwh.dwh.[Dim_Security]
	(
	  [SECURITY_CODE]
	  ,[INVESTEE]
      ,[RESIDENCE]
      ,[EXCHANGE]
      ,[PRICE_CURRENCY]
      ,[ISSUER_NAME]
      ,[SECURITY_DESC]
      ,[INCOME_CURRENCY]
      ,[CURRENT_COUPON]
      ,[OUTSTANDING_SHARES]
      ,[INFERRED]
      ,[VALID_FROM_DATE]
      ,[VALID_TO_DATE]
      ,[ACTIVE]
	)

	SELECT 
		 s.[SecurityCode]
		 ,i.[Investee]
		,s.[ResidenceCtry]
		,s.[ExchangeCtry]
		,s.[PriceCcy]
		,s.[IssuerName]
		,s.[IssueDesc]
		,s.[IncomeCcy]
		,NULL
		,NULL
		,0
		,GETDATE()
		,NULL
		,1		
	FROM		[CAL_JBETL_PROD_COPY].[inv].[Securities] s
	LEFT JOIN	[CAL_JBETL_PROD_COPY].[inv].[Investees] i
	ON			s.SecurityCode	=	i.SecurityCode
	;
	

-- Populate Summary Period Fact Table 

	-- Execute SP in Cursor for set of dates 

	DECLARE @AsAtDate		DATE, 
			@RowsToProcess	INT,
			@CurrentRow		INT,
			@SQL			VARCHAR(1000)

	-- Iterate series of dates 
	
		-- Enable ad hoc distributed queries so we can populate temp table with values from rep.GetNAV stored procedure
		EXEC sp_configure 'show advanced options', 1
		RECONFIGURE
		GO
		EXEC sp_configure 'ad hoc distributed queries', 1
		RECONFIGURE
		GO


	DECLARE  @ReportDates TABLE
					(	
						RowID int not null primary key identity(1,1)
						,AsAtDate DATE
					);

	INSERT INTO @ReportDates	
	SELECT		CalendarDate
	FROM		[CAL_JBETL_PROD_COPY].[inv].[Calendar]
	WHERE		CalendarDate BETWEEN '2018-12-31' AND GETDATE()  
	AND			( CalendarDate = EndOfMonth OR DayOfWeek = 6 ) 
	ORDER BY	CalendarDate DESC;

	SELECT * FROM @ReportDates;
	

	/*	------------------------------------------------------------------	*/
		/*		Manually run per report date	*/

	DROP TABLE IF EXISTS #MyTempTable;

	SELECT * INTO #MyTempTable 
			FROM OPENROWSET( 'SQLNCLI', 'Server=.;Trusted_Connection=yes;', 'EXEC [CAL_JBETL_PROD_COPY].[rep].[GetNAV] ''2019-06-30'';');
			
	INSERT INTO  [DWH].[dwh].[Fact_Investments_Summary]
	(
		[VALUATION_DATE]
		,[POOL_ID]		
		,[PORTFOLIO_ID]
		,[SECURITY_ID]
		,[CURRENCY_ID]
		,[AUDIT_ID]
		,[Holding]
		,[ValuationLC]
		,[ValuationBC]
		,[FXRateLToB]
		,[MTDCapitalGainLC]
		,[MTDSalesLC]
		,[MTDPurchasesLC]
		,[MTDTranscationsLC]
		,[MTDMarketMovementLC]
		,[MTDFXMovementLC]
		,[MTDIncomeLC]
		,[MTDTotalReturnLC]
		,[MTDCapitalGainBC]
		,[MTDSalesBC]
		,[MTDPurchasesBC]
		,[MTDTranscationsBC]
		,[MTDMarketMovementBC]
		,[MTDFXMovementBC]
		,[MTDIncomeBC]
		,[MTDTotalReturnBC]
		,[YTDCapitalGainLC]
		,[YTDSalesLC]
		,[YTDPurchasesLC]
		,[YTDTranscationsLC]
		,[YTDMarketMovementLC]
		,[YTDFXMovementLC]
		,[YTDIncomeLC]
		,[YTDTotalReturnLC]
		,[YTDCapitalGainBC]
		,[YTDSalesBC]
		,[YTDPurchasesBC]
		,[YTDTranscationsBC]
		,[YTDMarketMovementBC]
		,[YTDFXMovementBC]
		,[YTDIncomeBC]
		,[YTDTotalReturnBC]
		,[CalculationDateTime]
	)
					
											
	SELECT 
			t.AsAtDate,
			dp.ID	AS Pool_ID, 
			dpt.ID	AS Portfolio_ID, 
			ds.ID	AS Security_ID, 
			dc.ID	AS Currency_ID, 
			1		AS Audit_ID
			,t.Holding
			,t.ValuationLC 
			,t.[ValuationBC]
			,t.FxRateLtoB
			,t.MTDCapGainLC		AS [MTDCapitalGainLC]
			,t.MTDSellsLC		AS [MTDSalesLC]
			,t.MTDBuysLC		AS [MTDPurchasesLC]
			,t.MTDTransLC		AS [MTDTranscationsLC]
			,NULL				AS [MTDMarketMovementLC]
			,NULL				AS [MTDFXMovementLC]
			,t.MTDIncomeLC		AS [MTDIncomeLC]
			,t.MTDTotRetLC		AS [MTDTotalReturnLC]
			,t.MTDCapGainBC		AS [MTDCapitalGainBC]
			,t.MTDSellsBC		AS [MTDSalesBC]
			,t.MTDBuysLC		AS [MTDPurchasesBC]
			,t.MTDTransBC		AS [MTDTranscationsBC]
			,NULL				AS [MTDMarketMovementBC]
			,NULL				AS [MTDFXMovementBC]
			,t.MTDIncomeBC		AS [MTDIncomeBC]
			,t.MTDTotRetBC		AS [MTDTotalReturnBC]
			,t.YTDCapGainLC		AS [YTDCapitalGainLC]
			,t.YTDSellsLC		AS [YTDSalesLC]
			,t.YTDBuysLC		AS [YTDPurchasesLC]
			,t.YTDTransLC		AS [YTDTranscationsLC]
			,NULL				AS [YTDMarketMovementLC]
			,NULL				AS [YTDFXMovementLC]
			,t.YTDIncomeLC		AS [YTDIncomeLC]
			,t.YTDTotRetLC		AS [YTDTotalReturnLC]
			,t.YTDCapGainBC			AS [YTDCapitalGainBC]
			,t.YTDSellsBC			AS [YTDSalesBC]
			,t.YTDBuysBC			AS [YTDPurchasesBC]
			,t.YTDTransBC			AS [YTDTranscationsBC]
			,NULL					AS [YTDMarketMovementBC]
			,NULL					AS [YTDFXMovementBC]
			,t.YTDIncomeBC			AS [YTDIncomeBC]
			,t.YTDTotRetBC			AS [YTDTotalReturnBC]
			,SYSDATETIME()			AS [CalculationDateTime]
			
	FROM	#MyTempTable t
	LEFT JOIN [DWH].[dwh].[Dim_Pool] dp ON dp.[POOL_PORTFOLIO_CODE] = t.MasterCode 
	LEFT JOIN [DWH].[dwh].[Dim_Security] ds ON ds.[Security_Code] = t.[SecurityCode]
	LEFT JOIN [DWH].[dwh].[Dim_Portfolio] dpt ON dpt.[Portfolio_Code] = t.[PortfolioCode]
	LEFT JOIN [DWH].[dwh].[Dim_Currency] dc ON dc.[Currency_Code] = t.[PriceCcy]
	;

	/*	------------------------------------------------------------------	*/



--SET @RowsToProcess = @@ROWCOUNT

	--SET @CurrentRow = 0
	--WHILE @CurrentRow < @RowsToProcess
	--BEGIN

	--	SET @CurrentRow = @CurrentRow + 1
		
	--	SELECT 
	--		@AsAtDate = AsAtDate
	--		FROM @ReportDates
	--		WHERE RowID = @CurrentRow;


	--	-- Get the summary data 
	--	SET @SQL = 'EXEC [CAL_JBETL_PROD_COPY].[rep].[GetNAV] ''' + FORMAT( @AsAtDate, 'yyyy-MM-dd') + '''';
		
	--	SELECT * INTO #MyTempTable 
	--	FROM OPENROWSET( 'SQLNCLI', 'Server=.;Trusted_Connection=yes;', @SQL );


	--	-- Insert derived \ calculated data for the Summary Periodic Fact table 



	END

	   	  







