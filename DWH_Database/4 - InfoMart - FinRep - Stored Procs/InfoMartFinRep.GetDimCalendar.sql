CREATE PROCEDURE [InfoMartFinRep].[GetDimCalendar]		@AsOfDateTime	DATETIME2 =	NULL
WITH EXECUTE AS OWNER
AS

	--	Author:				Paul Loh	
	--	Creation Date:		20190130
	--	Description:		Dimension table from calendar reference table in Finrep (Financial Reporting) Information Mart.
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
	WHERE 		rc.CalendarDate <= DATEADD( MONTH, 12, GETDATE())
	AND			(
					@AsOfDateTime		BETWEEN			rc.Meta_LoadDateTime	
										AND				rc.Meta_LoadEndDateTime
				)	
;
   
