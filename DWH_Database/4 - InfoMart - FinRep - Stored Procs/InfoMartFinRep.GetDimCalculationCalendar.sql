CREATE PROCEDURE [InfoMartFinRep].[GetDimCalculationCalendar]		@AsOfDateTime	DATETIME2	=	NULL,
																	@YearsHistory	INT			=	NULL
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Calculation dimension table from calendar reference table in Finrep (Financial Reporting) Information Mart.
	--
	--						Parameters:
	--								@AsOfDateTime	:	Date\time records are retrieved for.
	--													Used to find records where parameter between Meta_LoadDateTime and Meta_LoadEndDateTime
	--						Grain: 
	--								Portfolio | Load DateTime

	IF ( @AsOfDateTime IS NULL )  
	BEGIN 
		SET @AsOfDateTime = SYSDATETIME()
	END;
	
    SELECT	rc.DateKey,
			rc.CalendarDate,
			rc.[Day],
			rc.[Month],
			rc.[Year],
			rc.[Quarter], 
			rc.[DayOfWeek],
			rc.DayOfQuarter,
			rc.[DayOfYear],
			rc.WeekNumISO,
			rc.MonthOfQuarter,
			rc.StartOfMonth,
			rc.EndOfMonth,
			rc.StartOfQuarter, 
			rc.EndOfQuarter,
			rc.StartOfCalYear,
			rc.EndOfCalYear,
			rc.StartOfFinYear
			,rc.[d]
			,rc.[dd]
			,rc.[ddd]
			,rc.[dddd]
			,rc.[m]
			,rc.[mm]
			,rc.[mmm]
			,rc.[mmmm]
			,rc.[q]
			,rc.[qqqq]
			,rc.[yyyy] 
			,rc.[yy]
			,rc.[yyyy] + N'_' + rc.q AS yyyy_q
			,rc.[yyyy] + N'_' + rc.q + N'_' + rc.mm AS yyyy_q_mm
			,rc.[FY_m]
			,rc.[FY_mm]
			,rc.[FY_q]
			,rc.[FY_qqqq]
			,rc.[FY_yy]
			,rc.[FY_yyyy]
			, rc.FY_yyyy + N'_' + rc.FY_q AS FY_yyyy_q
			,rc.[IsWeekDay]
			,rc.[IsHolidayUK]
			,rc.[HolidayUK]
			
	FROM		ref.RefCalendar rc	
	
	-- Add an extra year of calendar history so the Previous Year End measure works ?!?!?!
	-- WHERE 		rc.CalendarDate BETWEEN DATEADD( YEAR, - (@YearsHistory + 1), @AsOfDateTime ) 
	WHERE 		rc.CalendarDate BETWEEN DATEADD( YEAR, -1 * @YearsHistory, @AsOfDateTime ) 
								AND		CAST( @AsOfDateTime AS DATE ) 
								
	AND			(
					@AsOfDateTime		BETWEEN			rc.Meta_LoadDateTime	
										AND				rc.Meta_LoadEndDateTime
				)	

	ORDER BY 	rc.CalendarDate DESC	
;
   
