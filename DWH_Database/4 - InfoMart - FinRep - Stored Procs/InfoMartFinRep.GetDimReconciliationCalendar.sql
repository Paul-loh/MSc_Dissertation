CREATE PROCEDURE [InfoMartFinRep].[GetDimReconciliationCalendar]	@AsOfDateTime	DATETIME2 =	NULL
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Dimension table subset of calendar reference table in Finrep (Financial Reporting) Information Mart.
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
			rc.Day,
			rc.Month,
			rc.Year,
			rc.Quarter, 
			rc.DayOfWeek,
			rc.DayOfQuarter,
			rc.DayOfYear,
			rc.WeekNumISO,
			rc.MonthOfQuarter,
			rc.StartOfMonth,
			rc.EndOfMonth,
			rc.StartOfQuarter, 
			rc.EndOfQuarter,
			rc.StartOfCalYear,
			rc.EndOfCalYear,
			rc.StartOfFinYear,
			rc.EndOfFinYear
				
	FROM		ref.RefCalendar rc
	WHERE 		rc.CalendarDate BETWEEN 
										( SELECT DATETIMEFROMPARTS(  DATEPART(year, DATEADD( year, -1, @AsOfDateTime ) ), 1, 1, 0, 0, 0, 0 ) ) 
								AND 	
										@AsOfDateTime

				AND		(
							@AsOfDateTime		BETWEEN			rc.Meta_LoadDateTime	
												AND				rc.Meta_LoadEndDateTime
						)	

	ORDER BY 	rc.CalendarDate DESC;
   
